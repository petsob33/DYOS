import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../features/auth/domain/couple_model.dart';
import '../../features/auth/domain/user_model.dart';
import 'pairing_exceptions.dart';

class PairingService {
  PairingService({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
    required FirebaseFunctions functions,
  })  : _auth = auth,
        _firestore = firestore,
        _functions = functions;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  User? get currentUser => _auth.currentUser;

  String generateInviteCode(String displayName) {
    // Keep only A-Z so code format matches backend validation.
    final cleaned = displayName.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
    final seed = cleaned.isEmpty ? 'USER' : cleaned;
    final prefix = seed.substring(0, seed.length > 4 ? 4 : seed.length);
    final normalizedPrefix = prefix.length >= 2 ? prefix : '${prefix}X';
    final random = Random();
    final number = random.nextInt(9000) + 1000;
    return '$normalizedPrefix-$number';
  }

  Future<UserModel?> findUserByInviteCode(String inviteCode) async {
    try {
      final callable = _functions.httpsCallable('getUserByInviteCode');
      final result = await callable.call({'inviteCode': inviteCode});
      final payload = result.data;
      if (payload == null) return null;
      final map = Map<String, dynamic>.from(payload as Map);
      return UserModel(
        uid: map['uid'] as String? ?? '',
        email: map['email'] as String? ?? '',
        displayName: map['displayName'] as String?,
        inviteCode: map['inviteCode'] as String?,
        coupleId: map['coupleId'] as String?,
      );
    } catch (_) {
      return null;
    }
  }

  Future<CoupleModel?> getCoupleData(String coupleId) async {
    try {
      final doc = await _firestore.collection('couples').doc(coupleId).get();
      if (!doc.exists) return null;
      return CoupleModel.fromFirestore(doc);
    } catch (_) {
      return null;
    }
  }

  Future<CoupleModel> pairUsers(String currentUserId, String partnerUserId) async {
    if (currentUserId == partnerUserId) {
      throw SelfPairingException();
    }

    final results = await Future.wait([
      _firestore.collection('users').doc(currentUserId).get(),
      _firestore.collection('users').doc(partnerUserId).get(),
    ]);

    final currentUserDoc = results[0];
    final partnerUserDoc = results[1];
    if (!currentUserDoc.exists) {
      throw UserNotFoundException();
    }
    if (!partnerUserDoc.exists) {
      throw PartnerNotFoundException();
    }

    final currentUser = UserModel.fromFirestore(currentUserDoc);
    final partnerUser = UserModel.fromFirestore(partnerUserDoc);

    if (currentUser.coupleId != null && currentUser.coupleId!.isNotEmpty) {
      throw UserAlreadyPairedException();
    }
    if (partnerUser.coupleId != null && partnerUser.coupleId!.isNotEmpty) {
      throw PartnerAlreadyPairedException();
    }

    final batch = _firestore.batch();
    final coupleId = 'couple_${DateTime.now().millisecondsSinceEpoch}';
    final coupleRef = _firestore.collection('couples').doc(coupleId);

    final statusMap = <String, CoupleStatus>{
      currentUserId: CoupleStatus(
        emoji: '😊',
        text: 'Ready to connect',
        updatedAt: DateTime.now(),
      ),
      partnerUserId: CoupleStatus(
        emoji: '😊',
        text: 'Ready to connect',
        updatedAt: DateTime.now(),
      ),
    };

    final couple = CoupleModel(
      id: coupleId,
      members: [currentUserId, partnerUserId],
      anniversaryDate: DateTime.now(),
      createdAt: DateTime.now(),
      subscriptionTier: 'free',
      subscriptionExpiry: null,
      status: statusMap,
    );

    batch.set(coupleRef, couple.toJson());
    batch.update(_firestore.collection('users').doc(currentUserId), {'coupleId': coupleId});
    batch.update(_firestore.collection('users').doc(partnerUserId), {'coupleId': coupleId});

    await batch.commit();
    return couple;
  }

  Future<PairInviteCodeResult> pairWithInviteCode(String inviteCode) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw GenericPairingException('Please sign in again and retry pairing.');
    }

    final normalizedCode = inviteCode.trim().toUpperCase();
    if (!RegExp(r'^[A-Z]{2,10}-\d{4}$').hasMatch(normalizedCode)) {
      throw GenericPairingException('Invalid invite code format.');
    }

    try {
      final partnerQuery = await _firestore
          .collection('users')
          .where('inviteCode', isEqualTo: normalizedCode)
          .limit(1)
          .get();

      if (partnerQuery.docs.isEmpty) {
        throw PartnerNotFoundException();
      }

      final partnerDoc = partnerQuery.docs.first;
      final partnerUserId = partnerDoc.id;
      if (partnerUserId == currentUser.uid) {
        throw SelfPairingException();
      }

      final coupleRef = _firestore.collection('couples').doc();
      await _firestore.runTransaction((tx) async {
        final currentUserRef = _firestore.collection('users').doc(currentUser.uid);
        final partnerRef = _firestore.collection('users').doc(partnerUserId);

        final snapshots = await Future.wait([
          tx.get(currentUserRef),
          tx.get(partnerRef),
        ]);

        final currentSnap = snapshots[0];
        final partnerSnap = snapshots[1];

        if (!currentSnap.exists) {
          throw UserNotFoundException();
        }
        if (!partnerSnap.exists) {
          throw PartnerNotFoundException();
        }

        final currentData = currentSnap.data()!;
        final partnerData = partnerSnap.data()!;
        if ((currentData['coupleId'] as String?)?.isNotEmpty == true) {
          throw UserAlreadyPairedException();
        }
        if ((partnerData['coupleId'] as String?)?.isNotEmpty == true) {
          throw PartnerAlreadyPairedException();
        }

        final now = FieldValue.serverTimestamp();
        tx.set(coupleRef, {
          'members': [currentUser.uid, partnerUserId],
          'anniversaryDate': now,
          'createdAt': now,
          'subscriptionTier': 'free',
          'status': {
            currentUser.uid: {
              'emoji': '😊',
              'text': 'Ready to connect',
              'updatedAt': now,
            },
            partnerUserId: {
              'emoji': '😊',
              'text': 'Ready to connect',
              'updatedAt': now,
            },
          },
          'xp': 0,
        });
        tx.update(currentUserRef, {'coupleId': coupleRef.id});
        tx.update(partnerRef, {'coupleId': coupleRef.id});
      });

      final partnerName = partnerDoc.data()['displayName'] as String?;
      return PairInviteCodeResult(
        coupleId: coupleRef.id,
        partnerDisplayName: partnerName,
      );
    } on PairingException {
      rethrow;
    } on FirebaseException catch (_) {
      throw GenericPairingException('Unable to complete pairing right now.');
    } catch (_) {
      throw GenericPairingException('Unable to complete pairing right now.');
    }
  }

  Future<bool> isUserPaired(Future<UserModel?> Function() getUserData) async {
    final userData = await getUserData();
    return userData?.coupleId != null && userData!.coupleId!.isNotEmpty;
  }

  Future<UserModel?> getPartner({
    required Future<UserModel?> Function() getUserData,
    required Future<CoupleModel?> Function(String coupleId) getCoupleData,
  }) async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final userData = await getUserData();
      if (userData?.coupleId == null || userData!.coupleId!.isEmpty) {
        return null;
      }

      final couple = await getCoupleData(userData.coupleId!);
      if (couple == null) return null;

      final partnerUid = couple.members.firstWhere(
        (uid) => uid != user.uid,
        orElse: () => '',
      );
      if (partnerUid.isEmpty) return null;

      final partnerDoc = await _firestore.collection('users').doc(partnerUid).get();
      if (!partnerDoc.exists) return null;

      return UserModel.fromFirestore(partnerDoc);
    } catch (_) {
      return null;
    }
  }
}


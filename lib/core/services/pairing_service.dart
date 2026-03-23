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
    final prefix = displayName.toUpperCase().substring(
          0,
          displayName.length > 4 ? 4 : displayName.length,
        );
    final random = Random();
    final number = random.nextInt(9000) + 1000;
    return '$prefix-$number';
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

  Future<String?> pairWithInviteCode(String inviteCode) async {
    try {
      final callable = _functions.httpsCallable('pairWithInviteCode');
      final result = await callable.call({'inviteCode': inviteCode});
      final payload = Map<String, dynamic>.from(result.data as Map);
      final partner = payload['partner'];
      if (partner is Map) {
        return Map<String, dynamic>.from(partner)['displayName'] as String?;
      }
      return null;
    } on FirebaseFunctionsException catch (e) {
      throw mapPairingFunctionsException(e);
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

PairingException mapPairingFunctionsException(FirebaseFunctionsException e) {
  switch (e.code) {
    case 'invalid-argument':
      return GenericPairingException('Invalid invite code format.');
    case 'not-found':
      return PartnerNotFoundException();
    case 'failed-precondition':
      if ((e.message ?? '').contains('yourself')) {
        return SelfPairingException();
      }
      if ((e.message ?? '').contains('already paired')) {
        if ((e.message ?? '').contains('Your account')) {
          return UserAlreadyPairedException();
        }
        return PartnerAlreadyPairedException();
      }
      return GenericPairingException(e.message ?? 'Pairing failed.');
    default:
      return GenericPairingException(e.message ?? 'Pairing failed.');
  }
}

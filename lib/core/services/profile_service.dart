import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../features/auth/domain/couple_model.dart';
import '../../features/auth/domain/user_model.dart';
import 'pairing_service.dart';

class ProfileService {
  ProfileService({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
    required PairingService pairingService,
  })  : _auth = auth,
        _firestore = firestore,
        _pairingService = pairingService;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final PairingService _pairingService;

  User? get currentUser => _auth.currentUser;

  Future<UserModel?> getUserData({GetOptions? getOptions}) async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get(getOptions ?? const GetOptions());
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    } catch (_) {
      return null;
    }
  }

  Future<UserModel> createOrUpdateUser({
    required String uid,
    required String email,
    required String displayName,
    String? photoUrl,
  }) async {
    final userRef = _firestore.collection('users').doc(uid);
    final userDoc = await userRef.get();

    String inviteCode;
    UserModel? existingUser;
    if (userDoc.exists) {
      existingUser = UserModel.fromFirestore(userDoc);
      final existingInviteCode = existingUser.inviteCode;
      if (existingInviteCode != null && _isValidInviteCode(existingInviteCode)) {
        inviteCode = existingInviteCode;
      } else {
        inviteCode = _pairingService.generateInviteCode(displayName);
      }
    } else {
      inviteCode = _pairingService.generateInviteCode(displayName);
    }

    final userData = UserModel(
      uid: uid,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      inviteCode: inviteCode,
      createdAt: existingUser?.createdAt ?? DateTime.now(),
      coupleId: existingUser?.coupleId,
    );

    await userRef.set(userData.toJson(), SetOptions(merge: true));
    return userData;
  }

  bool _isValidInviteCode(String value) {
    return RegExp(r'^[A-Z]{2,10}-\d{4}$').hasMatch(value.trim().toUpperCase());
  }

  Future<void> deleteAccount({
    required Future<CoupleModel?> Function(String coupleId) getCoupleData,
  }) async {
    final user = currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in');
    }

    final userData = await getUserData();
    if (userData == null) {
      throw Exception('User data not found');
    }

    if (userData.coupleId != null && userData.coupleId!.isNotEmpty) {
      final couple = await getCoupleData(userData.coupleId!);
      if (couple != null) {
        final partnerUid = couple.members.firstWhere(
          (uid) => uid != user.uid,
          orElse: () => '',
        );

        final subcollections = [
          'memories',
          'intimacy_logs',
          'notes',
          'cycle_logs',
          'cycle_settings',
          'haptic_signals',
          'quick_messages',
        ];

        for (final subcollection in subcollections) {
          final subcollectionRef = _firestore
              .collection('couples')
              .doc(userData.coupleId!)
              .collection(subcollection);

          QuerySnapshot? snapshot;
          do {
            snapshot = await subcollectionRef.limit(500).get();
            if (snapshot.docs.isNotEmpty) {
              final deleteBatch = _firestore.batch();
              for (final doc in snapshot.docs) {
                deleteBatch.delete(doc.reference);
              }
              await deleteBatch.commit();
            }
          } while (snapshot.docs.length == 500);
        }

        final finalBatch = _firestore.batch();
        final coupleRef = _firestore.collection('couples').doc(userData.coupleId!);
        finalBatch.delete(coupleRef);

        if (partnerUid.isNotEmpty) {
          final partnerRef = _firestore.collection('users').doc(partnerUid);
          finalBatch.update(partnerRef, {'coupleId': FieldValue.delete()});
        }

        final userRef = _firestore.collection('users').doc(user.uid);
        finalBatch.delete(userRef);
        await finalBatch.commit();
      } else {
        await _firestore.collection('users').doc(user.uid).delete();
      }
    } else {
      await _firestore.collection('users').doc(user.uid).delete();
    }

    await user.delete();
  }
}

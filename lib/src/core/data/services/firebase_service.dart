import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/user_model.dart';
import '../models/couple_model.dart';

part 'firebase_service.g.dart';

@riverpod
FirebaseService firebaseService(FirebaseServiceRef ref) {
  return FirebaseService();
}

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check if user exists and has a couple
  Future<UserModel?> getUserData() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    } catch (e) {
      return null;
    }
  }

  // Create or update user document
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
      inviteCode = existingUser.inviteCode ?? _generateInviteCode(displayName);
    } else {
      // Generate unique invite code
      inviteCode = _generateInviteCode(displayName);
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

  // Generate unique invite code (e.g., "PETR-8821")
  String _generateInviteCode(String displayName) {
    final prefix = displayName.toUpperCase().substring(
        0, displayName.length > 4 ? 4 : displayName.length);
    final random = Random();
    final number = random.nextInt(9000) + 1000; // 1000-9999
    return '$prefix-$number';
  }

  // Find user by invite code
  Future<UserModel?> findUserByInviteCode(String inviteCode) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('inviteCode', isEqualTo: inviteCode.toUpperCase())
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;
      return UserModel.fromFirestore(query.docs.first);
    } catch (e) {
      return null;
    }
  }

  // Pair two users
  Future<CoupleModel> pairUsers(String currentUserId, String partnerUserId) async {
    final batch = _firestore.batch();

    // Create couple document
    final coupleId = 'couple_${DateTime.now().millisecondsSinceEpoch}';
    final coupleRef = _firestore.collection('couples').doc(coupleId);

    final couple = CoupleModel(
      id: coupleId,
      members: [currentUserId, partnerUserId],
      anniversaryDate: DateTime.now(), // Can be updated later
      createdAt: DateTime.now(),
    );

    batch.set(coupleRef, couple.toJson());

    // Update both users with coupleId
    final currentUserRef = _firestore.collection('users').doc(currentUserId);
    final partnerUserRef = _firestore.collection('users').doc(partnerUserId);

    batch.update(currentUserRef, {'coupleId': coupleId});
    batch.update(partnerUserRef, {'coupleId': coupleId});

    await batch.commit();
    return couple;
  }

  // Get couple data
  Future<CoupleModel?> getCoupleData(String coupleId) async {
    try {
      final doc = await _firestore.collection('couples').doc(coupleId).get();
      if (!doc.exists) return null;
      return CoupleModel.fromJson(doc.data()!);
    } catch (e) {
      return null;
    }
  }

  // Check if user is paired
  Future<bool> isUserPaired() async {
    final userData = await getUserData();
    return userData?.coupleId != null && userData!.coupleId!.isNotEmpty;
  }
}

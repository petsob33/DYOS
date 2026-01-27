import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/domain/user_model.dart';
import '../../features/auth/domain/couple_model.dart';
import 'pairing_exceptions.dart';

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
    } catch (e, stackTrace) {
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

  /// Pair two users together
  /// 
  /// This method creates a couple document in Firestore with:
  /// - Both user UIDs in the members array
  /// - Initial subscription tier set to "free"
  /// - Empty status objects for both users (to be updated later)
  /// - Anniversary date set to current date (can be updated later)
  /// 
  /// It also updates both user documents with the coupleId.
  /// 
  /// Returns the created CoupleModel.
  /// Throws an exception if pairing fails.
  Future<CoupleModel> pairUsers(String currentUserId, String partnerUserId) async {
    // Safety check: prevent pairing with yourself
    if (currentUserId == partnerUserId) {
      throw SelfPairingException();
    }

    // Safety check: verify both users exist
// Stáhne oba naráz
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

    // Safety check: verify neither user is already paired
    final currentUser = UserModel.fromFirestore(currentUserDoc);
    final partnerUser = UserModel.fromFirestore(partnerUserDoc);
    
    if (currentUser.coupleId != null && currentUser.coupleId!.isNotEmpty) {
      throw UserAlreadyPairedException();
    }
    if (partnerUser.coupleId != null && partnerUser.coupleId!.isNotEmpty) {
      throw PartnerAlreadyPairedException();
    }

    final batch = _firestore.batch();

    // Create couple document with new structure
    final coupleId = 'couple_${DateTime.now().millisecondsSinceEpoch}';
    final coupleRef = _firestore.collection('couples').doc(coupleId);

    // Initialize status map with empty statuses for both users
    // This allows the dashboard to display status without reading additional documents
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
      anniversaryDate: DateTime.now(), // Can be updated later by users
      createdAt: DateTime.now(),
      subscriptionTier: 'free', // Default to free tier
      subscriptionExpiry: null, // No expiry for free tier
      status: statusMap,
    );

    // Debug: print what we're saving
    final coupleJson = couple.toJson();

    // Set the couple document
    batch.set(coupleRef, coupleJson);

    // Update both users with coupleId
    final currentUserRef = _firestore.collection('users').doc(currentUserId);
    final partnerUserRef = _firestore.collection('users').doc(partnerUserId);

    batch.update(currentUserRef, {'coupleId': coupleId});
    batch.update(partnerUserRef, {'coupleId': coupleId});

    // Commit all changes atomically
    await batch.commit();
    return couple;
  }

  Future<CoupleModel?> getCoupleData(String coupleId) async {
    try {
      final doc = await _firestore.collection('couples').doc(coupleId).get();
      if (!doc.exists) return null;
      return CoupleModel.fromFirestore(doc);
    } catch (e, stackTrace) {
      // Log error for debugging but don't throw to prevent app crashes
      print('Error loading couple data for coupleId $coupleId: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  // Check if user is paired
  Future<bool> isUserPaired() async {
    final userData = await getUserData();
    return userData?.coupleId != null && userData!.coupleId!.isNotEmpty;
  }

  Future<UserModel?> getPartner() async {
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
    } catch (e, stackTrace) {
      return null;
    }
  }

  /// Update user's status in the couple document
  /// 
  /// Updates the emoji and text status for the current user.
  /// The status is stored in the couple document for quick access.
  /// This will trigger a real-time update for the partner.
  Future<void> updateStatus({
    required String coupleId,
    required String userId,
    required String emoji,
    required String text,
  }) async {
    try {
      final coupleRef = _firestore.collection('couples').doc(coupleId);
      
      // Update the status map in the couple document
      await coupleRef.update({
        'status.$userId': {
          'emoji': emoji,
          'text': text,
          'updatedAt': Timestamp.now(),
        },
      });
      
    } catch (e, stackTrace) {
      rethrow;
    }
  }

  /// Send haptic touch signal to partner
  /// 
  /// Creates a haptic signal document in Firestore that the partner's app
  /// will listen to and trigger a vibration.
  Future<void> sendHapticTouch({
    required String coupleId,
    required String fromUserId,
    required int durationMs,
  }) async {
    try {
      final signalsRef = _firestore
          .collection('couples')
          .doc(coupleId)
          .collection('haptic_signals')
          .doc();
      
      await signalsRef.set({
        'fromUserId': fromUserId,
        'durationMs': durationMs,
        'timestamp': Timestamp.now(),
        'read': false,
      });
      
    } catch (e, stackTrace) {
      rethrow;
    }
  }

  /// Send quick message to partner
  /// 
  /// Creates a quick message document in Firestore that will trigger
  /// a notification for the partner.
  Future<void> sendQuickMessage({
    required String coupleId,
    required String fromUserId,
    required String message,
  }) async {
    try {
      final messagesRef = _firestore
          .collection('couples')
          .doc(coupleId)
          .collection('quick_messages')
          .doc();
      
      await messagesRef.set({
        'fromUserId': fromUserId,
        'message': message,
        'timestamp': Timestamp.now(),
        'read': false,
      });
      
    } catch (e, stackTrace) {
      rethrow;
    }
  }

  /// Delete user account and all associated data
  /// 
  /// This is a destructive operation that permanently deletes:
  /// - User document from Firestore
  /// - Couple document (if user is paired) and all subcollections
  /// - Partner's coupleId reference (if paired)
  /// - Firebase Auth account
  /// 
  /// WARNING: This operation cannot be undone!
  /// 
  /// Process:
  /// 1. Get current user data
  /// 2. If user has coupleId, handle couple deletion:
  ///    - Get couple data
  ///    - Find partner
  ///    - Delete all couple subcollections (memories, intimacy_logs, notes, etc.)
  ///    - Delete couple document
  ///    - Remove coupleId from partner's user document
  /// 3. Delete user document from Firestore
  /// 4. Delete Firebase Auth account
  /// 
  /// Throws: Exception if deletion fails at any step
  Future<void> deleteAccount() async {
    final user = currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in');
    }

    try {
      // Step 1: Get user data
      final userData = await getUserData();
      if (userData == null) {
        throw Exception('User data not found');
      }

      final batch = _firestore.batch();

      // Step 2: Handle couple deletion if user is paired
      if (userData.coupleId != null && userData.coupleId!.isNotEmpty) {
        final couple = await getCoupleData(userData.coupleId!);
        
        if (couple != null) {
          // Find partner
          final partnerUid = couple.members.firstWhere(
            (uid) => uid != user.uid,
            orElse: () => '',
          );

          // Delete all subcollections
          // Note: Firestore batch operations have a limit of 500 operations
          // We delete subcollections in separate batches to handle large amounts of data
          final subcollections = [
            'memories',
            'intimacy_logs',
            'notes',
            'cycle_logs',
            'cycle_settings',
            'haptic_signals',
            'quick_messages',
          ];

          // Delete each subcollection in batches
          for (final subcollection in subcollections) {
            final subcollectionRef = _firestore
                .collection('couples')
                .doc(userData.coupleId!)
                .collection(subcollection);
            
            // Delete documents in batches of 500 (Firestore batch limit)
            QuerySnapshot? snapshot;
            do {
              snapshot = await subcollectionRef
                  .limit(500)
                  .get();
              
              if (snapshot.docs.isNotEmpty) {
                final deleteBatch = _firestore.batch();
                for (final doc in snapshot.docs) {
                  deleteBatch.delete(doc.reference);
                }
                await deleteBatch.commit();
              }
            } while (snapshot.docs.length == 500);
          }

          // Create final batch for couple and user documents
          final finalBatch = _firestore.batch();

          // Delete couple document
          final coupleRef = _firestore.collection('couples').doc(userData.coupleId!);
          finalBatch.delete(coupleRef);

          // Remove coupleId from partner's user document
          if (partnerUid.isNotEmpty) {
            final partnerRef = _firestore.collection('users').doc(partnerUid);
            finalBatch.update(partnerRef, {'coupleId': FieldValue.delete()});
          }

          // Delete user document
          final userRef = _firestore.collection('users').doc(user.uid);
          finalBatch.delete(userRef);

          // Commit final batch
          await finalBatch.commit();
        } else {
          // User not paired - just delete user document
          final userRef = _firestore.collection('users').doc(user.uid);
          await userRef.delete();
        }
      } else {
        // User not paired - just delete user document
        final userRef = _firestore.collection('users').doc(user.uid);
        await userRef.delete();
      }

      // Step 4: Delete Firebase Auth account
      await user.delete();

    } catch (e, stackTrace) {
      rethrow;
    }
  }
}

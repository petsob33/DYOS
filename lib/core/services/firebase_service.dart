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

    // Debugging print - před .set()
    final myId = FirebaseAuth.instance.currentUser?.uid;
    final membersList = [currentUserId, partnerUserId];
    
    print("=== DEBUGGING FIRESTORE WRITE ===");
    print("My ID (from currentUser): $myId");
    print("Current User ID (param): $currentUserId");
    print("Partner ID (param): $partnerUserId");
    print("Members List: $membersList");
    print("Members Length: ${membersList.length}");
    print("Couple ID: $coupleId");
    
    if (currentUserId == null || currentUserId.isEmpty) {
      print("ERROR! Current User ID is null or empty!");
      throw Exception("Current user ID is missing");
    }
    
    if (partnerUserId == null || partnerUserId.isEmpty) {
      print("ERROR! Partner User ID is null or empty!");
      throw Exception("Partner user ID is missing");
    }
    
    if (membersList.length != 2) {
      print("ERROR! Members list must contain exactly 2 users, got ${membersList.length}");
      throw Exception("Invalid members list size");
    }
    
    final coupleData = couple.toJson();
    print("Couple data keys: ${coupleData.keys.join(", ")}");
    print("Members in couple data: ${coupleData['members']}");
    print("Members type: ${coupleData['members'].runtimeType}");
    
    // Set the couple document
    batch.set(coupleRef, coupleData);

    // Update both users with coupleId
    final currentUserRef = _firestore.collection('users').doc(currentUserId);
    final partnerUserRef = _firestore.collection('users').doc(partnerUserId);

    batch.update(currentUserRef, {'coupleId': coupleId});
    batch.update(partnerUserRef, {'coupleId': coupleId});

    // Commit all changes atomically
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

  /// Get partner's user data
  /// 
  /// Finds the partner user by looking at the couple's members array
  /// and returning the user that is not the current user.
  /// 
  /// Returns: UserModel of the partner, or null if not found
  Future<UserModel?> getPartner() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      // Get current user's data to find coupleId
      final userData = await getUserData();
      if (userData?.coupleId == null || userData!.coupleId!.isEmpty) {
        return null; // User is not paired
      }

      // Get couple data
      final couple = await getCoupleData(userData.coupleId!);
      if (couple == null) return null;

      // Find partner's UID (the other member, not the current user)
      final partnerUid = couple.members.firstWhere(
        (uid) => uid != user.uid,
        orElse: () => '',
      );

      if (partnerUid.isEmpty) return null;

      // Get partner's user document
      final partnerDoc = await _firestore.collection('users').doc(partnerUid).get();
      if (!partnerDoc.exists) return null;

      return UserModel.fromFirestore(partnerDoc);
    } catch (e) {
      return null;
    }
  }
}

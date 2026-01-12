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
    if (user == null) {
      print('DEBUG getUserData: No current user');
      return null;
    }

    try {
      print('DEBUG getUserData: Loading user data for UID: ${user.uid}');
      final doc = await _firestore.collection('users').doc(user.uid).get();
      print('DEBUG getUserData: Document exists: ${doc.exists}');
      if (!doc.exists) {
        print('DEBUG getUserData: User document does not exist');
        return null;
      }
      final userModel = UserModel.fromFirestore(doc);
      print('DEBUG getUserData: User loaded - displayName: ${userModel.displayName}, email: ${userModel.email}, coupleId: ${userModel.coupleId}');
      return userModel;
    } catch (e, stackTrace) {
      print('ERROR in getUserData: $e');
      print('Stack trace: $stackTrace');
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
    print('DEBUG pairUsers: Saving couple - ID: $coupleId');
    print('DEBUG pairUsers: Members in couple object: ${couple.members}');
    print('DEBUG pairUsers: Members in JSON: ${coupleJson['members']}');
    print('DEBUG pairUsers: JSON keys: ${coupleJson.keys.join(", ")}');

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

  // Get couple data
  Future<CoupleModel?> getCoupleData(String coupleId) async {
    try {
      print('DEBUG getCoupleData: Loading couple with ID: $coupleId');
      final doc = await _firestore.collection('couples').doc(coupleId).get();
      if (!doc.exists) {
        print('DEBUG getCoupleData: Document does not exist');
        return null;
      }
      final data = doc.data()!;
      print('DEBUG getCoupleData: Document data keys: ${data.keys.join(", ")}');
      print('DEBUG getCoupleData: Members in data: ${data['members']}');
      print('DEBUG getCoupleData: Members type: ${data['members']?.runtimeType}');
      
      // Use fromFirestore to properly set the id field
      final couple = CoupleModel.fromFirestore(doc);
      print('DEBUG getCoupleData: Couple loaded - id: ${couple.id}, members: ${couple.members}, members count: ${couple.members.length}');
      return couple;
    } catch (e, stackTrace) {
      print('ERROR in getCoupleData: $e');
      print('Stack trace: $stackTrace');
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
    print('DEBUG getPartner: Starting...');
    final user = currentUser;
    if (user == null) {
      print('DEBUG getPartner: No current user');
      return null;
    }
    print('DEBUG getPartner: Current user UID: ${user.uid}');

    try {
      // Get current user's data to find coupleId
      final userData = await getUserData();
      print('DEBUG getPartner: User data loaded - coupleId: ${userData?.coupleId ?? 'null'}');
      if (userData?.coupleId == null || userData!.coupleId!.isEmpty) {
        print('DEBUG getPartner: User is not paired');
        return null; // User is not paired
      }

      // Get couple data
      final couple = await getCoupleData(userData.coupleId!);
      print('DEBUG getPartner: Couple data loaded - members: ${couple?.members ?? 'null'}');
      if (couple == null) {
        print('DEBUG getPartner: Couple not found');
        return null;
      }

      // Find partner's UID (the other member, not the current user)
      final partnerUid = couple.members.firstWhere(
        (uid) => uid != user.uid,
        orElse: () => '',
      );

      print('DEBUG getPartner: Partner UID found: $partnerUid');
      if (partnerUid.isEmpty) {
        print('DEBUG getPartner: Partner UID is empty. Members: ${couple.members}, Current user: ${user.uid}');
        return null;
      }

      // Get partner's user document
      final partnerDoc = await _firestore.collection('users').doc(partnerUid).get();
      print('DEBUG getPartner: Partner document exists: ${partnerDoc.exists}');
      if (!partnerDoc.exists) {
        print('DEBUG getPartner: Partner document does not exist for UID: $partnerUid');
        return null;
      }

      final partner = UserModel.fromFirestore(partnerDoc);
      print('DEBUG getPartner: Partner loaded successfully - UID: ${partner.uid}, displayName: ${partner.displayName}, email: ${partner.email}');
      return partner;
    } catch (e, stackTrace) {
      print('ERROR in getPartner: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }
}

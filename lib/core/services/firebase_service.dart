import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../firebase/firebase_functions_factory.dart';
import '../../features/auth/domain/user_model.dart';
import '../../features/auth/domain/couple_model.dart';
import 'app_logger.dart';
import 'couple_notification_service.dart';
import 'profile_service.dart';
import 'pairing_service.dart' as pairing;
import 'pairing_exceptions.dart';
import 'subscription_service.dart';

part 'firebase_service.g.dart';

@riverpod
FirebaseService firebaseService(FirebaseServiceRef ref) {
  return FirebaseService();
}

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = createFirebaseFunctions();
  late final pairing.PairingService _pairingService = pairing.PairingService(
    auth: _auth,
    firestore: _firestore,
    functions: _functions,
  );
  late final ProfileService _profileService = ProfileService(
    auth: _auth,
    firestore: _firestore,
    pairingService: _pairingService,
  );
  late final SubscriptionService _subscriptionService =
      SubscriptionService(firestore: _firestore);
  late final CoupleNotificationService _coupleNotificationService =
      CoupleNotificationService(firestore: _firestore);

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check if user exists and has a couple
  Future<UserModel?> getUserData({GetOptions? getOptions}) async {
    return _profileService.getUserData(getOptions: getOptions);
  }

  // Create or update user document
  Future<UserModel> createOrUpdateUser({
    required String uid,
    required String email,
    required String displayName,
    String? photoUrl,
  }) async {
    return _profileService.createOrUpdateUser(
      uid: uid,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
    );
  }

  // Find user by invite code (minimal payload from secured callable)
  Future<UserModel?> findUserByInviteCode(String inviteCode) async {
    return _pairingService.findUserByInviteCode(inviteCode);
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
    return _pairingService.pairUsers(currentUserId, partnerUserId);
  }

  /// Pair by invite code directly via Firestore lookup + transaction.
  Future<PairInviteCodeResult> pairWithInviteCode(String inviteCode) async {
    return _pairingService.pairWithInviteCode(inviteCode);
  }

  Future<PairInviteCodeResult> pairWithEmail(String email) async {
    return _pairingService.pairWithEmail(email);
  }

  Future<CoupleModel?> getCoupleData(String coupleId) async {
    final result = await _pairingService.getCoupleData(coupleId);
    if (result == null) {
      AppLogger.debug('Could not load couple data for coupleId $coupleId');
    }
    return result;
  }

  /// Update subscription fields on the couple document.
  /// Called after a successful RevenueCat purchase so both partners get premium via the couple stream.
  Future<void> updateCoupleSubscription(
    String coupleId, {
    required String subscriptionTier,
    DateTime? subscriptionExpiry,
  }) async {
    await _subscriptionService.updateCoupleSubscription(
      coupleId,
      subscriptionTier: subscriptionTier,
      subscriptionExpiry: subscriptionExpiry,
    );
  }

  // Check if user is paired
  Future<bool> isUserPaired() async {
    return _pairingService.isUserPaired(getUserData);
  }

  Future<UserModel?> getPartner() async {
    return _pairingService.getPartner(
      getUserData: getUserData,
      getCoupleData: getCoupleData,
    );
  }

  /// Add XP to the couple (gamification). Persisted in Firestore.
  Future<void> addCoupleXp(String coupleId, int amount) async {
    await _subscriptionService.addCoupleXp(coupleId, amount);
  }

  /// Save blueprint answers for a section and user. Merges into couple.blueprintAnswers.
  Future<void> saveBlueprintAnswers({
    required String coupleId,
    required String sectionId,
    required String userId,
    required Map<String, dynamic> answers,
  }) async {
    await _subscriptionService.saveBlueprintAnswers(
      coupleId: coupleId,
      sectionId: sectionId,
      userId: userId,
      answers: answers,
    );
  }

  /// Mark a blueprint section as completed for XP (so +100 XP is only given once per section).
  Future<void> addCompletedBlueprintSection(String coupleId, String sectionId) async {
    await _subscriptionService.addCompletedBlueprintSection(coupleId, sectionId);
  }

  /// Set last date XP was granted for a quest (for "once per day" logic).
  Future<void> setQuestXpGrantedAt(String coupleId, String questId, String dateString) async {
    await _subscriptionService.setQuestXpGrantedAt(coupleId, questId, dateString);
  }

  /// Atomically grants XP for a quest, once per day, inside a single
  /// Firestore transaction. See [SubscriptionService.grantQuestXpIfEligible].
  Future<bool> grantQuestXpIfEligible({
    required String coupleId,
    required String questId,
    required int amount,
  }) {
    return _subscriptionService.grantQuestXpIfEligible(
      coupleId: coupleId,
      questId: questId,
      amount: amount,
    );
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
    await _coupleNotificationService.updateStatus(
      coupleId: coupleId,
      userId: userId,
      emoji: emoji,
      text: text,
    );
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
    await _coupleNotificationService.sendHapticTouch(
      coupleId: coupleId,
      fromUserId: fromUserId,
      durationMs: durationMs,
    );
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
    await _coupleNotificationService.sendQuickMessage(
      coupleId: coupleId,
      fromUserId: fromUserId,
      message: message,
    );
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
    await _profileService.deleteAccount(getCoupleData: getCoupleData);
  }
}

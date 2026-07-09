import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/domain/couple_model.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../../core/services/subscription_service.dart'
    show isQuestGrantedForToday, todayDateString;

/// Provider that exposes current couple XP from Firestore. Reactive to stream updates.
final currentXpProvider = Provider<int>((ref) {
  return ref.watch(coupleProvider).when(
        data: (c) => c?.xp ?? 0,
        loading: () => 0,
        error: (_, __) => 0,
      );
});

/// [currentUserDataProvider] caches one snapshot and does not refresh after pairing.
/// Gamification must use [userProvider] (Firestore user stream) so [coupleId] stays correct.
String? _coupleIdForXp(dynamic ref) {
  final userAsync = ref.read(userProvider);
  if (userAsync.hasValue) {
    return userAsync.value?.coupleId;
  }
  return null;
}

/// True if this quest already granted XP today (once per day). Reads the
/// locally cached [couple] stream, so it's suitable for UI display (e.g. a
/// "completed" checkmark) but NOT as the actual grant gate - see
/// [grantQuestXpIfEligible], which checks server-side state transactionally.
bool isQuestCompletedToday(CoupleModel? couple, String questId) {
  if (couple?.questXpLastGrantedAt == null) return false;
  return isQuestGrantedForToday(couple!.questXpLastGrantedAt!, questId, todayDateString());
}

/// Add [amount] XP to the couple (persisted). Call only when user is paired.
Future<void> addCoupleXp(dynamic ref, int amount) async {
  if (amount <= 0) return;
  final coupleId = _coupleIdForXp(ref);
  if (coupleId == null) return;
  await ref.read(firebaseServiceProvider).addCoupleXp(coupleId, amount);
}

/// Grant XP for a quest only if not already granted today.
/// Returns true if XP was granted, false if skipped (already done today or not paired).
///
/// The eligibility check and both writes (XP increment + granted flag) run
/// inside a single Firestore transaction against server state (see
/// [FirebaseService.grantQuestXpIfEligible]) rather than against the locally
/// cached couple stream, so concurrent calls for the same quest (e.g. both
/// partners triggering it at once) can't double-grant XP.
Future<bool> grantQuestXpIfEligible(dynamic ref, String questId, int amount) async {
  if (amount <= 0) return false;
  final coupleId = _coupleIdForXp(ref);
  if (coupleId == null) return false;
  final firebase = ref.read(firebaseServiceProvider);
  return firebase.grantQuestXpIfEligible(
    coupleId: coupleId,
    questId: questId,
    amount: amount,
  );
}

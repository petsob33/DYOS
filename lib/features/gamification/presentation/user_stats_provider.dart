import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/domain/couple_model.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../../../core/services/firebase_service.dart';

/// Provider that exposes current couple XP from Firestore. Reactive to stream updates.
final currentXpProvider = Provider<int>((ref) {
  return ref.watch(coupleProvider).when(
        data: (c) => c?.xp ?? 0,
        loading: () => 0,
        error: (_, __) => 0,
      );
});

String _todayString() {
  final n = DateTime.now();
  return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
}

/// [currentUserDataProvider] caches one snapshot and does not refresh after pairing.
/// Gamification must use [userProvider] (Firestore user stream) so [coupleId] stays correct.
String? _coupleIdForXp(dynamic ref) {
  final fromStream = ref.read(userProvider).valueOrNull?.coupleId;
  if (fromStream != null && fromStream.isNotEmpty) return fromStream;
  final fromCached = ref.read(currentUserDataProvider).valueOrNull?.coupleId;
  if (fromCached != null && fromCached.isNotEmpty) return fromCached;
  return null;
}

/// True if this quest already granted XP today (once per day).
bool isQuestCompletedToday(CoupleModel? couple, String questId) {
  if (couple?.questXpLastGrantedAt == null) return false;
  final today = _todayString();
  if (questId == 'blueprint') {
    return couple!.questXpLastGrantedAt!.entries
        .any((e) => e.key.startsWith('blueprint_') && e.value == today);
  }
  return couple!.questXpLastGrantedAt![questId] == today;
}

/// Add [amount] XP to the couple (persisted). Call only when user is paired.
Future<void> addCoupleXp(dynamic ref, int amount) async {
  if (amount <= 0) return;
  final coupleId = _coupleIdForXp(ref);
  if (coupleId == null) return;
  await ref.read(firebaseServiceProvider).addCoupleXp(coupleId, amount);
}

/// Grant XP for a quest only if not already granted today. Persists the date.
/// Returns true if XP was granted, false if skipped (already done today or not paired).
Future<bool> grantQuestXpIfEligible(dynamic ref, String questId, int amount) async {
  if (amount <= 0) return false;
  final coupleId = _coupleIdForXp(ref);
  if (coupleId == null) return false;
  final firebase = ref.read(firebaseServiceProvider);
  final couple = await firebase.getCoupleData(coupleId);
  if (couple == null || isQuestCompletedToday(couple, questId)) return false;
  await firebase.addCoupleXp(coupleId, amount);
  await firebase.setQuestXpGrantedAt(coupleId, questId, _todayString());
  return true;
}

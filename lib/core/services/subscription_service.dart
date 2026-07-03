import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriptionService {
  SubscriptionService({required FirebaseFirestore firestore}) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  Future<void> updateCoupleSubscription(
    String coupleId, {
    required String subscriptionTier,
    DateTime? subscriptionExpiry,
  }) async {
    final coupleRef = _firestore.collection('couples').doc(coupleId);
    final updates = <String, dynamic>{'subscriptionTier': subscriptionTier};
    if (subscriptionExpiry != null) {
      updates['subscriptionExpiry'] = Timestamp.fromDate(subscriptionExpiry);
    } else {
      updates['subscriptionExpiry'] = FieldValue.delete();
    }
    await coupleRef.update(updates);
  }

  Future<void> addCoupleXp(String coupleId, int amount) async {
    if (amount <= 0) return;
    await _firestore.collection('couples').doc(coupleId).update({
      'xp': FieldValue.increment(amount),
    });
  }

  Future<void> saveBlueprintAnswers({
    required String coupleId,
    required String sectionId,
    required String userId,
    required Map<String, dynamic> answers,
  }) async {
    final path = 'blueprintAnswers.$sectionId.$userId';
    await _firestore.collection('couples').doc(coupleId).update({path: answers});
  }

  Future<void> addCompletedBlueprintSection(String coupleId, String sectionId) async {
    await _firestore.collection('couples').doc(coupleId).update({
      'completedBlueprintSections': FieldValue.arrayUnion([sectionId]),
    });
  }

  Future<void> setQuestXpGrantedAt(String coupleId, String questId, String dateString) async {
    await _firestore.collection('couples').doc(coupleId).update({
      'questXpLastGrantedAt.$questId': dateString,
    });
  }

  /// Atomically grants XP for a quest, once per day, in a single Firestore
  /// transaction: reads the current grant state fresh from the server, and
  /// only increments XP + sets the granted flag if it isn't already set for
  /// today. Returns true if XP was granted, false if it was already granted
  /// today or the couple document doesn't exist.
  ///
  /// This replaces the previous check-then-act pattern of reading a locally
  /// cached couple stream, then issuing two separate non-transactional
  /// writes (addCoupleXp + setQuestXpGrantedAt). That allowed both partners
  /// triggering the same quest within the same stale-cache window to each
  /// see "not granted yet" and double-grant XP - and if the app crashed
  /// between the two writes, XP could be granted without the flag being
  /// persisted. A single transaction closes both gaps: Firestore serializes
  /// concurrent transactions against the same document server-side and
  /// retries on conflict, and the XP increment and flag write commit
  /// together or not at all.
  Future<bool> grantQuestXpIfEligible({
    required String coupleId,
    required String questId,
    required int amount,
  }) async {
    if (amount <= 0) return false;
    final coupleRef = _firestore.collection('couples').doc(coupleId);
    final today = todayDateString();

    return _firestore.runTransaction<bool>((transaction) async {
      final snapshot = await transaction.get(coupleRef);
      if (!snapshot.exists) return false;

      final data = snapshot.data() ?? <String, dynamic>{};
      final granted = questXpLastGrantedAtFromFirestore(data['questXpLastGrantedAt']);

      if (isQuestGrantedForToday(granted, questId, today)) return false;

      transaction.update(coupleRef, {
        'xp': FieldValue.increment(amount),
        'questXpLastGrantedAt.$questId': today,
      });
      return true;
    });
  }
}

/// "YYYY-MM-DD" for the current local date - matches the format quest grant
/// dates are stored in ([SubscriptionService.grantQuestXpIfEligible],
/// [SubscriptionService.setQuestXpGrantedAt]).
String todayDateString([DateTime? now]) {
  final n = now ?? DateTime.now();
  return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
}

/// Normalizes the raw `questXpLastGrantedAt` Firestore field (a `Map` with
/// dynamic value types as decoded from JSON) into a `Map<String, String>`.
Map<String, String> questXpLastGrantedAtFromFirestore(Object? raw) {
  if (raw is! Map) return const {};
  return raw.map((key, value) => MapEntry(key as String, value as String));
}

/// True if [questId] already has a grant dated [today] in [granted].
///
/// Special-cased for 'blueprint': grants are recorded per-section as
/// 'blueprint_<sectionId>', but the daily quest list shows one generic
/// "Blueprint" row, so completion for display purposes means "any section
/// completed today" - see level_screen.dart.
bool isQuestGrantedForToday(Map<String, String> granted, String questId, String today) {
  if (questId == 'blueprint') {
    return granted.entries.any((e) => e.key.startsWith('blueprint_') && e.value == today);
  }
  return granted[questId] == today;
}

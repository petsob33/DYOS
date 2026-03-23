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
}

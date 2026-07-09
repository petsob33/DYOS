import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ouros_app/core/services/subscription_service.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late SubscriptionService service;
  const coupleId = 'couple_1';

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    service = SubscriptionService(firestore: firestore);
    await firestore.collection('couples').doc(coupleId).set({
      'members': ['user_a', 'user_b'],
      'xp': 0,
    });
  });

  group('SubscriptionService.grantQuestXpIfEligible', () {
    test('grants XP and records the date on first call today', () async {
      final granted = await service.grantQuestXpIfEligible(
        coupleId: coupleId,
        questId: 'memory',
        amount: 25,
      );

      expect(granted, true);
      final doc = await firestore.collection('couples').doc(coupleId).get();
      expect(doc.data()?['xp'], 25);
      expect(doc.data()?['questXpLastGrantedAt']?['memory'], isNotNull);
    });

    test('does not grant XP again the same day for the same quest', () async {
      await service.grantQuestXpIfEligible(
        coupleId: coupleId,
        questId: 'memory',
        amount: 25,
      );

      final grantedSecondTime = await service.grantQuestXpIfEligible(
        coupleId: coupleId,
        questId: 'memory',
        amount: 25,
      );

      expect(grantedSecondTime, false);
      final doc = await firestore.collection('couples').doc(coupleId).get();
      expect(doc.data()?['xp'], 25); // not 50
    });

    test('grants XP for two different quests independently on the same day', () async {
      await service.grantQuestXpIfEligible(coupleId: coupleId, questId: 'memory', amount: 25);
      await service.grantQuestXpIfEligible(coupleId: coupleId, questId: 'event', amount: 15);

      final doc = await firestore.collection('couples').doc(coupleId).get();
      expect(doc.data()?['xp'], 40);
    });

    test('does not grant XP when the couple document does not exist', () async {
      final granted = await service.grantQuestXpIfEligible(
        coupleId: 'nonexistent_couple',
        questId: 'memory',
        amount: 25,
      );

      expect(granted, false);
    });

    // NOTE: The actual "two concurrent calls only grant once" race-condition
    // regression test lives in test/gamification/emulator/ (Node, against
    // the real Firestore emulator), not here. fake_cloud_firestore's
    // runTransaction() uses a _DummyTransaction with no locking or retry
    // (see FakeFirebaseFirestore.runTransaction in the fake_cloud_firestore
    // package source), so two Future.wait-fired calls against it both read
    // "not granted yet" and both grant - it cannot demonstrate the fix
    // works, only real Firestore's transaction serialization can. See
    // test/gamification/emulator/xp_transaction_race.test.js.
  });

  group('isQuestGrantedForToday', () {
    test('matches an exact questId dated today', () {
      final granted = isQuestGrantedForToday({'memory': '2026-07-03'}, 'memory', '2026-07-03');
      expect(granted, true);
    });

    test('does not match a questId dated a different day', () {
      final granted = isQuestGrantedForToday({'memory': '2026-07-02'}, 'memory', '2026-07-03');
      expect(granted, false);
    });

    test("'blueprint' matches if any blueprint_<section> key is dated today", () {
      final granted = isQuestGrantedForToday(
        {'blueprint_values': '2026-07-03'},
        'blueprint',
        '2026-07-03',
      );
      expect(granted, true);
    });
  });
}

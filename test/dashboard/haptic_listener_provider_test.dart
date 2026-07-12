import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ouros_app/features/dashboard/presentation/haptic_listener_provider.dart';

/// Regression coverage for the "notification fires every time I open the
/// app" bug: hapticSignalsStream/quickMessagesStream query for read:false
/// documents, and a fresh Firestore listener always delivers everything
/// currently matching as its first snapshot - so without this backlog
/// check, any signal/message left over from a previous session (still
/// unread because nobody was actively subscribed to mark it read) would
/// replay its buzz/notification on every subsequent app open, not just the
/// first time it's actually seen.
void main() {
  late FakeFirebaseFirestore firestore;
  const coupleId = 'couple_1';
  const partnerId = 'partner_1';
  const meId = 'me_1';

  setUp(() {
    firestore = FakeFirebaseFirestore();
  });

  Future<QueryDocumentSnapshot<Map<String, dynamic>>> seedUnread({
    required String fromUserId,
    required DateTime timestamp,
  }) async {
    final ref = await firestore
        .collection('couples')
        .doc(coupleId)
        .collection('haptic_signals')
        .add({
      'fromUserId': fromUserId,
      'timestamp': Timestamp.fromDate(timestamp),
      'read': false,
    });
    final snapshot = await firestore
        .collection('couples')
        .doc(coupleId)
        .collection('haptic_signals')
        .where('read', isEqualTo: false)
        .get();
    return snapshot.docs.firstWhere((d) => d.id == ref.id);
  }

  test('backlog snapshot on (re)connect does not trigger a notification', () async {
    await seedUnread(fromUserId: partnerId, timestamp: DateTime(2026, 1, 1));

    final snapshot = await firestore
        .collection('couples')
        .doc(coupleId)
        .collection('haptic_signals')
        .where('read', isEqualTo: false)
        .get();

    final result = pickLatestUnreadFromPartner(
      snapshot.docs,
      currentUserId: meId,
      isBacklogSnapshot: true,
    );

    expect(result, isNull);
  });

  test('backlog signal is still marked read so it does not linger forever', () async {
    final doc = await seedUnread(fromUserId: partnerId, timestamp: DateTime(2026, 1, 1));

    pickLatestUnreadFromPartner(
      [doc],
      currentUserId: meId,
      isBacklogSnapshot: true,
    );

    // The update is fire-and-forget; flush the microtask queue.
    await Future<void>.delayed(Duration.zero);

    final refreshed = await firestore
        .collection('couples')
        .doc(coupleId)
        .collection('haptic_signals')
        .doc(doc.id)
        .get();
    expect(refreshed.data()?['read'], isTrue);
  });

  test('a live (non-backlog) snapshot does trigger a notification', () async {
    final doc = await seedUnread(fromUserId: partnerId, timestamp: DateTime(2026, 1, 1));

    final result = pickLatestUnreadFromPartner(
      [doc],
      currentUserId: meId,
      isBacklogSnapshot: false,
    );

    expect(result, isNotNull);
    expect(result!.data()['fromUserId'], partnerId);
  });

  test('signals sent by the current user are ignored either way', () async {
    final doc = await seedUnread(fromUserId: meId, timestamp: DateTime(2026, 1, 1));

    final backlogResult = pickLatestUnreadFromPartner(
      [doc],
      currentUserId: meId,
      isBacklogSnapshot: true,
    );
    final liveResult = pickLatestUnreadFromPartner(
      [doc],
      currentUserId: meId,
      isBacklogSnapshot: false,
    );

    expect(backlogResult, isNull);
    expect(liveResult, isNull);
  });

  test(
    'a multi-item backlog only replays once it is genuinely new, not one notification per stale item',
    () async {
      final first = await seedUnread(
        fromUserId: partnerId,
        timestamp: DateTime(2026, 1, 1),
      );
      final second = await seedUnread(
        fromUserId: partnerId,
        timestamp: DateTime(2026, 1, 2),
      );

      // Simulates the first snapshot delivered on (re)connect, containing
      // both stale unread docs.
      final backlogResult = pickLatestUnreadFromPartner(
        [first, second],
        currentUserId: meId,
        isBacklogSnapshot: true,
      );
      expect(backlogResult, isNull);

      await Future<void>.delayed(Duration.zero);

      // Both must have been marked read - if only the "latest" one had
      // been, the next reconnect would still find the other one unread and
      // replay a notification for it.
      final remaining = await firestore
          .collection('couples')
          .doc(coupleId)
          .collection('haptic_signals')
          .where('read', isEqualTo: false)
          .get();
      expect(remaining.docs, isEmpty);
    },
  );
}

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ouros_app/features/tracker/data/intimacy_repository.dart';
import 'package:ouros_app/features/tracker/domain/intimacy_log_model.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late IntimacyRepository repository;
  const coupleId = 'couple_1';

  IntimacyLog buildLog({String id = '', DateTime? date, int rating = 4}) {
    return IntimacyLog(
      id: id,
      date: date ?? DateTime(2026, 1, 1),
      initiatorId: 'user_1',
      rating: rating,
      protectionUsed: true,
    );
  }

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = IntimacyRepository(firestore: firestore);
  });

  group('IntimacyRepository.addLog', () {
    test('adds a log and generates an id', () async {
      final added = await repository.addLog(buildLog(), coupleId);

      expect(added.id, isNotEmpty);
      final doc = await firestore
          .collection('couples')
          .doc(coupleId)
          .collection('intimacy_logs')
          .doc(added.id)
          .get();
      expect(doc.exists, true);
      expect(doc.data()?['rating'], 4);
    });

    test('throws when coupleId is empty', () async {
      expect(
        () => repository.addLog(buildLog(), ''),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('IntimacyRepository.watchLogs', () {
    test('streams logs for a couple ordered by date descending', () async {
      await repository.addLog(buildLog(date: DateTime(2026, 1, 1)), coupleId);
      await repository.addLog(buildLog(date: DateTime(2026, 3, 1)), coupleId);

      final logs = await repository.watchLogs(coupleId).first;

      expect(logs.map((l) => l.date), [DateTime(2026, 3, 1), DateTime(2026, 1, 1)]);
    });

    test('returns an empty stream for an empty coupleId', () async {
      final logs = await repository.watchLogs('').first;
      expect(logs, isEmpty);
    });
  });

  group('IntimacyRepository pagination (getRecentLogsFeed / getOlderLogs)', () {
    test('getRecentLogsFeed bounds to the newest [limit] logs', () async {
      for (var i = 0; i < 5; i++) {
        await repository.addLog(buildLog(date: DateTime(2026, 1, i + 1)), coupleId);
      }

      final feed = await repository.getRecentLogsFeed(coupleId, limit: 3).first;

      expect(
        feed.map((l) => l.date),
        [DateTime(2026, 1, 5), DateTime(2026, 1, 4), DateTime(2026, 1, 3)],
      );
    });

    test('getOlderLogs fetches the page before a given date', () async {
      for (var i = 0; i < 5; i++) {
        await repository.addLog(buildLog(date: DateTime(2026, 1, i + 1)), coupleId);
      }

      final recent = await repository.getRecentLogsFeed(coupleId, limit: 3).first;
      final older = await repository.getOlderLogs(coupleId, before: recent.last.date, limit: 50);

      expect(older.map((l) => l.date), [DateTime(2026, 1, 2), DateTime(2026, 1, 1)]);
    });

    test('getOlderLogs returns nothing past the oldest log', () async {
      await repository.addLog(buildLog(date: DateTime(2026, 1, 1)), coupleId);

      final older = await repository.getOlderLogs(coupleId, before: DateTime(2026, 1, 1));

      expect(older, isEmpty);
    });
  });

  group('IntimacyRepository.updateLog', () {
    test('updates an existing log', () async {
      final added = await repository.addLog(buildLog(rating: 3), coupleId);

      await repository.updateLog(added.copyWith(rating: 5), coupleId);

      final doc = await firestore
          .collection('couples')
          .doc(coupleId)
          .collection('intimacy_logs')
          .doc(added.id)
          .get();
      expect(doc.data()?['rating'], 5);
    });

    test('throws when log id is empty', () async {
      expect(
        () => repository.updateLog(buildLog(id: ''), coupleId),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('IntimacyRepository.deleteLog', () {
    test('deletes an existing log', () async {
      final added = await repository.addLog(buildLog(), coupleId);

      await repository.deleteLog(added.id, coupleId);

      final doc = await firestore
          .collection('couples')
          .doc(coupleId)
          .collection('intimacy_logs')
          .doc(added.id)
          .get();
      expect(doc.exists, false);
    });

    test('throws when logId is empty', () async {
      expect(
        () => repository.deleteLog('', coupleId),
        throwsA(isA<Exception>()),
      );
    });
  });
}

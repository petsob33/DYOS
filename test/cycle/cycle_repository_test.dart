import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ouros_app/features/cycle/data/cycle_repository.dart';
import 'package:ouros_app/features/cycle/domain/cycle_log_model.dart';
import 'package:ouros_app/features/cycle/domain/cycle_settings_model.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late CycleRepository repository;
  const coupleId = 'couple_1';

  CycleLog buildLog({String id = '', DateTime? date}) {
    return CycleLog(
      id: id,
      date: date ?? DateTime(2026, 1, 1),
      flowIntensity: FlowIntensity.medium,
      mood: Mood.happy,
    );
  }

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = CycleRepository(firestore: firestore);
  });

  group('CycleRepository.addOrUpdateLog', () {
    test('creates a log and generates an id when none is given', () async {
      final saved = await repository.addOrUpdateLog(buildLog(), coupleId);

      expect(saved.id, isNotEmpty);
      final doc = await firestore
          .collection('couples')
          .doc(coupleId)
          .collection('cycle_logs')
          .doc(saved.id)
          .get();
      expect(doc.exists, true);
      expect(doc.data()?['flowIntensity'], 'medium');
    });

    test('updates in place when an id is given', () async {
      final created = await repository.addOrUpdateLog(buildLog(), coupleId);

      final updated = await repository.addOrUpdateLog(
        created.copyWith(mood: Mood.energetic),
        coupleId,
      );

      expect(updated.id, created.id);
      final logs = await repository.watchLogs(coupleId).first;
      expect(logs.length, 1);
      expect(logs.single.mood, Mood.energetic);
    });

    test('throws when coupleId is empty', () async {
      expect(
        () => repository.addOrUpdateLog(buildLog(), ''),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('CycleRepository.watchLogs', () {
    test('streams logs for a couple ordered by date descending', () async {
      await repository.addOrUpdateLog(buildLog(date: DateTime(2026, 1, 1)), coupleId);
      await repository.addOrUpdateLog(buildLog(date: DateTime(2026, 3, 1)), coupleId);

      final logs = await repository.watchLogs(coupleId).first;

      expect(logs.map((l) => l.date), [DateTime(2026, 3, 1), DateTime(2026, 1, 1)]);
    });

    test('returns an empty stream for an empty coupleId', () async {
      final logs = await repository.watchLogs('').first;
      expect(logs, isEmpty);
    });
  });

  group('CycleRepository.deleteLog', () {
    test('deletes an existing log', () async {
      final created = await repository.addOrUpdateLog(buildLog(), coupleId);

      await repository.deleteLog(created.id, coupleId);

      final doc = await firestore
          .collection('couples')
          .doc(coupleId)
          .collection('cycle_logs')
          .doc(created.id)
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

  group('CycleRepository settings', () {
    test('getSettings returns null when none saved yet', () async {
      final settings = await repository.getSettings(coupleId);
      expect(settings, isNull);
    });

    test('updateSettings then getSettings round-trips', () async {
      await repository.updateSettings(
        const CycleSettings(id: '', averageCycleLength: 30, periodLength: 6),
        coupleId,
      );

      final settings = await repository.getSettings(coupleId);

      expect(settings, isNotNull);
      expect(settings!.averageCycleLength, 30);
      expect(settings.periodLength, 6);
    });

    test('watchSettings streams updates', () async {
      // The doc doesn't exist yet, so watchSettings immediately emits null
      // on subscription; wait for the emission that follows the write.
      final afterWrite = repository.watchSettings(coupleId).skip(1).first;

      await repository.updateSettings(
        const CycleSettings(id: '', averageCycleLength: 25, periodLength: 4),
        coupleId,
      );

      final settings = await afterWrite;
      expect(settings?.averageCycleLength, 25);
    });

    test('getSettings throws when coupleId is empty', () async {
      expect(
        () => repository.getSettings(''),
        throwsA(isA<Exception>()),
      );
    });
  });
}

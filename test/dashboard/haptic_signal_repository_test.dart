import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ouros_app/features/dashboard/data/haptic_signal_repository.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late HapticSignalRepository repository;
  const coupleId = 'couple_1';

  Future<void> addSignal(String fromUserId, DateTime timestamp) async {
    await firestore
        .collection('couples')
        .doc(coupleId)
        .collection('haptic_signals')
        .add({
      'fromUserId': fromUserId,
      'timestamp': timestamp,
      'durationMs': 200,
      'read': false,
    });
  }

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = HapticSignalRepository(firestore: firestore);
  });

  group('HapticSignalRepository.watchSignals', () {
    test('returns an empty stream for an empty coupleId', () async {
      final signals = await repository.watchSignals('').first;
      expect(signals, isEmpty);
    });

    test('streams all signals for a couple, including already-read ones', () async {
      await addSignal('user_1', DateTime(2026, 7, 1));
      await addSignal('user_2', DateTime(2026, 7, 2));

      final signals = await repository.watchSignals(coupleId).first;

      expect(signals.map((s) => s.fromUserId), containsAll(['user_1', 'user_2']));
    });

    test('excludes signals older than the window, includes ones inside it', () async {
      final now = DateTime(2026, 8, 8);
      await addSignal('user_1', now.subtract(const Duration(days: 91)));
      await addSignal('user_2', now.subtract(const Duration(days: 30)));

      final signals = await repository.watchSignals(coupleId, now: now).first;

      expect(signals.map((s) => s.fromUserId), ['user_2']);
    });
  });
}

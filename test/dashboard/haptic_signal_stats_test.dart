import 'package:flutter_test/flutter_test.dart';

import 'package:ouros_app/features/dashboard/domain/haptic_signal.dart';
import 'package:ouros_app/features/dashboard/domain/haptic_signal_stats.dart';

void main() {
  const memberIds = ['user_1', 'user_2'];
  final now = DateTime(2026, 7, 15, 18, 0);

  HapticSignal signal(String fromUserId, DateTime timestamp) =>
      HapticSignal(fromUserId: fromUserId, timestamp: timestamp);

  group('heartsStreak', () {
    test('returns 0 when there are no signals', () {
      expect(heartsStreak([], memberIds: memberIds, now: now), 0);
    });

    test('returns 1 when both members sent a signal today', () {
      final signals = [
        signal('user_1', DateTime(2026, 7, 15, 9)),
        signal('user_2', DateTime(2026, 7, 15, 20)),
      ];

      expect(heartsStreak(signals, memberIds: memberIds, now: now), 1);
    });

    test('returns 0 when only one member sent today and neither sent yesterday', () {
      final signals = [signal('user_1', DateTime(2026, 7, 15, 9))];

      expect(heartsStreak(signals, memberIds: memberIds, now: now), 0);
    });

    test('counts consecutive days backward from today', () {
      final signals = [
        for (final day in [13, 14, 15])
          for (final member in memberIds) signal(member, DateTime(2026, 7, day, 12)),
      ];

      expect(heartsStreak(signals, memberIds: memberIds, now: now), 3);
    });

    test('stops counting at the first day that is missing a member', () {
      final signals = [
        signal('user_1', DateTime(2026, 7, 15, 12)),
        signal('user_2', DateTime(2026, 7, 15, 12)),
        signal('user_1', DateTime(2026, 7, 14, 12)),
        signal('user_2', DateTime(2026, 7, 14, 12)),
        // 2026-07-13: only user_1 sent -> breaks the streak
        signal('user_1', DateTime(2026, 7, 13, 12)),
      ];

      expect(heartsStreak(signals, memberIds: memberIds, now: now), 2);
    });

    test('gives a grace day when today has no signals yet, counting from yesterday', () {
      final signals = [
        signal('user_1', DateTime(2026, 7, 14, 12)),
        signal('user_2', DateTime(2026, 7, 14, 12)),
        signal('user_1', DateTime(2026, 7, 13, 12)),
        signal('user_2', DateTime(2026, 7, 13, 12)),
      ];

      expect(heartsStreak(signals, memberIds: memberIds, now: now), 2);
    });
  });
}

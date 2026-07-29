import 'package:flutter_test/flutter_test.dart';

import 'package:ouros_app/features/tracker/domain/intimacy_log_model.dart';
import 'package:ouros_app/features/tracker/domain/intimacy_stats.dart';

void main() {
  IntimacyLog buildLog({
    DateTime? date,
    int userOrgasmCount = 0,
    int partnerOrgasmCount = 0,
    int? duration,
  }) {
    return IntimacyLog(
      id: '',
      date: date ?? DateTime(2026, 1, 1),
      initiatorId: 'user_1',
      rating: 4,
      userOrgasmCount: userOrgasmCount,
      partnerOrgasmCount: partnerOrgasmCount,
      duration: duration,
      protectionUsed: true,
    );
  }

  group('totalOrgasms', () {
    test('returns zero for both when logs is empty', () {
      final result = totalOrgasms([]);
      expect(result.user, 0);
      expect(result.partner, 0);
    });

    test('sums user and partner orgasm counts across logs', () {
      final logs = [
        buildLog(userOrgasmCount: 2, partnerOrgasmCount: 1),
        buildLog(userOrgasmCount: 1, partnerOrgasmCount: 3),
      ];

      final result = totalOrgasms(logs);

      expect(result.user, 3);
      expect(result.partner, 4);
    });
  });

  group('longestDuration', () {
    test('returns null when logs is empty', () {
      expect(longestDuration([]), isNull);
    });

    test('returns null when every log has a null duration', () {
      final logs = [buildLog(duration: null), buildLog(duration: null)];
      expect(longestDuration(logs), isNull);
    });

    test('returns the max duration across all logs, ignoring nulls', () {
      final logs = [
        buildLog(duration: 15),
        buildLog(duration: null),
        buildLog(duration: 45),
        buildLog(duration: 30),
      ];
      expect(longestDuration(logs), 45);
    });
  });

  group('currentMonthStats', () {
    final now = DateTime(2026, 7, 15);

    test('returns empty-safe defaults when there are no logs', () {
      final stats = currentMonthStats([], now);

      expect(stats.count, 0);
      expect(stats.longestDurationMinutes, isNull);
      expect(stats.avgDurationMinutes, isNull);
      expect(stats.avgOrgasms, 0);
    });

    test('only counts logs within the given month and year', () {
      final logs = [
        buildLog(date: DateTime(2026, 7, 1), duration: 10),
        buildLog(date: DateTime(2026, 7, 20), duration: 20),
        buildLog(date: DateTime(2026, 6, 30), duration: 99),
        buildLog(date: DateTime(2025, 7, 15), duration: 99),
      ];

      final stats = currentMonthStats(logs, now);

      expect(stats.count, 2);
      expect(stats.longestDurationMinutes, 20);
      expect(stats.avgDurationMinutes, 15.0);
    });

    test('ignores null durations when computing longest and average duration', () {
      final logs = [
        buildLog(date: DateTime(2026, 7, 1), duration: 30),
        buildLog(date: DateTime(2026, 7, 2), duration: null),
      ];

      final stats = currentMonthStats(logs, now);

      expect(stats.count, 2);
      expect(stats.longestDurationMinutes, 30);
      expect(stats.avgDurationMinutes, 30.0);
    });

    test('reports null duration stats when every log this month has no duration', () {
      final logs = [
        buildLog(date: DateTime(2026, 7, 1), duration: null),
        buildLog(date: DateTime(2026, 7, 2), duration: null),
      ];

      final stats = currentMonthStats(logs, now);

      expect(stats.count, 2);
      expect(stats.longestDurationMinutes, isNull);
      expect(stats.avgDurationMinutes, isNull);
    });

    test('averages combined user+partner orgasms per log across the month, independent of duration', () {
      final logs = [
        buildLog(date: DateTime(2026, 7, 1), userOrgasmCount: 1, partnerOrgasmCount: 1, duration: null),
        buildLog(date: DateTime(2026, 7, 2), userOrgasmCount: 2, partnerOrgasmCount: 0, duration: 10),
      ];

      final stats = currentMonthStats(logs, now);

      expect(stats.avgOrgasms, 2.0);
    });
  });
}

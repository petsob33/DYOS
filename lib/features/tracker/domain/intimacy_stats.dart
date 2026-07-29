import 'intimacy_log_model.dart';

/// Total orgasm counts across all logs, split by who they belong to.
typedef OrgasmTotals = ({int user, int partner});

/// Aggregate stats for logs falling in the same calendar month/year as [now].
typedef MonthStats = ({
  int count,
  int? longestDurationMinutes,
  double? avgDurationMinutes,
  double avgOrgasms,
});

OrgasmTotals totalOrgasms(List<IntimacyLog> logs) {
  var user = 0;
  var partner = 0;
  for (final log in logs) {
    user += log.userOrgasmCount;
    partner += log.partnerOrgasmCount;
  }
  return (user: user, partner: partner);
}

MonthStats currentMonthStats(List<IntimacyLog> logs, DateTime now) {
  final monthLogs = logs
      .where((log) => log.date.year == now.year && log.date.month == now.month)
      .toList();

  final durations = monthLogs
      .map((log) => log.duration)
      .whereType<int>()
      .toList();

  final totalOrgasmsThisMonth = monthLogs.fold<int>(
    0,
    (sum, log) => sum + log.userOrgasmCount + log.partnerOrgasmCount,
  );

  return (
    count: monthLogs.length,
    longestDurationMinutes: durations.isEmpty ? null : durations.reduce((a, b) => a > b ? a : b),
    avgDurationMinutes: durations.isEmpty ? null : durations.reduce((a, b) => a + b) / durations.length,
    avgOrgasms: monthLogs.isEmpty ? 0 : totalOrgasmsThisMonth / monthLogs.length,
  );
}

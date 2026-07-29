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

/// The longest logged duration in minutes, or null if none of [logs] has one.
int? longestDuration(List<IntimacyLog> logs) {
  final durations = logs.map((log) => log.duration).whereType<int>().toList();
  return durations.isEmpty ? null : durations.reduce((a, b) => a > b ? a : b);
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
    longestDurationMinutes: longestDuration(monthLogs),
    avgDurationMinutes: durations.isEmpty ? null : durations.reduce((a, b) => a + b) / durations.length,
    avgOrgasms: monthLogs.isEmpty ? 0 : totalOrgasmsThisMonth / monthLogs.length,
  );
}

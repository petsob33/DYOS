import 'haptic_signal.dart';

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Number of consecutive days (ending today, or yesterday if today has no
/// signals yet) on which every id in [memberIds] sent at least one signal.
int heartsStreak(
  List<HapticSignal> signals, {
  required List<String> memberIds,
  required DateTime now,
}) {
  final sentDaysByUser = <String, Set<DateTime>>{};
  for (final signal in signals) {
    sentDaysByUser.putIfAbsent(signal.fromUserId, () => {}).add(_dateOnly(signal.timestamp));
  }

  bool allSentOn(DateTime day) =>
      memberIds.every((id) => sentDaysByUser[id]?.contains(day) ?? false);

  var day = _dateOnly(now);
  if (!allSentOn(day)) {
    day = day.subtract(const Duration(days: 1));
  }

  var streak = 0;
  while (allSentOn(day)) {
    streak++;
    day = day.subtract(const Duration(days: 1));
  }
  return streak;
}

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/presentation/auth_providers.dart';
import '../data/cycle_repository.dart';
import '../presentation/cycle_provider.dart';
import 'cycle_log.dart';

part 'cycle_provider.g.dart';

/// Provider that holds cycle logs
/// 
/// This provider manages the cycle logs state.
@riverpod
Stream<List<CycleLog>> cycleLogs(CycleLogsRef ref) {
  final userAsync = ref.watch(userProvider);
  final user = userAsync.valueOrNull;

  if (user == null || user.coupleId == null || user.coupleId!.isEmpty) {
    return Stream.value([]);
  }

  final repository = ref.watch(cycleRepositoryProvider);
  return repository.watchLogs(user.coupleId!).map((logs) {
    return logs.map((log) => CycleLog(
      date: log.date,
      flowIntensity: log.flowIntensity,
      mood: log.mood,
    )).toList();
  });
}

/// Provider that calculates predicted period days (List<DateTime>)
/// 
/// Calculates future period start dates based on cycle settings.
/// Returns empty list if settings are not available.
@riverpod
List<DateTime> predictedPeriodDays(PredictedPeriodDaysRef ref) {
  final settingsAsync = ref.watch(cycleSettingsStreamProvider);
  final settings = settingsAsync.valueOrNull;

  if (settings == null || settings.lastPeriodDate == null) {
    return [];
  }

  final lastPeriodDate = settings.lastPeriodDate!;
  final averageCycleLength = settings.averageCycleLength;
  final predictedPeriods = <DateTime>[];

  // Calculate next 6 predicted periods
  for (int i = 1; i <= 6; i++) {
    predictedPeriods.add(
      lastPeriodDate.add(Duration(days: averageCycleLength * i)),
    );
  }

  return predictedPeriods;
}

/// Provider that calculates fertile window (List<DateTime>)
/// 
/// Calculates the fertile window days (typically days 10-15 of the cycle).
/// Returns empty list if settings are not available.
@riverpod
List<DateTime> fertileWindow(FertileWindowRef ref) {
  final settingsAsync = ref.watch(cycleSettingsStreamProvider);
  final settings = settingsAsync.valueOrNull;

  if (settings == null || settings.lastPeriodDate == null) {
    return [];
  }

  final lastPeriodDate = settings.lastPeriodDate!;
  final fertileDays = <DateTime>[];

  // Fertile window is typically days 10-15 of the cycle
  for (int i = 10; i <= 15; i++) {
    fertileDays.add(lastPeriodDate.add(Duration(days: i)));
  }

  return fertileDays;
}

/// Provider that calculates ovulation day (DateTime)
/// 
/// Calculates the ovulation day (typically 14 days before the next period).
/// Returns null if settings are not available.
@riverpod
DateTime? ovulationDay(OvulationDayRef ref) {
  final settingsAsync = ref.watch(cycleSettingsStreamProvider);
  final settings = settingsAsync.valueOrNull;

  if (settings == null || settings.lastPeriodDate == null) {
    return null;
  }

  final lastPeriodDate = settings.lastPeriodDate!;
  final averageCycleLength = settings.averageCycleLength;
  
  // Ovulation is typically 14 days before the next period
  // Next period = lastPeriodDate + averageCycleLength
  // Ovulation = nextPeriod - 14 = lastPeriodDate + averageCycleLength - 14
  return lastPeriodDate.add(Duration(days: averageCycleLength - 14));
}
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/presentation/auth_providers.dart';
import '../data/cycle_repository.dart';
import '../domain/cycle_log_model.dart';
import '../domain/cycle_settings_model.dart';

part 'cycle_provider.g.dart';

/// Stream provider that watches cycle logs for the current user's couple
/// 
/// This provider automatically updates when logs are added, updated, or deleted.
/// It requires the user to be paired (have a coupleId).
@riverpod
Stream<List<CycleLog>> cycleLogsStream(CycleLogsStreamRef ref) {
  final userAsync = ref.watch(userProvider);
  final user = userAsync.valueOrNull;

  if (user == null || user.coupleId == null || user.coupleId!.isEmpty) {
    return Stream.value([]);
  }

  final repository = ref.watch(cycleRepositoryProvider);
  return repository.watchLogs(user.coupleId!);
}

/// Stream provider that watches cycle settings for the current user's couple
/// 
/// This provider automatically updates when settings are changed.
/// It requires the user to be paired (have a coupleId).
@riverpod
Stream<CycleSettings?> cycleSettingsStream(CycleSettingsStreamRef ref) {
  final userAsync = ref.watch(userProvider);
  final user = userAsync.valueOrNull;

  if (user == null || user.coupleId == null || user.coupleId!.isEmpty) {
    return Stream.value(null);
  }

  final repository = ref.watch(cycleRepositoryProvider);
  return repository.watchSettings(user.coupleId!);
}

/// Provider that calculates the next predicted period start date
/// 
/// Based on the last period date and average cycle length from settings.
/// Returns null if settings are not available or lastPeriodDate is null.
@riverpod
DateTime? nextPredictedPeriodDate(NextPredictedPeriodDateRef ref) {
  final settingsAsync = ref.watch(cycleSettingsStreamProvider);
  final settings = settingsAsync.valueOrNull;

  if (settings == null || settings.lastPeriodDate == null) {
    return null;
  }

  final lastPeriodDate = settings.lastPeriodDate!;
  return lastPeriodDate.add(Duration(days: settings.averageCycleLength));
}

/// Provider that calculates the fertile window (start and end dates)
/// 
/// The fertile window is typically days 10-15 of the cycle (relative to last period).
/// Returns null if settings are not available or lastPeriodDate is null.
@riverpod
FertileWindow? fertileWindow(FertileWindowRef ref) {
  final settingsAsync = ref.watch(cycleSettingsStreamProvider);
  final settings = settingsAsync.valueOrNull;

  if (settings == null || settings.lastPeriodDate == null) {
    return null;
  }

  final lastPeriodDate = settings.lastPeriodDate!;
  final fertileStart = lastPeriodDate.add(const Duration(days: 10));
  final fertileEnd = lastPeriodDate.add(const Duration(days: 15));

  return FertileWindow(start: fertileStart, end: fertileEnd);
}

/// Provider that calculates the ovulation day
///
/// Ovulation typically occurs approximately 14 days before the next period.
/// This is calculated as (lastPeriodDate + averageCycleLength - 14).
/// Returns null if settings are not available or lastPeriodDate is null.
@riverpod
DateTime? ovulationDay(OvulationDayRef ref) {
  final settingsAsync = ref.watch(cycleSettingsStreamProvider);
  final settings = settingsAsync.valueOrNull;

  if (settings == null || settings.lastPeriodDate == null) {
    return null;
  }

  final lastPeriodDate = settings.lastPeriodDate!;
  // Ovulation is typically 14 days before the next period
  // Next period = lastPeriodDate + averageCycleLength
  // Ovulation = nextPeriod - 14 = lastPeriodDate + averageCycleLength - 14
  return lastPeriodDate.add(Duration(days: settings.averageCycleLength - 14));
}

/// Provider that calculates the next 6 predicted period start dates.
///
/// Used by the calendar view to mark upcoming predicted periods (as
/// opposed to [nextPredictedPeriodDateProvider], which only exposes the
/// single next date for dashboard/insight display).
/// Returns an empty list if settings are not available.
@riverpod
List<DateTime> predictedPeriodDays(PredictedPeriodDaysRef ref) {
  final settingsAsync = ref.watch(cycleSettingsStreamProvider);
  final settings = settingsAsync.valueOrNull;

  if (settings == null || settings.lastPeriodDate == null) {
    return [];
  }

  final lastPeriodDate = settings.lastPeriodDate!;
  final averageCycleLength = settings.averageCycleLength;

  return [
    for (var i = 1; i <= 6; i++)
      lastPeriodDate.add(Duration(days: averageCycleLength * i)),
  ];
}

/// Provider that calculates every day of the fertile window (days 10-15
/// of the cycle) as a list.
///
/// Used by the calendar view to mark each fertile day (as opposed to
/// [fertileWindowProvider], which only exposes the window's start/end for
/// dashboard/insight display).
/// Returns an empty list if settings are not available.
@riverpod
List<DateTime> fertileWindowDays(FertileWindowDaysRef ref) {
  final settingsAsync = ref.watch(cycleSettingsStreamProvider);
  final settings = settingsAsync.valueOrNull;

  if (settings == null || settings.lastPeriodDate == null) {
    return [];
  }

  final lastPeriodDate = settings.lastPeriodDate!;

  return [
    for (var i = 10; i <= 15; i++) lastPeriodDate.add(Duration(days: i)),
  ];
}

/// Data class representing a fertile window period
class FertileWindow {
  final DateTime start;
  final DateTime end;

  const FertileWindow({required this.start, required this.end});
}

/// Provider class for cycle operations
/// 
/// This class provides methods for adding/editing cycle logs and managing settings.
class CycleProviderNotifier {
  final Ref ref;

  CycleProviderNotifier(this.ref);

  /// Add or update a cycle log entry
  /// 
  /// [log] - The CycleLog to add or update
  /// 
  /// Returns: The created/updated CycleLog
  /// 
  /// Throws: Exception if operation fails
  Future<CycleLog> addOrUpdateLog(CycleLog log) async {
    final userAsync = ref.read(userProvider);
    final user = userAsync.valueOrNull;

    if (user == null) {
      throw Exception('User not authenticated');
    }

    if (user.coupleId == null || user.coupleId!.isEmpty) {
      throw Exception('User is not paired. Please pair with your partner first.');
    }

    final repository = ref.read(cycleRepositoryProvider);
    return await repository.addOrUpdateLog(log, user.coupleId!);
  }

  /// Delete a cycle log entry
  /// 
  /// [logId] - The ID of the log to delete
  /// 
  /// Throws: Exception if operation fails
  Future<void> deleteLog(String logId) async {
    final userAsync = ref.read(userProvider);
    final user = userAsync.valueOrNull;

    if (user == null) {
      throw Exception('User not authenticated');
    }

    if (user.coupleId == null || user.coupleId!.isEmpty) {
      throw Exception('User is not paired. Please pair with your partner first.');
    }

    final repository = ref.read(cycleRepositoryProvider);
    return await repository.deleteLog(logId, user.coupleId!);
  }

  /// Update cycle settings
  /// 
  /// [settings] - The CycleSettings to update
  /// 
  /// Returns: The updated CycleSettings
  /// 
  /// Throws: Exception if operation fails
  Future<CycleSettings> updateSettings(CycleSettings settings) async {
    final userAsync = ref.read(userProvider);
    final user = userAsync.valueOrNull;

    if (user == null) {
      throw Exception('User not authenticated');
    }

    if (user.coupleId == null || user.coupleId!.isEmpty) {
      throw Exception('User is not paired. Please pair with your partner first.');
    }

    final repository = ref.read(cycleRepositoryProvider);
    return await repository.updateSettings(settings, user.coupleId!);
  }

  /// Get cycle settings (non-stream, one-time fetch)
  /// 
  /// Returns: CycleSettings or null if not found
  /// 
  /// Throws: Exception if operation fails
  Future<CycleSettings?> getSettings() async {
    final userAsync = ref.read(userProvider);
    final user = userAsync.valueOrNull;

    if (user == null) {
      throw Exception('User not authenticated');
    }

    if (user.coupleId == null || user.coupleId!.isEmpty) {
      throw Exception('User is not paired. Please pair with your partner first.');
    }

    final repository = ref.read(cycleRepositoryProvider);
    return await repository.getSettings(user.coupleId!);
  }
}

/// Provider that creates a CycleProviderNotifier instance
@riverpod
CycleProviderNotifier cycleProviderNotifier(CycleProviderNotifierRef ref) {
  return CycleProviderNotifier(ref);
}
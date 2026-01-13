// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cycle_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cycleLogsStreamHash() => r'8925419db26242cdd9da92a9ea9279b464b819dd';

/// Stream provider that watches cycle logs for the current user's couple
///
/// This provider automatically updates when logs are added, updated, or deleted.
/// It requires the user to be paired (have a coupleId).
///
/// Copied from [cycleLogsStream].
@ProviderFor(cycleLogsStream)
final cycleLogsStreamProvider =
    AutoDisposeStreamProvider<List<CycleLog>>.internal(
      cycleLogsStream,
      name: r'cycleLogsStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$cycleLogsStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CycleLogsStreamRef = AutoDisposeStreamProviderRef<List<CycleLog>>;
String _$cycleSettingsStreamHash() =>
    r'df523a5b13d9a84dd35e2760570bf697b226863a';

/// Stream provider that watches cycle settings for the current user's couple
///
/// This provider automatically updates when settings are changed.
/// It requires the user to be paired (have a coupleId).
///
/// Copied from [cycleSettingsStream].
@ProviderFor(cycleSettingsStream)
final cycleSettingsStreamProvider =
    AutoDisposeStreamProvider<CycleSettings?>.internal(
      cycleSettingsStream,
      name: r'cycleSettingsStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$cycleSettingsStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CycleSettingsStreamRef = AutoDisposeStreamProviderRef<CycleSettings?>;
String _$nextPredictedPeriodDateHash() =>
    r'111945ccd5ee078b9ea9254824f900247c7132c9';

/// Provider that calculates the next predicted period start date
///
/// Based on the last period date and average cycle length from settings.
/// Returns null if settings are not available or lastPeriodDate is null.
///
/// Copied from [nextPredictedPeriodDate].
@ProviderFor(nextPredictedPeriodDate)
final nextPredictedPeriodDateProvider = AutoDisposeProvider<DateTime?>.internal(
  nextPredictedPeriodDate,
  name: r'nextPredictedPeriodDateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$nextPredictedPeriodDateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NextPredictedPeriodDateRef = AutoDisposeProviderRef<DateTime?>;
String _$fertileWindowHash() => r'e784c13455d7f51b941dbad01813fd53cb053fc0';

/// Provider that calculates the fertile window (start and end dates)
///
/// The fertile window is typically days 10-15 of the cycle (relative to last period).
/// Returns null if settings are not available or lastPeriodDate is null.
///
/// Copied from [fertileWindow].
@ProviderFor(fertileWindow)
final fertileWindowProvider = AutoDisposeProvider<FertileWindow?>.internal(
  fertileWindow,
  name: r'fertileWindowProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$fertileWindowHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FertileWindowRef = AutoDisposeProviderRef<FertileWindow?>;
String _$ovulationDayHash() => r'200f151c46ad1f81bea8cc52e70bb9bcba1899e5';

/// Provider that calculates the ovulation day
///
/// Ovulation typically occurs approximately 14 days before the next period.
/// This is calculated as (lastPeriodDate + averageCycleLength - 14).
/// Returns null if settings are not available or lastPeriodDate is null.
///
/// Copied from [ovulationDay].
@ProviderFor(ovulationDay)
final ovulationDayProvider = AutoDisposeProvider<DateTime?>.internal(
  ovulationDay,
  name: r'ovulationDayProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$ovulationDayHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OvulationDayRef = AutoDisposeProviderRef<DateTime?>;
String _$cycleProviderNotifierHash() =>
    r'26a0fc4a55dba596a32da95a97b575e4e8662dc2';

/// Provider that creates a CycleProviderNotifier instance
///
/// Copied from [cycleProviderNotifier].
@ProviderFor(cycleProviderNotifier)
final cycleProviderNotifierProvider =
    AutoDisposeProvider<CycleProviderNotifier>.internal(
      cycleProviderNotifier,
      name: r'cycleProviderNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$cycleProviderNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CycleProviderNotifierRef =
    AutoDisposeProviderRef<CycleProviderNotifier>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

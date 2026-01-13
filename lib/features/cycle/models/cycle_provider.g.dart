// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cycle_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cycleLogsHash() => r'54b49b5bacd5a5158113d4894dd9eb049fb1f629';

/// Provider that holds cycle logs
///
/// This provider manages the cycle logs state.
///
/// Copied from [cycleLogs].
@ProviderFor(cycleLogs)
final cycleLogsProvider = AutoDisposeStreamProvider<List<CycleLog>>.internal(
  cycleLogs,
  name: r'cycleLogsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cycleLogsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CycleLogsRef = AutoDisposeStreamProviderRef<List<CycleLog>>;
String _$predictedPeriodDaysHash() =>
    r'7d2faa30d060f7e8dcb102c33e58dab355c6980c';

/// Provider that calculates predicted period days (List<DateTime>)
///
/// Calculates future period start dates based on cycle settings.
/// Returns empty list if settings are not available.
///
/// Copied from [predictedPeriodDays].
@ProviderFor(predictedPeriodDays)
final predictedPeriodDaysProvider =
    AutoDisposeProvider<List<DateTime>>.internal(
      predictedPeriodDays,
      name: r'predictedPeriodDaysProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$predictedPeriodDaysHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PredictedPeriodDaysRef = AutoDisposeProviderRef<List<DateTime>>;
String _$fertileWindowHash() => r'606c10dc91a7764e118a26c8b3b1f5f8ad1a2139';

/// Provider that calculates fertile window (List<DateTime>)
///
/// Calculates the fertile window days (typically days 10-15 of the cycle).
/// Returns empty list if settings are not available.
///
/// Copied from [fertileWindow].
@ProviderFor(fertileWindow)
final fertileWindowProvider = AutoDisposeProvider<List<DateTime>>.internal(
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
typedef FertileWindowRef = AutoDisposeProviderRef<List<DateTime>>;
String _$ovulationDayHash() => r'2585f17ad2174dd10f66f1563fee12ca3cb49523';

/// Provider that calculates ovulation day (DateTime)
///
/// Calculates the ovulation day (typically 14 days before the next period).
/// Returns null if settings are not available.
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
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

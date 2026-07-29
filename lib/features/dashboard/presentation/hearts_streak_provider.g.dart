// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hearts_streak_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$hapticSignalsHistoryHash() =>
    r'17dd5f3180218ed4e435d1ef86b6c3cab2958cbb';

/// Full history of haptic signals for the current user's couple, used to
/// compute the "hearts streak" highlight on the Data & Analytics screen.
///
/// Copied from [hapticSignalsHistory].
@ProviderFor(hapticSignalsHistory)
final hapticSignalsHistoryProvider =
    AutoDisposeStreamProvider<List<HapticSignal>>.internal(
      hapticSignalsHistory,
      name: r'hapticSignalsHistoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$hapticSignalsHistoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HapticSignalsHistoryRef =
    AutoDisposeStreamProviderRef<List<HapticSignal>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

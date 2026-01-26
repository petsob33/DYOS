// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'haptic_listener_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$hapticSignalsStreamHash() =>
    r'747ab52124c8fb524f11f551e8fc8c46d91c8eda';

/// Provider that listens for haptic signals from partner
///
/// Copied from [hapticSignalsStream].
@ProviderFor(hapticSignalsStream)
final hapticSignalsStreamProvider =
    AutoDisposeStreamProvider<DateTime?>.internal(
      hapticSignalsStream,
      name: r'hapticSignalsStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$hapticSignalsStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HapticSignalsStreamRef = AutoDisposeStreamProviderRef<DateTime?>;
String _$quickMessagesStreamHash() =>
    r'145dfe60ce53736e7ed5002692e6e52b1d6c32fc';

/// Provider that listens for quick messages from partner
///
/// Copied from [quickMessagesStream].
@ProviderFor(quickMessagesStream)
final quickMessagesStreamProvider =
    AutoDisposeStreamProvider<Map<String, dynamic>?>.internal(
      quickMessagesStream,
      name: r'quickMessagesStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$quickMessagesStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef QuickMessagesStreamRef =
    AutoDisposeStreamProviderRef<Map<String, dynamic>?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

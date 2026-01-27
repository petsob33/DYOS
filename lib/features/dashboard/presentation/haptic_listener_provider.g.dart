// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'haptic_listener_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$hapticSignalsStreamHash() =>
    r'de9c4b2db9a3d551d2374204858dee8e6570edf0';

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
    r'289f4d19664a392214e35dc1266195ffd8577920';

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

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cycle_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cycleRepositoryHash() => r'f44206495a85d38a3214897dec0c929bde0f8ff2';

/// Riverpod provider that creates a singleton CycleRepository instance
/// This follows the repository pattern for clean architecture
///
/// Copied from [cycleRepository].
@ProviderFor(cycleRepository)
final cycleRepositoryProvider = AutoDisposeProvider<CycleRepository>.internal(
  cycleRepository,
  name: r'cycleRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cycleRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CycleRepositoryRef = AutoDisposeProviderRef<CycleRepository>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

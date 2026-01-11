// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memory_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$memoryRepositoryHash() => r'd508f7106f3e40fb608a69b0c8e27161e1b63c60';

/// Riverpod provider that creates a singleton MemoryRepository instance
/// This follows the repository pattern for clean architecture
///
/// Copied from [memoryRepository].
@ProviderFor(memoryRepository)
final memoryRepositoryProvider = AutoDisposeProvider<MemoryRepository>.internal(
  memoryRepository,
  name: r'memoryRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$memoryRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MemoryRepositoryRef = AutoDisposeProviderRef<MemoryRepository>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

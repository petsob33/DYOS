// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'intimacy_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$intimacyLogsStreamHash() =>
    r'6f07108a6562b22069f0d8ddea50a0f96774018b';

/// Stream provider that watches intimacy logs for the current user's couple
///
/// This provider automatically updates when logs are added, updated, or deleted.
/// It requires the user to be paired (have a coupleId).
///
/// Copied from [intimacyLogsStream].
@ProviderFor(intimacyLogsStream)
final intimacyLogsStreamProvider =
    AutoDisposeStreamProvider<List<IntimacyLog>>.internal(
      intimacyLogsStream,
      name: r'intimacyLogsStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$intimacyLogsStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IntimacyLogsStreamRef = AutoDisposeStreamProviderRef<List<IntimacyLog>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

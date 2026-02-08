// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'premium_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$purchaseServiceHash() => r'9666bb178ce997d2391cc58395a38cd73575a2d7';

/// See also [purchaseService].
@ProviderFor(purchaseService)
final purchaseServiceProvider = AutoDisposeProvider<PurchaseService>.internal(
  purchaseService,
  name: r'purchaseServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$purchaseServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PurchaseServiceRef = AutoDisposeProviderRef<PurchaseService>;
String _$isPremiumHash() => r'008ed0b9c5a105ca952448c8c01ff8b6739abea8';

/// Derives premium status from the couple stream so the app can depend on a single AsyncValue for bool.
///
/// Copied from [isPremium].
@ProviderFor(isPremium)
final isPremiumProvider = AutoDisposeProvider<AsyncValue<bool>>.internal(
  isPremium,
  name: r'isPremiumProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isPremiumHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsPremiumRef = AutoDisposeProviderRef<AsyncValue<bool>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

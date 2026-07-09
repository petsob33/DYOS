// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$notificationServiceHash() =>
    r'015117d47fe71bf44664bf802ad1290b1e2492d4';

/// Service for handling notifications in the app
///
/// Handles:
/// - Local notifications (in-app / foreground)
/// - Firebase Cloud Messaging (push when app is in background or closed)
///
/// Copied from [notificationService].
@ProviderFor(notificationService)
final notificationServiceProvider = Provider<NotificationService>.internal(
  notificationService,
  name: r'notificationServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NotificationServiceRef = ProviderRef<NotificationService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

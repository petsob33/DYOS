// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authStateHash() => r'8d66f1b36c36fb23821c0fc880f8ccb5ae688e88';

/// Provider that streams the current authentication state
///
/// This provider exposes Firebase Auth's authentication state as a stream.
/// It's used throughout the app to reactively respond to auth changes.
///
/// Usage:
/// - Router uses this to redirect users based on auth state
/// - UI widgets can watch this to show/hide content based on login status
/// - Any part of the app can listen to auth changes reactively
///
/// Stream behavior:
/// - Emits User object when user is signed in
/// - Emits null when user is signed out
/// - Automatically updates when auth state changes (login, logout, token refresh)
///
/// Example:
/// ```dart
/// final authState = ref.watch(authStateProvider);
/// final isAuthenticated = authState.value != null;
/// ```
///
/// Copied from [authState].
@ProviderFor(authState)
final authStateProvider = AutoDisposeStreamProvider<User?>.internal(
  authState,
  name: r'authStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthStateRef = AutoDisposeStreamProviderRef<User?>;
String _$currentUserHash() => r'bb8045770bfb19870392407ad2f87446ef8ea6f2';

/// Provider that provides the current user (synchronous)
///
/// This provider gives immediate access to the current authenticated user
/// without waiting for stream updates. It reads from Firebase Auth's cached state.
///
/// Use this when you need:
/// - Quick synchronous access to current user
/// - User info that doesn't need to update reactively
/// - Initial user check before stream emits
///
/// Note: This reads from cache, so it may not reflect the latest state
/// immediately after sign in/out. For reactive updates, use authStateProvider.
///
/// Example:
/// ```dart
/// final user = ref.watch(currentUserProvider);
/// if (user != null) {
///   print('User is logged in: ${user.email}');
/// }
/// ```
///
/// Copied from [currentUser].
@ProviderFor(currentUser)
final currentUserProvider = AutoDisposeProvider<User?>.internal(
  currentUser,
  name: r'currentUserProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentUserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentUserRef = AutoDisposeProviderRef<User?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

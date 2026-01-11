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
String _$authHash() => r'421d23ab33104c094039efb502dd8930436fc7d8';

/// Alias for authStateProvider - streams the current authentication state
///
/// This is the same as authStateProvider, provided for consistency with naming conventions.
/// Returns Stream<User?> that emits the current Firebase Auth user or null.
///
/// Copied from [auth].
@ProviderFor(auth)
final authProvider = AutoDisposeStreamProvider<User?>.internal(
  auth,
  name: r'authProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthRef = AutoDisposeStreamProviderRef<User?>;
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
String _$isUserPairedHash() => r'099014ca29b8c27729b58d1992fedef34ebe5350';

/// Provider that checks if the current user is paired with a partner
///
/// This provider checks if the authenticated user has a coupleId in their
/// user document. It's used by the router to redirect users to the pairing
/// screen if they're not yet paired.
///
/// Returns:
/// - true if user is paired (has a coupleId)
/// - false if user is not paired (no coupleId or null)
/// - null if user is not authenticated or data is loading
///
/// Example:
/// ```dart
/// final isPaired = ref.watch(isUserPairedProvider);
/// if (isPaired == false) {
///   // Redirect to pairing screen
/// }
/// ```
///
/// Copied from [isUserPaired].
@ProviderFor(isUserPaired)
final isUserPairedProvider = AutoDisposeFutureProvider<bool?>.internal(
  isUserPaired,
  name: r'isUserPairedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isUserPairedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsUserPairedRef = AutoDisposeFutureProviderRef<bool?>;
String _$currentCoupleHash() => r'6a57585a4e2a44c63f7756d8abde8c4e29bc3237';

/// Provider that provides the current user's couple data
///
/// This provider fetches the couple document for the currently authenticated user.
/// It automatically finds the coupleId from the user's document and loads the couple data.
///
/// Returns:
/// - CoupleModel if user is paired and couple exists
/// - null if user is not paired, not authenticated, or couple doesn't exist
///
/// Example:
/// ```dart
/// final coupleAsync = ref.watch(currentCoupleProvider);
/// coupleAsync.when(
///   data: (couple) => couple != null ? Text('Paired!') : Text('Not paired'),
///   loading: () => CircularProgressIndicator(),
///   error: (e, _) => Text('Error: $e'),
/// );
/// ```
///
/// Copied from [currentCouple].
@ProviderFor(currentCouple)
final currentCoupleProvider = AutoDisposeFutureProvider<CoupleModel?>.internal(
  currentCouple,
  name: r'currentCoupleProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentCoupleHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentCoupleRef = AutoDisposeFutureProviderRef<CoupleModel?>;
String _$partnerHash() => r'ee11a92355ad1d7f23a1b6ecf6b931fdff4b8455';

/// Provider that provides the partner's user data
///
/// This provider finds and loads the partner's user document.
/// It uses the couple data to find the partner's UID (the other member in the couple).
///
/// Returns:
/// - UserModel of the partner if found
/// - null if user is not paired, not authenticated, or partner not found
///
/// Example:
/// ```dart
/// final partnerAsync = ref.watch(partnerProvider);
/// partnerAsync.when(
///   data: (partner) => partner != null ? Text(partner.displayName ?? 'Partner') : Text('No partner'),
///   loading: () => CircularProgressIndicator(),
///   error: (e, _) => Text('Error: $e'),
/// );
/// ```
///
/// Copied from [partner].
@ProviderFor(partner)
final partnerProvider = AutoDisposeFutureProvider<UserModel?>.internal(
  partner,
  name: r'partnerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$partnerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PartnerRef = AutoDisposeFutureProviderRef<UserModel?>;
String _$currentUserDataHash() => r'64155b0adda0d415ea426bace389b78b10601b9a';

/// Provider that provides the current user's data from Firestore
///
/// This provider fetches the current user's UserModel from Firestore.
/// It's different from currentUserProvider which gives Firebase Auth User.
///
/// Returns:
/// - UserModel if user is authenticated and document exists
/// - null if user is not authenticated or document doesn't exist
///
/// Copied from [currentUserData].
@ProviderFor(currentUserData)
final currentUserDataProvider = AutoDisposeFutureProvider<UserModel?>.internal(
  currentUserData,
  name: r'currentUserDataProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentUserDataHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentUserDataRef = AutoDisposeFutureProviderRef<UserModel?>;
String _$userHash() => r'843469f6e552d902ac4da1e691f71ff185b488ea';

/// Provider that streams the current user's UserModel from Firestore
///
/// This provider streams the current user's UserModel data, updating reactively
/// when the user document changes in Firestore. It depends on auth state - when
/// there's no authenticated user, it emits null.
///
/// Stream behavior:
/// - Emits UserModel when user is authenticated and document exists
/// - Emits null when user is not authenticated
/// - Automatically updates when user document changes in Firestore
///
/// Example:
/// ```dart
/// final userStream = ref.watch(userProvider);
/// userStream.when(
///   data: (user) => user != null ? Text(user.email) : Text('Not signed in'),
///   loading: () => CircularProgressIndicator(),
///   error: (e, _) => Text('Error: $e'),
/// );
/// ```
///
/// Copied from [user].
@ProviderFor(user)
final userProvider = AutoDisposeStreamProvider<UserModel?>.internal(
  user,
  name: r'userProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserRef = AutoDisposeStreamProviderRef<UserModel?>;
String _$coupleHash() => r'6a8b3179e8bc8dfd704c7cf2392764612d351748';

/// Provider that streams the current user's couple data
///
/// This provider streams the CoupleModel for the authenticated user, updating
/// reactively when the couple document changes in Firestore. It depends on
/// userProvider - when the user has a coupleId, it streams that couple's data.
///
/// Stream behavior:
/// - Emits CoupleModel when user is authenticated and has a coupleId
/// - Emits null when user is not authenticated, not paired, or couple doesn't exist
/// - Automatically updates when couple document changes in Firestore
///
/// Example:
/// ```dart
/// final coupleStream = ref.watch(coupleProvider);
/// coupleStream.when(
///   data: (couple) => couple != null ? Text('Paired!') : Text('Not paired'),
///   loading: () => CircularProgressIndicator(),
///   error: (e, _) => Text('Error: $e'),
/// );
/// ```
///
/// Copied from [couple].
@ProviderFor(couple)
final coupleProvider = AutoDisposeStreamProvider<CoupleModel?>.internal(
  couple,
  name: r'coupleProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$coupleHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CoupleRef = AutoDisposeStreamProviderRef<CoupleModel?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

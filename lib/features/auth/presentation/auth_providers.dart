import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firebase_service.dart';
import '../data/user_repository.dart';
import '../domain/user_model.dart';
import '../domain/couple_model.dart';

part 'auth_providers.g.dart';

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
@riverpod
Stream<User?> authState(AuthStateRef ref) {
  // Get the AuthService instance
  final authService = ref.watch(authServiceProvider);
  // Return the stream of auth state changes
  // This stream will automatically notify all watchers when auth state changes
  return authService.authStateChanges;
}

/// Alias for authStateProvider - streams the current authentication state
/// 
/// This is the same as authStateProvider, provided for consistency with naming conventions.
/// Returns Stream<User?> that emits the current Firebase Auth user or null.
@riverpod
Stream<User?> auth(AuthRef ref) {
  // Reuse the same stream source as authStateProvider
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
}

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
@riverpod
User? currentUser(CurrentUserRef ref) {
  // Get the AuthService instance
  final authService = ref.watch(authServiceProvider);
  // Return the current user synchronously
  // This reads from Firebase Auth's in-memory cache
  return authService.currentUser;
}

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
@riverpod
Future<bool?> isUserPaired(IsUserPairedRef ref) async {
  // Get the FirebaseService instance
  final firebaseService = ref.watch(firebaseServiceProvider);
  
  // Check if user is authenticated first
  final user = firebaseService.currentUser;
  if (user == null) {
    return null; // Not authenticated
  }

  try {
    // Use the FirebaseService method to check pairing status
    final isPaired = await firebaseService.isUserPaired();
    return isPaired;
  } catch (e) {
    // If there's an error, assume not paired
    // This is safe because we can always try pairing again
    return false;
  }
}

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
@riverpod
Future<CoupleModel?> currentCouple(CurrentCoupleRef ref) async {
  final firebaseService = ref.watch(firebaseServiceProvider);
  final user = firebaseService.currentUser;
  
  if (user == null) return null;
  
  try {
    // Get user data to find coupleId
    final userData = await firebaseService.getUserData();
    if (userData?.coupleId == null || userData!.coupleId!.isEmpty) {
      return null; // User is not paired
    }
    
    // Get couple data
    return await firebaseService.getCoupleData(userData.coupleId!);
  } catch (e) {
    return null;
  }
}

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
@riverpod
Future<UserModel?> partner(PartnerRef ref) async {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return await firebaseService.getPartner();
}

/// Provider that provides the current user's data from Firestore
/// 
/// This provider fetches the current user's UserModel from Firestore.
/// It's different from currentUserProvider which gives Firebase Auth User.
/// 
/// Returns:
/// - UserModel if user is authenticated and document exists
/// - null if user is not authenticated or document doesn't exist
@riverpod
Future<UserModel?> currentUserData(CurrentUserDataRef ref) async {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return await firebaseService.getUserData();
}

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
@riverpod
Stream<UserModel?> user(UserRef ref) {
  // Watch auth state - this is a StreamProvider, so we get AsyncValue
  // We need to convert it to a stream that switches based on auth state
  return ref.watch(authStateProvider.stream).asyncExpand((firebaseUser) {
    // If no authenticated user, return a stream that emits null
    if (firebaseUser == null) {
      return Stream<UserModel?>.value(null);
    }
    
    // Get user repository and stream the user's Firestore document
    final userRepository = ref.read(userRepositoryProvider);
    return userRepository.streamUser(firebaseUser.uid);
  });
}

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
@riverpod
Stream<CoupleModel?> couple(CoupleRef ref) {
  // Watch user provider to get coupleId - this is a StreamProvider
  return ref.watch(userProvider.stream).asyncExpand((user) {
    // If no user or no coupleId, return a stream that emits null
    if (user?.coupleId == null || user!.coupleId!.isEmpty) {
      return Stream<CoupleModel?>.value(null);
    }
    
    // Stream the couple document from Firestore
    final firestore = FirebaseFirestore.instance;
    return firestore
        .collection('couples')
        .doc(user.coupleId!)
        .snapshots()
        .map((doc) {
      // Check if document exists
      if (!doc.exists) return null;
      // Convert to CoupleModel
      final data = doc.data();
      if (data == null) return null;
      return CoupleModel.fromJson(data).copyWith(id: doc.id);
    });
  });
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/services/auth_service.dart';
import '../data/services/firebase_service.dart';

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

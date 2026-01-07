import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../repositories/user_repository.dart';
import '../models/user_model.dart';

part 'auth_service.g.dart';

/// Riverpod provider that creates and provides a singleton instance of AuthService
/// This ensures we have a single source of truth for authentication operations
@riverpod
AuthService authService(AuthServiceRef ref) {
  return AuthService(ref);
}

/// Authentication Service
/// 
/// This service handles all authentication-related operations using Firebase Auth.
/// It provides methods for:
/// - Signing in existing users
/// - Registering new users (and creating their Firestore document)
/// - Signing out users
/// - Monitoring authentication state changes
/// 
/// The service acts as a bridge between the UI layer and Firebase Auth,
/// providing a clean API and handling error translation for user-friendly messages.
class AuthService {
  /// Reference to Riverpod container - used to access other providers
  /// This allows us to get the UserRepository when needed
  final Ref _ref;
  
  /// Firebase Auth instance - handles all authentication operations
  /// This is a singleton provided by Firebase SDK
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  /// Lazy getter for UserRepository - only accessed when needed
  /// This follows dependency injection pattern through Riverpod
  UserRepository get _userRepository => _ref.read(userRepositoryProvider);

  /// Constructor - receives Riverpod ref for dependency injection
  AuthService(this._ref);

  /// Stream of authentication state changes
  /// 
  /// This stream emits a new User object whenever the authentication state changes:
  /// - When user signs in: emits the User object
  /// - When user signs out: emits null
  /// - When token refreshes: emits the updated User object
  /// 
  /// This is used by the router to automatically redirect users based on auth state
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Get current authenticated user synchronously
  /// 
  /// Returns the currently signed-in user, or null if no user is signed in.
  /// This is a synchronous getter that reads from Firebase Auth's cached state.
  User? get currentUser => _auth.currentUser;

  /// Sign in with email and password
  /// 
  /// Authenticates a user with their email and password credentials.
  /// 
  /// Process:
  /// 1. Trims email to remove whitespace
  /// 2. Calls Firebase Auth's signInWithEmailAndPassword
  /// 3. Returns UserCredential on success
  /// 4. Catches FirebaseAuthException and converts to user-friendly message
  /// 
  /// [email] - User's email address
  /// [password] - User's password (not trimmed to preserve intentional spaces)
  /// 
  /// Returns: UserCredential containing user info and auth tokens
  /// Throws: String with user-friendly error message
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Attempt to sign in with Firebase Auth
      // This validates credentials and creates a session
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(), // Remove leading/trailing whitespace
        password: password,   // Keep password as-is (may contain intentional spaces)
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      // Convert Firebase error codes to user-friendly messages
      // This improves UX by showing readable errors instead of technical codes
      throw _handleAuthException(e);
    }
  }

  /// Register with email and password
  /// 
  /// Creates a new user account and sets up their profile.
  /// 
  /// Process:
  /// 1. Creates Firebase Auth account (email/password)
  /// 2. Updates the user's display name in Firebase Auth
  /// 3. Creates a corresponding UserModel document in Firestore
  ///    - This stores additional user data (invite code, couple ID, etc.)
  /// 4. Returns UserCredential on success
  /// 
  /// [email] - User's email address
  /// [password] - User's chosen password
  /// [displayName] - User's full name/display name
  /// 
  /// Returns: UserCredential containing user info and auth tokens
  /// Throws: String with user-friendly error message
  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      // Step 1: Create the Firebase Auth account
      // This validates email format and password strength
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Step 2: Update display name in Firebase Auth profile
      // This is separate from Firestore - it's stored in Auth user profile
      await credential.user?.updateDisplayName(displayName);

      // Step 3: Create user document in Firestore
      // This stores app-specific data that's not in Firebase Auth
      // We only create if user was successfully created (null check)
      if (credential.user != null) {
        // Generate unique invite code for pairing
        // Format: NAME-1234 (e.g., PETR-8821, ANNA-1234)
        final inviteCode = _generateInviteCode(displayName);
        
        final userModel = UserModel(
          uid: credential.user!.uid,           // Use Firebase Auth UID as document ID
          email: email.trim(),                  // Store email
          displayName: displayName,            // Store display name
          inviteCode: inviteCode,              // Generate invite code for pairing
          createdAt: DateTime.now(),           // Track when account was created
          // Other fields (coupleId, etc.) will be set later
        );
        // Save to Firestore through repository layer
        await _userRepository.createUser(userModel);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      // Convert Firebase error codes to user-friendly messages
      throw _handleAuthException(e);
    }
  }

  /// Sign out the current user
  /// 
  /// Ends the current user session and clears authentication state.
  /// After this, authStateChanges stream will emit null.
  /// 
  /// Note: This only signs out from Firebase Auth.
  /// Firestore data remains (user document is not deleted).
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Generate unique invite code for user pairing
  /// 
  /// Creates a code in the format "NAME-1234" where:
  /// - NAME is the first 4 characters of display name (uppercase)
  /// - 1234 is a random 4-digit number (1000-9999)
  /// 
  /// Example: "Petr" → "PETR-8821"
  /// Example: "Anna" → "ANNA-1234"
  /// 
  /// [displayName] - User's display name to use as prefix
  /// Returns: Unique invite code string
  String _generateInviteCode(String displayName) {
    // Get first 4 characters of name (or all if shorter than 4)
    final prefix = displayName.toUpperCase().substring(
        0, displayName.length > 4 ? 4 : displayName.length);
    // Generate random 4-digit number (1000-9999)
    final random = Random();
    final number = random.nextInt(9000) + 1000;
    return '$prefix-$number';
  }

  /// Handle Firebase Auth exceptions and return user-friendly messages
  /// 
  /// Firebase Auth throws exceptions with technical error codes.
  /// This method translates those codes into messages users can understand.
  /// 
  /// Common error codes:
  /// - 'weak-password': Password doesn't meet security requirements
  /// - 'email-already-in-use': Email is already registered
  /// - 'user-not-found': No account exists with this email
  /// - 'wrong-password': Incorrect password provided
  /// - 'invalid-email': Email format is invalid
  /// - 'user-disabled': Account has been disabled by admin
  /// - 'too-many-requests': Rate limit exceeded (security feature)
  /// - 'operation-not-allowed': Auth method not enabled in Firebase console
  /// 
  /// [e] - The FirebaseAuthException to handle
  /// Returns: User-friendly error message string
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      default:
        // Fallback: use Firebase's message if available, or generic message
        return e.message ?? 'An error occurred. Please try again.';
    }
  }
}

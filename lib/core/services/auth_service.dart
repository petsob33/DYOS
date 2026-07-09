import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/auth/data/user_repository.dart';
import '../../features/auth/domain/user_model.dart';

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
  
  /// Google Sign-In instance
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Web client ID (type 3 in google-services.json) — required on Android
    // to obtain an idToken that Firebase Auth can verify.
    serverClientId:
        '112080403338-evu84vogva87fvee1rohdvmk2qsc2k2f.apps.googleusercontent.com',
  );
  
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
    UserCredential? credential;
    try {
      // Step 1: Create the Firebase Auth account
      // This validates email format and password strength
      credential = await _auth.createUserWithEmailAndPassword(
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
    } catch (e) {
      // If profile/Firestore setup fails after auth account creation,
      // remove the just-created auth user to avoid half-created accounts.
      if (credential?.user != null) {
        try {
          await credential!.user!.delete();
        } catch (_) {
          // Ignore cleanup errors and continue with fallback sign-out.
        }
      }
      await _auth.signOut();
      throw 'We could not finish creating your account. Please try again.';
    }
  }

  /// Sign in with Google
  /// 
  /// Authenticates a user using their Google account.
  /// 
  /// Process:
  /// 1. Signs in with Google (opens Google sign-in flow)
  /// 2. Gets authentication credentials from Google
  /// 3. Signs in to Firebase with Google credentials
  /// 4. Creates or updates user document in Firestore
  /// 5. Returns UserCredential on success
  /// 
  /// Returns: UserCredential containing user info and auth tokens
  /// Throws: String with user-friendly error message
  Future<UserCredential> signInWithGoogle() async {
    try {
      // Step 1: Trigger the Google Sign-In flow
      // This opens a dialog/web page for user to select Google account
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      // User cancelled the sign-in
      if (googleUser == null) {
        throw 'Sign in cancelled';
      }

      // Step 2: Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Step 3: Create a new credential for Firebase Auth
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Step 4: Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);

      // Step 5: Check if user document exists in Firestore.
      // Login flow only accepts existing accounts — new accounts must register.
      if (userCredential.user != null) {
        final existingUser = await _userRepository.getUserById(userCredential.user!.uid);

        if (existingUser == null) {
          // No app account found — clean up the Firebase auth entry and reject login.
          try {
            await userCredential.user!.delete();
          } catch (_) {}
          await _googleSignIn.signOut();
          throw 'No account found for this Google account. Please register first.';
        }

        // Existing user — update photo URL if it changed.
        if (userCredential.user!.photoURL != null &&
            existingUser.photoUrl != userCredential.user!.photoURL) {
          await _userRepository.updateUser(
            existingUser.copyWith(photoUrl: userCredential.user!.photoURL),
          );
        }
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      // Handle other errors (e.g., sign-in cancelled, network errors)
      throw e.toString();
    }
  }

  /// Register with Google
  ///
  /// Creates a new app account using Google sign-in.
  /// Throws if a Firestore account already exists for this Google account
  /// (the user should use Login instead).
  Future<UserCredential> registerWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw 'Sign in cancelled';

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        final existingUser = await _userRepository.getUserById(userCredential.user!.uid);

        if (existingUser != null) {
          // Account already exists — reject and send them to login.
          await _googleSignIn.signOut();
          await _auth.signOut();
          throw 'An account already exists for this Google account. Please log in instead.';
        }

        // New user — create Firestore document.
        final displayName = userCredential.user!.displayName ??
            googleUser.displayName ??
            'User';
        final inviteCode = _generateInviteCode(displayName);
        final userModel = UserModel(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email ?? '',
          displayName: displayName,
          photoUrl: userCredential.user!.photoURL,
          inviteCode: inviteCode,
          createdAt: DateTime.now(),
        );
        await _userRepository.createUser(userModel);
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw e.toString();
    }
  }

  /// Sign out the current user
  /// 
  /// Ends the current user session and clears authentication state.
  /// After this, authStateChanges stream will emit null.
  /// 
  /// Note: This signs out from both Firebase Auth and Google Sign-In.
  /// Firestore data remains (user document is not deleted).
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  /// Send password reset email
  /// 
  /// Sends a password reset email to the user's email address.
  /// The email contains a link that allows the user to reset their password.
  /// 
  /// [email] - User's email address
  /// 
  /// Throws: String with user-friendly error message
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
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
    // Keep only A-Z so backend callable validation accepts the code.
    final cleaned = displayName.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
    final seed = cleaned.isEmpty ? 'USER' : cleaned;
    final prefix = seed.substring(0, seed.length > 4 ? 4 : seed.length);
    final normalizedPrefix = prefix.length >= 2 ? prefix : '${prefix}X';
    // Generate random 4-digit number (1000-9999)
    final random = Random();
    final number = random.nextInt(9000) + 1000;
    return '$normalizedPrefix-$number';
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
      case 'invalid-credential':
      case 'invalid-login-credentials':
        return 'Invalid email or password.';
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

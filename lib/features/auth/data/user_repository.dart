import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'user_data_source.dart';
import '../domain/user_model.dart';

part 'user_repository.g.dart';

/// Riverpod provider that creates a singleton UserRepository instance
/// This follows the repository pattern for clean architecture
@riverpod
UserRepository userRepository(UserRepositoryRef ref) {
  return UserRepository();
}

/// Repository layer for user data operations
/// 
/// This class acts as an abstraction layer between business logic and data source.
/// It provides a clean, high-level API for user operations while hiding the
/// implementation details of Firestore.
/// 
/// Architecture pattern:
/// UI/Features → Repository → DataSource → Firestore
/// 
/// Benefits:
/// - Easy to test (can mock DataSource)
/// - Easy to swap data sources (Firestore → REST API, etc.)
/// - Centralized business logic
/// - Consistent error handling
/// 
/// The repository combines Firebase Auth (for current user) with Firestore
/// (for user data) to provide a unified interface.
class UserRepository {
  /// Data source that handles direct Firestore operations
  /// This is the low-level layer that talks to Firebase
  final UserDataSource _dataSource = UserDataSource();
  
  /// Firebase Auth instance - used to get current authenticated user
  /// We need this to know which user's data to fetch
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current authenticated user from Firebase Auth
  /// 
  /// This returns the Firebase Auth User object, which contains:
  /// - UID (unique identifier)
  /// - Email
  /// - Display name (from Auth profile)
  /// - Photo URL (from Auth profile)
  /// 
  /// Note: This is different from UserModel, which contains app-specific data
  /// stored in Firestore (like inviteCode, coupleId, etc.)
  User? get currentUser => _auth.currentUser;

  /// Get current user's data from Firestore
  /// 
  /// Fetches the complete UserModel for the currently authenticated user.
  /// This combines Firebase Auth user info with Firestore user data.
  /// 
  /// Returns null if:
  /// - No user is signed in
  /// - User document doesn't exist in Firestore
  /// - Error occurs during fetch
  /// 
  /// This is the most common method for getting current user's app data.
  Future<UserModel?> getCurrentUserData() async {
    final user = currentUser;
    // Safety check: ensure user is authenticated
    if (user == null) return null;
    // Fetch user document from Firestore using Auth UID
    return await _dataSource.getUserById(user.uid);
  }

  /// Get user by ID
  /// 
  /// Fetches a user's data from Firestore by their UID.
  /// Useful for fetching other users' data (e.g., partner's data).
  /// 
  /// [uid] - The Firebase Auth UID (also used as Firestore document ID)
  /// Returns: UserModel if found, null otherwise
  Future<UserModel?> getUserById(String uid) async {
    return await _dataSource.getUserById(uid);
  }

  /// Get user by invite code
  /// 
  /// Searches for a user by their unique invite code.
  /// Used in the pairing feature to find users to connect with.
  /// 
  /// [inviteCode] - The invite code to search for (e.g., "PETR-8821")
  /// Returns: UserModel if found, null otherwise
  /// 
  /// Note: Invite codes are case-insensitive (converted to uppercase)
  Future<UserModel?> getUserByInviteCode(String inviteCode) async {
    return await _dataSource.getUserByInviteCode(inviteCode);
  }

  /// Create a new user document in Firestore
  /// 
  /// Creates a new UserModel document. Typically called after user registration.
  /// 
  /// [user] - The UserModel to create
  /// Returns: The created UserModel (same as input, for chaining)
  /// 
  /// Note: This will fail if a document with the same UID already exists.
  /// Use createOrUpdateUser for upsert behavior.
  Future<UserModel> createUser(UserModel user) async {
    return await _dataSource.createUser(user);
  }

  /// Update an existing user document in Firestore
  /// 
  /// Updates all fields of a user document. The UserModel must have a valid UID.
  /// 
  /// [user] - The UserModel with updated data
  /// Returns: The updated UserModel
  /// 
  /// Note: This will fail if the document doesn't exist.
  /// Use createOrUpdateUser for upsert behavior.
  Future<UserModel> updateUser(UserModel user) async {
    return await _dataSource.updateUser(user);
  }

  /// Create or update user (upsert operation)
  /// 
  /// If a user document exists, it updates it. If not, it creates a new one.
  /// This is useful when you're not sure if the document exists.
  /// 
  /// [user] - The UserModel to create or update
  /// Returns: The UserModel after save
  /// 
  /// This uses Firestore's merge option, which combines existing data
  /// with new data (doesn't overwrite unspecified fields).
  Future<UserModel> createOrUpdateUser(UserModel user) async {
    return await _dataSource.createOrUpdateUser(user);
  }

  /// Update specific user fields
  /// 
  /// Updates only the specified fields without replacing the entire document.
  /// More efficient than updateUser when you only need to change a few fields.
  /// 
  /// [uid] - The user's UID (document ID)
  /// [fields] - Map of field names to new values
  /// 
  /// Example:
  /// ```dart
  /// await updateUserFields(uid, {'coupleId': 'couple_123'});
  /// ```
  Future<void> updateUserFields(String uid, Map<String, dynamic> fields) async {
    await _dataSource.updateUserFields(uid, fields);
  }

  /// Delete a user document from Firestore
  /// 
  /// Permanently removes the user's document from Firestore.
  /// 
  /// [uid] - The user's UID (document ID)
  /// 
  /// Warning: This only deletes Firestore data, not the Firebase Auth account.
  /// To fully delete a user, also delete from Firebase Auth.
  Future<void> deleteUser(String uid) async {
    await _dataSource.deleteUser(uid);
  }

  /// Stream user data for real-time updates
  /// 
  /// Returns a stream that emits UserModel whenever the document changes.
  /// This is useful for real-time UI updates (e.g., when partner updates their status).
  /// 
  /// [uid] - The user's UID to stream
  /// Returns: Stream that emits UserModel on changes, or null if document doesn't exist
  /// 
  /// The stream will:
  /// - Emit current data immediately
  /// - Emit new data whenever the document is updated
  /// - Emit null if the document is deleted
  Stream<UserModel?> streamUser(String uid) {
    return _dataSource.streamUser(uid);
  }

  /// Stream current user's data
  /// 
  /// Convenience method that streams the currently authenticated user's data.
  /// Automatically handles the case where no user is signed in.
  /// 
  /// Returns: Stream of current user's UserModel, or Stream.value(null) if not signed in
  /// 
  /// This is useful for widgets that need to reactively update when user data changes.
  Stream<UserModel?> streamCurrentUser() {
    final user = currentUser;
    // If no user, return a stream that immediately emits null
    if (user == null) return Stream.value(null);
    // Otherwise, stream the user's data
    return _dataSource.streamUser(user.uid);
  }

  /// Check if current user exists in Firestore
  /// 
  /// Verifies that the current user has a corresponding document in Firestore.
  /// Useful for checking if user profile is fully set up.
  /// 
  /// Returns: true if document exists, false if not signed in or document missing
  Future<bool> currentUserExists() async {
    final user = currentUser;
    if (user == null) return false;
    return await _dataSource.userExists(user.uid);
  }

  /// Check if user is paired (has a coupleId)
  /// 
  /// Determines if the current user has been paired with another user.
  /// A user is considered "paired" if they have a non-empty coupleId.
  /// 
  /// Returns: true if user has a coupleId, false otherwise
  /// 
  /// This is used to determine if user should see pairing screen or main app.
  Future<bool> isUserPaired() async {
    final userData = await getCurrentUserData();
    // Check if coupleId exists and is not empty
    return userData?.coupleId != null && userData!.coupleId!.isNotEmpty;
  }
}

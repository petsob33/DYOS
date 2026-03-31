import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../../core/firebase/firebase_functions_factory.dart';
import '../domain/user_model.dart';

/// Data source layer for user operations in Firebase Firestore
/// 
/// This is the lowest level of data access - it directly interacts with Firestore.
/// It handles:
/// - CRUD operations on user documents
/// - Querying users by various criteria
/// - Real-time data streaming
/// - Error handling and null safety
/// 
/// Architecture: This sits below the Repository layer and above Firestore.
/// It provides a clean interface for Firestore operations while handling
/// the conversion between Firestore documents and UserModel objects.
/// 
/// Design decisions:
/// - All methods return null on error (fail gracefully)
/// - Uses UserModel.fromFirestore() for proper data conversion
/// - Supports dependency injection for testing (can pass mock Firestore)
class UserDataSource {
  /// Firestore instance - can be injected for testing
  /// Defaults to FirebaseFirestore.instance if not provided
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  /// Constructor with optional Firestore instance for testing
  /// If not provided, uses the default Firebase Firestore instance
  UserDataSource({FirebaseFirestore? firestore, FirebaseFunctions? functions})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _functions = functions ?? createFirebaseFunctions();


  /// Collection reference for users
  /// 
  /// This is a convenience getter that returns a reference to the 'users' collection.
  /// All user documents are stored in this collection, with UID as document ID.
  /// 
  /// Firestore structure:
  /// users/
  ///   {uid}/
  ///     email: string
  ///     displayName: string
  ///     inviteCode: string
  ///     coupleId: string?
  ///     ...
  CollectionReference get _usersCollection => _firestore.collection('users');

  /// Get user by document ID
  /// 
  /// Fetches a single user document from Firestore by their UID.
  /// 
  /// Process:
  /// 1. Get document reference using UID
  /// 2. Fetch document data
  /// 3. Check if document exists
  /// 4. Convert Firestore document to UserModel
  /// 
  /// [uid] - The user's Firebase Auth UID (used as Firestore document ID)
  /// Returns: UserModel if found, null if document doesn't exist or error occurs
  /// 
  /// Error handling: Returns null on any error to fail gracefully
  Future<UserModel?> getUserById(String uid) async {
    try {
      // Get the document reference and fetch its data
      final doc = await _usersCollection.doc(uid).get();
      // Check if document exists in Firestore
      if (!doc.exists) return null;
      // Convert Firestore document to UserModel
      // fromFirestore handles Timestamp conversion and sets UID from document ID
      return UserModel.fromFirestore(doc);
    } catch (e) {
      // Fail gracefully - return null instead of throwing
      // This allows calling code to handle missing users elegantly
      return null;
    }
  }

  /// Get user by invite code
  /// 
  /// Searches for a user document by their unique invite code.
  /// Used in the pairing feature to find users to connect with.
  /// 
  /// Process:
  /// 1. Query users collection where inviteCode matches
  /// 2. Convert invite code to uppercase for case-insensitive search
  /// 3. Limit to 1 result (invite codes should be unique)
  /// 4. Convert first result to UserModel
  /// 
  /// [inviteCode] - The invite code to search for (e.g., "PETR-8821")
  /// Returns: UserModel if found, null if not found or error occurs
  /// 
  /// Note: Invite codes are stored in uppercase, so we convert search term
  Future<UserModel?> getUserByInviteCode(String inviteCode) async {
    try {
      final callable = _functions.httpsCallable('getUserByInviteCode');
      final result = await callable.call({'inviteCode': inviteCode});
      if (result.data == null) {
        return null;
      }
      return UserModel.fromJson(Map<String, dynamic>.from(result.data));
    } catch (e) {
      // Fail gracefully
      return null;
    }
  }

  /// Create a new user document
  /// 
  /// Creates a new document in the users collection.
  /// 
  /// Process:
  /// 1. Get document reference using user's UID
  /// 2. Convert UserModel to JSON (handles Timestamp conversion)
  /// 3. Set document data (creates new document)
  /// 
  /// [user] - The UserModel to save
  /// Returns: The same UserModel (for method chaining)
  /// 
  /// Note: This will overwrite if document already exists.
  /// Use createOrUpdateUser for safer upsert behavior.
  Future<UserModel> createUser(UserModel user) async {
    // Get document reference - UID is used as document ID
    final userRef = _usersCollection.doc(user.uid);
    // Convert UserModel to JSON and save to Firestore
    // toJson() handles DateTime to Timestamp conversion
    await userRef.set(user.toJson());
    return user;
  }

  /// Update an existing user document
  /// 
  /// Updates an existing document. All fields in the UserModel will be written.
  /// 
  /// Process:
  /// 1. Get document reference
  /// 2. Convert UserModel to JSON
  /// 3. Update document (only works if document exists)
  /// 
  /// [user] - The UserModel with updated data
  /// Returns: The same UserModel
  /// 
  /// Note: This will fail if document doesn't exist.
  /// Use createOrUpdateUser for upsert behavior.
  Future<UserModel> updateUser(UserModel user) async {
    final userRef = _usersCollection.doc(user.uid);
    // update() only works on existing documents
    // It will throw an error if document doesn't exist
    await userRef.update(user.toJson());
    return user;
  }

  /// Create or update user (upsert operation)
  /// 
  /// If document exists, updates it. If not, creates it.
  /// Uses merge option to preserve existing fields not in the update.
  /// 
  /// Process:
  /// 1. Get document reference
  /// 2. Convert UserModel to JSON
  /// 3. Set with merge option (combines with existing data)
  /// 
  /// [user] - The UserModel to create or update
  /// Returns: The same UserModel
  /// 
  /// Merge behavior:
  /// - If document exists: new fields are added, existing fields are updated
  /// - If document doesn't exist: new document is created
  /// - Fields not in UserModel are preserved (if document exists)
  Future<UserModel> createOrUpdateUser(UserModel user) async {
    final userRef = _usersCollection.doc(user.uid);
    // set() with merge: true creates or updates
    // merge: true means existing fields not in user.toJson() are preserved
    await userRef.set(user.toJson(), SetOptions(merge: true));
    return user;
  }

  /// Update specific fields of a user
  /// 
  /// Updates only the specified fields without touching other fields.
  /// More efficient than updateUser when you only need to change a few fields.
  /// 
  /// Process:
  /// 1. Get document reference
  /// 2. Update only specified fields
  /// 
  /// [uid] - The user's UID (document ID)
  /// [fields] - Map of field names to new values
  /// 
  /// Example:
  /// ```dart
  /// await updateUserFields('uid123', {'coupleId': 'couple_456'});
  /// ```
  /// 
  /// Note: This will fail if document doesn't exist.
  /// Only updates the fields specified in the map.
  Future<void> updateUserFields(String uid, Map<String, dynamic> fields) async {
    await _usersCollection.doc(uid).update(fields);
  }

  /// Delete a user document
  /// 
  /// Permanently removes the user's document from Firestore.
  /// 
  /// [uid] - The user's UID (document ID)
  /// 
  /// Warning: This is irreversible. Consider soft-delete (add deleted flag) instead.
  Future<void> deleteUser(String uid) async {
    await _usersCollection.doc(uid).delete();
  }

  /// Stream user data for real-time updates
  /// 
  /// Returns a stream that emits a new UserModel whenever the document changes.
  /// This enables real-time UI updates without polling.
  /// 
  /// Process:
  /// 1. Get document reference
  /// 2. Listen to snapshots (Firestore stream)
  /// 3. Map each snapshot to UserModel (or null if deleted)
  /// 
  /// [uid] - The user's UID to stream
  /// Returns: Stream<UserModel?> that emits on document changes
  /// 
  /// Stream behavior:
  /// - Emits current data immediately when stream is listened to
  /// - Emits new data whenever document is updated in Firestore
  /// - Emits null if document is deleted
  /// - Automatically handles connection issues (reconnects when online)
  /// 
  /// Usage: Perfect for widgets that need to update when user data changes
  /// (e.g., partner's status, couple information, etc.)
  Stream<UserModel?> streamUser(String uid) {
    // snapshots() returns a stream of DocumentSnapshot
    // map() converts each snapshot to UserModel
    return _usersCollection.doc(uid).snapshots().map((doc) {
      // Check if document still exists
      if (!doc.exists) return null;
      // Convert to UserModel
      return UserModel.fromFirestore(doc);
    });
  }

  /// Check if user exists
  /// 
  /// Verifies if a document with the given UID exists in Firestore.
  /// 
  /// [uid] - The user's UID to check
  /// Returns: true if document exists, false otherwise
  /// 
  /// This is a lightweight check - only fetches document metadata, not full data.
  Future<bool> userExists(String uid) async {
    final doc = await _usersCollection.doc(uid).get();
    return doc.exists;
  }
}

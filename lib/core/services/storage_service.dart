import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'storage_service.g.dart';

/// Riverpod provider that creates a singleton StorageService instance
@riverpod
StorageService storageService(StorageServiceRef ref) {
  return StorageService();
}

/// Service for handling Firebase Storage operations
/// 
/// This service provides methods for uploading files (images, videos, etc.)
/// to Firebase Storage and managing file paths.
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload a profile picture to Firebase Storage
  /// 
  /// Uploads an image file to the user's profile pictures folder.
  /// The file path will be: `profile_pictures/{userId}/{timestamp}.jpg`
  /// 
  /// [file] - The image file to upload
  /// [userId] - The user's UID
  /// 
  /// Returns: The download URL of the uploaded image
  /// 
  /// Throws: Exception if upload fails
  Future<String> uploadProfilePicture(File file, String userId) async {
    try {
      // Generate unique filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '$timestamp.jpg';
      final path = 'profile_pictures/$userId/$fileName';

      // Create reference to the file location
      final ref = _storage.ref().child(path);

      // Upload the file
      await ref.putFile(file);

      // Get the download URL
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload profile picture: ${e.toString()}');
    }
  }

  /// Delete a file from Firebase Storage
  /// 
  /// [path] - The storage path of the file to delete
  /// 
  /// Throws: Exception if deletion fails
  Future<void> deleteFile(String path) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete file: ${e.toString()}');
    }
  }

  /// Delete old profile picture if it exists
  /// 
  /// Extracts the storage path from a download URL and deletes the file.
  /// This is useful when replacing a profile picture.
  /// 
  /// [downloadUrl] - The download URL of the file to delete
  /// 
  /// Note: This will silently fail if the file doesn't exist (which is fine)
  Future<void> deleteProfilePicture(String downloadUrl) async {
    try {
      // Extract path from URL
      // URL format: https://firebasestorage.googleapis.com/v0/b/{bucket}/o/{path}?alt=media&token=...
      final uri = Uri.parse(downloadUrl);
      final pathSegments = uri.pathSegments;
      
      // Find the 'o' segment which precedes the actual path
      final oIndex = pathSegments.indexOf('o');
      if (oIndex != -1 && oIndex < pathSegments.length - 1) {
        // Get the path after 'o' and decode it
        final encodedPath = pathSegments[oIndex + 1];
        final path = Uri.decodeComponent(encodedPath);
        
        // Delete the file
        await deleteFile(path);
      }
    } catch (e) {
      // Silently fail - old picture might not exist or URL format might be different
      // This is not critical, we just want to clean up if possible
    }
  }
}

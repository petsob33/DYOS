import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/memory_model.dart';

part 'memory_repository.g.dart';

/// Riverpod provider that creates a singleton MemoryRepository instance
/// This follows the repository pattern for clean architecture
@riverpod
MemoryRepository memoryRepository(MemoryRepositoryRef ref) {
  return MemoryRepository();
}

/// Repository layer for memory operations
/// 
/// This class provides a high-level API for memory operations while hiding
/// the implementation details of Firestore and Firebase Storage.
/// 
/// Architecture pattern:
/// UI/Features → Repository → Firestore/Storage
/// 
/// The repository handles:
/// - Uploading media files to Firebase Storage
/// - Storing memory data in Firestore
/// - Retrieving memories as streams for real-time updates
class MemoryRepository {
  MemoryRepository({FirebaseFirestore? firestore, FirebaseStorage? storage})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  /// Create a new memory with media files
  /// 
  /// This method:
  /// 1. Uploads media files to Firebase Storage
  /// 2. Gets download URLs for uploaded files
  /// 3. Updates the Memory object with the URLs
  /// 4. Saves the Memory to Firestore at couples/{coupleId}/memories/{memoryId}
  /// 
  /// [memory] - The Memory object to create (can have empty id to auto-generate)
  /// [mediaFiles] - List of image/video files to upload
  /// 
  /// Returns: The created Memory object with populated mediaUrls and id
  /// 
  /// Throws: Exception if upload or save fails
  /// 
  /// Storage path format: memories/{coupleId}/{timestamp}_{index}.jpg
  Future<Memory> createMemory({
    required Memory memory,
    required List<File> mediaFiles,
  }) async {
    try {
      // Validate inputs
      if (memory.pairId.isEmpty) {
        throw Exception('pairId cannot be empty');
      }

      // Generate memory ID if not provided
      final memoryId = memory.id.isEmpty
          ? _firestore.collection('couples').doc().id
          : memory.id;

      final List<String> downloadUrls = [];

      // Upload each media file to Firebase Storage
      if (mediaFiles.isNotEmpty) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        
        for (int i = 0; i < mediaFiles.length; i++) {
          final file = mediaFiles[i];
          
          // Determine file extension from file path
          final extension = file.path.split('.').last.toLowerCase();
          final storagePath = 'memories/${memory.pairId}/${timestamp}_$i.$extension';
          
          // Determine content type based on extension
          String? contentType;
          if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
            contentType = 'image/$extension';
            if (extension == 'jpg') contentType = 'image/jpeg';
          } else if (['mp4', 'mov', 'avi', 'mkv'].contains(extension)) {
            contentType = 'video/$extension';
            if (extension == 'mov') contentType = 'video/quicktime';
            else if (extension == 'mkv') contentType = 'video/x-matroska';
          }
          
          // Create reference and upload file with metadata
          final storageRef = _storage.ref().child(storagePath);
          final metadata = contentType != null
              ? SettableMetadata(contentType: contentType)
              : null;
          
          try {
            await storageRef.putFile(file, metadata);
            
            // Get download URL
            final downloadUrl = await storageRef.getDownloadURL();
            downloadUrls.add(downloadUrl);
          } catch (e) {
            // Re-throw with more context
            throw Exception('Failed to upload file ${i + 1}/${mediaFiles.length}: $e');
          }
        }
      }

      // Update memory with download URLs, ID, and createdAt
      final memoryWithUrls = memory.copyWith(
        id: memoryId,
        mediaUrls: downloadUrls,
        createdAt: DateTime.now(),
      );

      // Save to Firestore
      // Path: couples/{coupleId}/memories/{memoryId}
      final memoryRef = _firestore
          .collection('couples')
          .doc(memory.pairId)
          .collection('memories')
          .doc(memoryId);

      // Convert memory to JSON and save
      final memoryJson = memoryWithUrls.toJson();
      
      try {
        await memoryRef.set(memoryJson);
      } catch (firestoreError) {
        // Re-throw with more context about what was being saved
        throw Exception('Failed to save memory to Firestore at couples/${memory.pairId}/memories/$memoryId: $firestoreError. Memory data: ${memoryJson.keys.join(", ")}');
      }

      return memoryWithUrls;
    } catch (e) {
      // Re-throw with additional context if it's not already wrapped
      if (e.toString().contains('Failed to')) {
        rethrow;
      }
      throw Exception('Failed to create memory: ${e.toString()}');
    }
  }

  /// Get memories stream for a couple
  /// 
  /// Returns a stream of memories ordered by date descending.
  /// The stream automatically updates when memories are added, updated, or deleted.
  /// 
  /// [coupleId] - The ID of the couple to get memories for
  /// [category] - Optional category to filter memories by
  /// 
  /// Returns: Stream<List<Memory>> ordered by date descending
  Stream<List<Memory>> getMemories(String coupleId, {MemoryCategory? category}) {
    if (coupleId.isEmpty) {
      return Stream.value([]);
    }
    
    Query query = _firestore
        .collection('couples')
        .doc(coupleId)
        .collection('memories');
        
    if (category != null) {
      query = query.where('category', isEqualTo: category.name);
    }
    
    return query.snapshots().map((snapshot) {
      final memories = _parseMemories(snapshot.docs);
      memories.sort((a, b) => b.date.compareTo(a.date));
      return memories;
    });
  }

  /// Update an existing memory (caption, date, category, location only; media unchanged).
  Future<Memory> updateMemory(Memory memory) async {
    if (memory.pairId.isEmpty || memory.id.isEmpty) {
      throw Exception('pairId and id cannot be empty');
    }
    final memoryRef = _firestore
        .collection('couples')
        .doc(memory.pairId)
        .collection('memories')
        .doc(memory.id);
    final updateJson = memory.toJson();
    await memoryRef.update(updateJson);
    return memory;
  }

  /// Delete a memory from Firestore (and optionally its media from Storage).
  Future<void> deleteMemory(Memory memory) async {
    if (memory.pairId.isEmpty || memory.id.isEmpty) {
      throw Exception('pairId and id cannot be empty');
    }
    final memoryRef = _firestore
        .collection('couples')
        .doc(memory.pairId)
        .collection('memories')
        .doc(memory.id);
    await memoryRef.delete();
  }

  /// Helper method to parse memory documents
  List<Memory> _parseMemories(List<QueryDocumentSnapshot> docs) {
    return docs.map((doc) {
      try {
        return Memory.fromFirestore(doc);
      } catch (e, stackTrace) {
        // Skip invalid documents
        return null;
      }
    }).where((memory) => memory != null).cast<Memory>().toList();
  }
}

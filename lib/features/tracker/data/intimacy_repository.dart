import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/intimacy_log_model.dart';

part 'intimacy_repository.g.dart';

/// Riverpod provider that creates a singleton IntimacyRepository instance
/// This follows the repository pattern for clean architecture
@riverpod
IntimacyRepository intimacyRepository(IntimacyRepositoryRef ref) {
  return IntimacyRepository();
}

/// Repository layer for intimacy log operations
/// 
/// This class provides a high-level API for intimacy log operations while hiding
/// the implementation details of Firestore.
/// 
/// Architecture pattern:
/// UI/Features → Repository → Firestore
/// 
/// The repository handles:
/// - Adding intimacy logs to Firestore
/// - Retrieving logs as streams for real-time updates
/// - Deleting logs
class IntimacyRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Add a new intimacy log
  /// 
  /// Saves the intimacy log to Firestore at couples/{coupleId}/intimacy_logs/{logId}
  /// 
  /// [log] - The IntimacyLog object to add (id can be empty to auto-generate)
  /// [coupleId] - The ID of the couple this log belongs to
  /// 
  /// Returns: The created IntimacyLog object with populated id
  /// 
  /// Throws: Exception if save fails
  Future<IntimacyLog> addLog(IntimacyLog log, String coupleId) async {
    try {
      if (coupleId.isEmpty) {
        throw Exception('coupleId cannot be empty');
      }

      // Generate log ID if not provided
      final logId = log.id.isEmpty
          ? _firestore
              .collection('couples')
              .doc(coupleId)
              .collection('intimacy_logs')
              .doc()
              .id
          : log.id;

      // Prepare log with ID
      final logWithId = log.copyWith(id: logId);

      // Save to Firestore
      // Path: couples/{coupleId}/intimacy_logs/{logId}
      final logRef = _firestore
          .collection('couples')
          .doc(coupleId)
          .collection('intimacy_logs')
          .doc(logId);

      // Convert log to JSON and save
      final logJson = logWithId.toJson();
      await logRef.set(logJson);

      return logWithId;
    } catch (e) {
      throw Exception('Failed to add intimacy log: ${e.toString()}');
    }
  }

  /// Watch intimacy logs for a couple
  /// 
  /// Returns a stream of intimacy logs ordered by date descending.
  /// The stream automatically updates when logs are added, updated, or deleted.
  /// 
  /// [coupleId] - The ID of the couple to get logs for
  /// 
  /// Returns: Stream of List of IntimacyLog ordered by date descending
  Stream<List<IntimacyLog>> watchLogs(String coupleId) {
    if (coupleId.isEmpty) {
      return Stream.value([]);
    }

    return _firestore
        .collection('couples')
        .doc(coupleId)
        .collection('intimacy_logs')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      final logs = _parseLogs(snapshot.docs);
      // Ensure sorted by date descending (already sorted by query, but ensure it)
      logs.sort((a, b) => b.date.compareTo(a.date));
      return logs;
    });
  }

  /// Update an existing intimacy log
  /// 
  /// Updates the intimacy log in Firestore.
  /// 
  /// [log] - The IntimacyLog object with updated data (must have valid id)
  /// [coupleId] - The ID of the couple this log belongs to
  /// 
  /// Returns: The updated IntimacyLog object
  /// 
  /// Throws: Exception if update fails
  Future<IntimacyLog> updateLog(IntimacyLog log, String coupleId) async {
    try {
      if (coupleId.isEmpty) {
        throw Exception('coupleId cannot be empty');
      }
      if (log.id.isEmpty) {
        throw Exception('log id cannot be empty');
      }

      // Convert log to JSON and update
      final logJson = log.toJson();
      await _firestore
          .collection('couples')
          .doc(coupleId)
          .collection('intimacy_logs')
          .doc(log.id)
          .update(logJson);

      return log;
    } catch (e) {
      throw Exception('Failed to update intimacy log: ${e.toString()}');
    }
  }

  /// Delete an intimacy log
  /// 
  /// Permanently removes the log from Firestore.
  /// 
  /// [logId] - The ID of the log to delete
  /// [coupleId] - The ID of the couple this log belongs to
  /// 
  /// Throws: Exception if deletion fails
  Future<void> deleteLog(String logId, String coupleId) async {
    try {
      if (coupleId.isEmpty) {
        throw Exception('coupleId cannot be empty');
      }
      if (logId.isEmpty) {
        throw Exception('logId cannot be empty');
      }

      await _firestore
          .collection('couples')
          .doc(coupleId)
          .collection('intimacy_logs')
          .doc(logId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete intimacy log: ${e.toString()}');
    }
  }

  /// Helper method to parse log documents
  List<IntimacyLog> _parseLogs(List<QueryDocumentSnapshot> docs) {
    return docs.map((doc) {
      try {
        return IntimacyLog.fromFirestore(doc);
      } catch (e) {
        // Skip invalid documents
        return null;
      }
    }).where((log) => log != null).cast<IntimacyLog>().toList();
  }
}

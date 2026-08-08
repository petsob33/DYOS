import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/firebase/firestore_parsing.dart';
import '../domain/cycle_log_model.dart';
import '../domain/cycle_settings_model.dart';

part 'cycle_repository.g.dart';

/// Riverpod provider that creates a singleton CycleRepository instance
/// This follows the repository pattern for clean architecture
@riverpod
CycleRepository cycleRepository(CycleRepositoryRef ref) {
  return CycleRepository();
}

/// Repository layer for cycle log and settings operations
/// 
/// This class provides a high-level API for cycle operations while hiding
/// the implementation details of Firestore.
/// 
/// Architecture pattern:
/// UI/Features → Repository → Firestore
/// 
/// The repository handles:
/// - Adding/updating cycle logs
/// - Retrieving logs as streams for real-time updates
/// - Deleting logs
/// - Getting/updating cycle settings
class CycleRepository {
  CycleRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Add or update a cycle log entry
  /// 
  /// Saves the cycle log to Firestore at couples/{coupleId}/cycle_logs/{logId}
  /// 
  /// [log] - The CycleLog object to add/update (id can be empty to auto-generate)
  /// [coupleId] - The ID of the couple this log belongs to
  /// 
  /// Returns: The created/updated CycleLog object with populated id
  /// 
  /// Throws: Exception if save fails
  Future<CycleLog> addOrUpdateLog(CycleLog log, String coupleId) async {
    try {
      if (coupleId.isEmpty) {
        throw Exception('coupleId cannot be empty');
      }

      // Generate log ID if not provided
      final logId = log.id.isEmpty
          ? _firestore
              .collection('couples')
              .doc(coupleId)
              .collection('cycle_logs')
              .doc()
              .id
          : log.id;

      // Prepare log with ID
      final logWithId = log.copyWith(id: logId);

      // Save to Firestore
      // Path: couples/{coupleId}/cycle_logs/{logId}
      final logRef = _firestore
          .collection('couples')
          .doc(coupleId)
          .collection('cycle_logs')
          .doc(logId);

      // Convert log to JSON and save
      final logJson = logWithId.toJson();
      await logRef.set(logJson);

      return logWithId;
    } catch (e) {
      throw Exception('Failed to add/update cycle log: ${e.toString()}');
    }
  }

  /// Watch cycle logs for a couple
  /// 
  /// Returns a stream of cycle logs ordered by date descending.
  /// The stream automatically updates when logs are added, updated, or deleted.
  /// 
  /// [coupleId] - The ID of the couple to get logs for
  /// 
  /// Returns: Stream of List of CycleLog ordered by date descending
  Stream<List<CycleLog>> watchLogs(String coupleId) {
    if (coupleId.isEmpty) {
      return Stream.value([]);
    }

    return _firestore
        .collection('couples')
        .doc(coupleId)
        .collection('cycle_logs')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      final logs = _parseLogs(snapshot.docs);
      // Ensure sorted by date descending (already sorted by query, but ensure it)
      logs.sort((a, b) => b.date.compareTo(a.date));
      return logs;
    });
  }

  /// Delete a cycle log entry
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
          .collection('cycle_logs')
          .doc(logId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete cycle log: ${e.toString()}');
    }
  }

  /// Get cycle settings for a couple
  /// 
  /// [coupleId] - The ID of the couple to get settings for
  /// 
  /// Returns: CycleSettings or null if not found
  /// 
  /// Throws: Exception if retrieval fails
  Future<CycleSettings?> getSettings(String coupleId) async {
    try {
      if (coupleId.isEmpty) {
        throw Exception('coupleId cannot be empty');
      }

      final doc = await _firestore
          .collection('couples')
          .doc(coupleId)
          .collection('cycle_settings')
          .doc('settings')
          .get();

      if (!doc.exists) {
        return null;
      }

      return CycleSettings.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get cycle settings: ${e.toString()}');
    }
  }

  /// Update cycle settings for a couple
  /// 
  /// [settings] - The CycleSettings object to save (id can be empty to use default)
  /// [coupleId] - The ID of the couple these settings belong to
  /// 
  /// Returns: The saved CycleSettings object with populated id
  /// 
  /// Throws: Exception if save fails
  Future<CycleSettings> updateSettings(
      CycleSettings settings, String coupleId) async {
    try {
      if (coupleId.isEmpty) {
        throw Exception('coupleId cannot be empty');
      }

      // Use 'settings' as the document ID
      final settingsId = settings.id.isEmpty ? 'settings' : settings.id;
      final settingsWithId = settings.copyWith(id: settingsId);

      // Save to Firestore
      // Path: couples/{coupleId}/cycle_settings/settings
      final settingsRef = _firestore
          .collection('couples')
          .doc(coupleId)
          .collection('cycle_settings')
          .doc(settingsId);

      // Convert settings to JSON and save
      final settingsJson = settingsWithId.toJson();
      await settingsRef.set(settingsJson);

      return settingsWithId;
    } catch (e) {
      throw Exception('Failed to update cycle settings: ${e.toString()}');
    }
  }

  /// Watch cycle settings for a couple
  /// 
  /// Returns a stream of cycle settings that updates in real-time.
  /// 
  /// [coupleId] - The ID of the couple to watch settings for
  /// 
  /// Returns: Stream of CycleSettings or null
  Stream<CycleSettings?> watchSettings(String coupleId) {
    if (coupleId.isEmpty) {
      return Stream.value(null);
    }

    return _firestore
        .collection('couples')
        .doc(coupleId)
        .collection('cycle_settings')
        .doc('settings')
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }
      return CycleSettings.fromFirestore(snapshot);
    });
  }

  /// Helper method to parse log documents
  List<CycleLog> _parseLogs(List<QueryDocumentSnapshot> docs) {
    return parseFirestoreDocs(docs, CycleLog.fromFirestore);
  }
}
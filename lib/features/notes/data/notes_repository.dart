import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/firebase/firestore_parsing.dart';
import '../domain/note_item.dart';

part 'notes_repository.g.dart';

/// Riverpod provider that creates a singleton NotesRepository instance
@riverpod
NotesRepository notesRepository(NotesRepositoryRef ref) {
  return NotesRepository();
}

/// Repository layer for note operations
/// 
/// This class provides a high-level API for note operations while hiding
/// the implementation details of Firestore.
/// 
/// Architecture pattern:
/// UI/Features → Repository → Firestore
/// 
/// The repository handles:
/// - Creating notes in Firestore
/// - Retrieving notes as streams for real-time updates
/// - Filtering notes by type
class NotesRepository {
  NotesRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Create a new note
  /// 
  /// [note] - The NoteItem object to create (can have empty id to auto-generate)
  /// [coupleId] - The ID of the couple this note belongs to
  /// 
  /// Returns: The created NoteItem object with populated id and createdAt
  /// 
  /// Throws: Exception if save fails
  /// 
  /// Storage path format: couples/{coupleId}/notes/{noteId}
  Future<NoteItem> createNote({
    required NoteItem note,
    required String coupleId,
  }) async {
    try {
      if (coupleId.isEmpty) {
        throw Exception('coupleId cannot be empty');
      }

      // Generate note ID if not provided
      final noteId = note.id.isEmpty
          ? _firestore.collection('couples').doc().id
          : note.id;

      // Update note with ID and createdAt
      final noteWithId = note.copyWith(
        id: noteId,
        createdAt: DateTime.now(),
      );

      // Save to Firestore
      // Path: couples/{coupleId}/notes/{noteId}
      final noteRef = _firestore
          .collection('couples')
          .doc(coupleId)
          .collection('notes')
          .doc(noteId);

      // Convert note to JSON and save
      final noteJson = noteWithId.toJson();
      
      try {
        await noteRef.set(noteJson);
      } catch (firestoreError) {
        throw Exception('Failed to save note to Firestore at couples/$coupleId/notes/$noteId: $firestoreError');
      }

      return noteWithId;
    } catch (e) {
      throw Exception('Failed to create note: ${e.toString()}');
    }
  }

  /// Get notes stream for a couple
  ///
  /// Returns a stream of notes ordered by createdAt descending.
  /// The stream automatically updates when notes are added, updated, or deleted.
  ///
  /// [coupleId] - The ID of the couple to get notes for
  /// [type] - Optional type to filter notes by
  /// [requestingUserId] - Required when [type] is `private` or `secretGift`.
  /// Firestore rules only allow the author to list those note types, and the
  /// `list` rule can't verify an unconstrained `authorId` field against a
  /// query that only filters by `type` - so the query itself must also
  /// filter by authorId or the read is denied server-side.
  ///
  /// Returns: Stream<List<NoteItem>> ordered by createdAt descending
  Stream<List<NoteItem>> getNotes(
    String coupleId, {
    NoteType? type,
    String? requestingUserId,
  }) {
    if (coupleId.isEmpty) {
      return Stream.value([]);
    }

    Query query = _firestore
        .collection('couples')
        .doc(coupleId)
        .collection('notes');

    if (type != null) {
      query = query.where('type', isEqualTo: type.name);
    }

    if (type == NoteType.private || type == NoteType.secretGift) {
      assert(
        requestingUserId != null && requestingUserId.isNotEmpty,
        'requestingUserId is required when querying private/secretGift notes',
      );
      query = query.where('authorId', isEqualTo: requestingUserId);
    }

    // If filtering by type, we can't use orderBy with where on different fields
    // So we'll sort in memory instead
    return query.snapshots().map((snapshot) {
      final notes = _parseNotes(snapshot.docs);
      // Sort by createdAt descending
      notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return notes;
    });
  }

  /// Get the latest shared note for a couple (for QuickNoteCard)
  ///
  /// Returns the most recent shared note, or null if none exists
  Stream<NoteItem?> getLatestSharedNote(String coupleId) {
    if (coupleId.isEmpty) {
      return Stream.value(null);
    }

    // Bounded to the single newest doc via orderBy+limit - requires the
    // composite index on (type, createdAt) declared in firestore.indexes.json.
    return _firestore
        .collection('couples')
        .doc(coupleId)
        .collection('notes')
        .where('type', isEqualTo: NoteType.shared.name)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return null;
      }
      try {
        return NoteItem.fromFirestore(snapshot.docs.first);
      } catch (e) {
        return null;
      }
    });
  }

  /// Helper method to parse note documents
  List<NoteItem> _parseNotes(List<QueryDocumentSnapshot> docs) {
    return parseFirestoreDocs(docs, NoteItem.fromFirestore);
  }

  /// Get notes filtered by type
  Future<List<NoteItem>> getNotesByType(String coupleId, NoteType type) async {
    final notesStream = getNotes(coupleId, type: type);
    return await notesStream.first;
  }

  /// Get a single note by ID
  Future<NoteItem?> getNoteById(String coupleId, String noteId) async {
    try {
      final doc = await _firestore
          .collection('couples')
          .doc(coupleId)
          .collection('notes')
          .doc(noteId)
          .get();
      
      if (!doc.exists) {
        return null;
      }
      
      return NoteItem.fromFirestore(doc);
    } catch (e) {
      return null;
    }
  }
}

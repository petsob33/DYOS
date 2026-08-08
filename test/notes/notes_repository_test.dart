import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ouros_app/features/notes/data/notes_repository.dart';
import 'package:ouros_app/features/notes/domain/note_item.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late NotesRepository repository;
  const coupleId = 'couple_1';

  Future<void> addNote({
    required String content,
    required NoteType type,
    required DateTime createdAt,
    String authorId = 'user_1',
  }) async {
    final ref = firestore
        .collection('couples')
        .doc(coupleId)
        .collection('notes')
        .doc();
    // Mirrors NotesRepository.createNote, which writes 'id' into the
    // document body alongside the doc ID.
    await ref.set({
      'id': ref.id,
      'content': content,
      'title': null,
      'createdAt': createdAt,
      'type': type.name,
      'authorId': authorId,
    });
  }

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = NotesRepository(firestore: firestore);
  });

  group('NotesRepository.getLatestSharedNote', () {
    test('returns null when there are no shared notes', () async {
      final note = await repository.getLatestSharedNote(coupleId).first;
      expect(note, isNull);
    });

    test('returns the most recently created shared note', () async {
      await addNote(
        content: 'older',
        type: NoteType.shared,
        createdAt: DateTime(2026, 1, 10),
      );
      await addNote(
        content: 'newest',
        type: NoteType.shared,
        createdAt: DateTime(2026, 6, 10),
      );
      await addNote(
        content: 'middle',
        type: NoteType.shared,
        createdAt: DateTime(2026, 3, 10),
      );

      final note = await repository.getLatestSharedNote(coupleId).first;

      expect(note?.content, 'newest');
    });

    test('ignores notes of other types', () async {
      await addNote(
        content: 'private note',
        type: NoteType.private,
        createdAt: DateTime(2026, 6, 10),
      );

      final note = await repository.getLatestSharedNote(coupleId).first;

      expect(note, isNull);
    });

    test('returns null for an empty coupleId', () async {
      final note = await repository.getLatestSharedNote('').first;
      expect(note, isNull);
    });
  });
}

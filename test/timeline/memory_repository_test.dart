import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:ouros_app/features/timeline/data/memory_repository.dart';
import 'package:ouros_app/features/timeline/domain/memory_model.dart';

// No storage calls happen in these tests (mediaFiles is always empty, and
// createMemory skips all upload logic in that case) - this stands in only
// so MemoryRepository's constructor doesn't reach for the real
// FirebaseStorage.instance, which requires a real Firebase app.
class MockFirebaseStorage extends Mock implements FirebaseStorage {}

void main() {
  late FakeFirebaseFirestore firestore;
  late MemoryRepository repository;
  const coupleId = 'couple_1';

  Memory buildMemory({
    String id = '',
    String caption = 'A lovely day',
    MemoryCategory category = MemoryCategory.dateNight,
    DateTime? date,
  }) {
    final when = date ?? DateTime(2026, 1, 1);
    return Memory(
      id: id,
      pairId: coupleId,
      authorId: 'user_1',
      caption: caption,
      date: when,
      category: category,
      createdAt: when,
    );
  }

  setUp(() {
    firestore = FakeFirebaseFirestore();
    // Storage is not exercised here: createMemory skips all upload logic
    // when mediaFiles is empty, so these are pure Firestore CRUD tests.
    repository = MemoryRepository(firestore: firestore, storage: MockFirebaseStorage());
  });

  group('MemoryRepository.createMemory', () {
    test('creates a memory without media and generates an id', () async {
      final created = await repository.createMemory(
        memory: buildMemory(),
        mediaFiles: [],
      );

      expect(created.id, isNotEmpty);
      expect(created.mediaUrls, isEmpty);

      final doc = await firestore
          .collection('couples')
          .doc(coupleId)
          .collection('memories')
          .doc(created.id)
          .get();
      expect(doc.exists, true);
      expect(doc.data()?['caption'], 'A lovely day');
    });

    test('throws when pairId is empty', () async {
      expect(
        () => repository.createMemory(
          memory: buildMemory().copyWith(pairId: ''),
          mediaFiles: [],
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('MemoryRepository.getMemories', () {
    test('streams memories for a couple ordered by date descending', () async {
      await repository.createMemory(
        memory: buildMemory(caption: 'Older', date: DateTime(2026, 1, 1)),
        mediaFiles: [],
      );
      await repository.createMemory(
        memory: buildMemory(caption: 'Newer', date: DateTime(2026, 2, 1)),
        mediaFiles: [],
      );

      final memories = await repository.getMemories(coupleId).first;

      expect(memories.map((m) => m.caption), ['Newer', 'Older']);
    });

    test('filters by category when provided', () async {
      await repository.createMemory(
        memory: buildMemory(caption: 'Trip memory', category: MemoryCategory.trip),
        mediaFiles: [],
      );
      await repository.createMemory(
        memory: buildMemory(caption: 'Food memory', category: MemoryCategory.food),
        mediaFiles: [],
      );

      final tripMemories =
          await repository.getMemories(coupleId, category: MemoryCategory.trip).first;

      expect(tripMemories.map((m) => m.caption), ['Trip memory']);
    });

    test('returns an empty stream for an empty coupleId', () async {
      final memories = await repository.getMemories('').first;
      expect(memories, isEmpty);
    });
  });

  group('MemoryRepository pagination (getRecentMemoriesFeed / getOlderMemories)', () {
    test('getRecentMemoriesFeed bounds to the newest [limit] memories', () async {
      for (var i = 0; i < 5; i++) {
        await repository.createMemory(
          memory: buildMemory(caption: 'Memory $i', date: DateTime(2026, 1, i + 1)),
          mediaFiles: [],
        );
      }

      final feed = await repository.getRecentMemoriesFeed(coupleId, limit: 3).first;

      expect(feed.map((m) => m.caption), ['Memory 4', 'Memory 3', 'Memory 2']);
    });

    test('getOlderMemories fetches the page before a given date', () async {
      for (var i = 0; i < 5; i++) {
        await repository.createMemory(
          memory: buildMemory(caption: 'Memory $i', date: DateTime(2026, 1, i + 1)),
          mediaFiles: [],
        );
      }

      final recent = await repository.getRecentMemoriesFeed(coupleId, limit: 3).first;
      final older = await repository.getOlderMemories(
        coupleId,
        before: recent.last.date,
        limit: 50,
      );

      expect(older.map((m) => m.caption), ['Memory 1', 'Memory 0']);
    });

    test('getOlderMemories returns nothing past the oldest memory', () async {
      await repository.createMemory(
        memory: buildMemory(date: DateTime(2026, 1, 1)),
        mediaFiles: [],
      );

      final older = await repository.getOlderMemories(
        coupleId,
        before: DateTime(2026, 1, 1),
      );

      expect(older, isEmpty);
    });
  });

  group('MemoryRepository.updateMemory', () {
    test('updates caption and category, leaving media untouched', () async {
      final created = await repository.createMemory(
        memory: buildMemory(caption: 'Original'),
        mediaFiles: [],
      );

      final updated = await repository.updateMemory(
        created.copyWith(caption: 'Edited', category: MemoryCategory.funny),
      );

      expect(updated.caption, 'Edited');
      final doc = await firestore
          .collection('couples')
          .doc(coupleId)
          .collection('memories')
          .doc(created.id)
          .get();
      expect(doc.data()?['caption'], 'Edited');
      expect(doc.data()?['category'], 'funny');
    });

    test('throws when id is empty', () async {
      expect(
        () => repository.updateMemory(buildMemory(id: '')),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('MemoryRepository.deleteMemory', () {
    test('deletes an existing memory', () async {
      final created = await repository.createMemory(
        memory: buildMemory(),
        mediaFiles: [],
      );

      await repository.deleteMemory(created);

      final doc = await firestore
          .collection('couples')
          .doc(coupleId)
          .collection('memories')
          .doc(created.id)
          .get();
      expect(doc.exists, false);
    });

    test('throws when pairId is empty', () async {
      expect(
        () => repository.deleteMemory(buildMemory().copyWith(pairId: '')),
        throwsA(isA<Exception>()),
      );
    });
  });
}

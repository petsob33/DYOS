import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/presentation/auth_providers.dart';
import '../domain/note_item.dart';
import '../data/notes_repository.dart';

part 'notes_provider.g.dart';

/// Provider for the latest shared note (for QuickNoteCard)
@riverpod
Stream<NoteItem?> latestSharedNote(LatestSharedNoteRef ref) {
  final coupleAsync = ref.watch(currentCoupleProvider);
  final couple = coupleAsync.valueOrNull;
  
  if (couple?.id == null || couple!.id.isEmpty) {
    return Stream.value(null);
  }
  
  final repository = ref.watch(notesRepositoryProvider);
  return repository.getLatestSharedNote(couple.id);
}

/// Provider for all notes of a couple
@riverpod
Stream<List<NoteItem>> coupleNotes(CoupleNotesRef ref, {NoteType? type}) {
  final coupleAsync = ref.watch(currentCoupleProvider);
  final couple = coupleAsync.valueOrNull;

  if (couple?.id == null || couple!.id.isEmpty) {
    return Stream.value([]);
  }

  final repository = ref.watch(notesRepositoryProvider);
  final currentUserId = ref.watch(currentUserProvider)?.uid;
  return repository.getNotes(
    couple.id,
    type: type,
    requestingUserId: currentUserId,
  );
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/chat_history_repository.dart';
import '../domain/chat_event.dart';

final chatHistoryRepositoryProvider = Provider<ChatHistoryRepository>((ref) {
  return ChatHistoryRepository(firestore: FirebaseFirestore.instance);
});

/// Live, newest-first merge of the couple's quick messages and haptic
/// touches, keyed by coupleId.
final chatHistoryProvider =
    StreamProvider.autoDispose.family<List<ChatEvent>, String>((ref, coupleId) {
  final repository = ref.watch(chatHistoryRepositoryProvider);
  return repository.watchHistory(coupleId);
});

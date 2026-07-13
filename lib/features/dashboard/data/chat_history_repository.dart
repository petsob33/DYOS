import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/chat_event.dart';

/// Reads the couple's full quick-message + haptic-touch history, merged
/// into one chronological (newest-first) timeline.
class ChatHistoryRepository {
  ChatHistoryRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  static const _historyLimit = 200;

  /// Live-updating, newest-first merge of quick_messages and haptic_signals
  /// for [coupleId]. Both source collections are queried independently and
  /// recombined whenever either one changes.
  Stream<List<ChatEvent>> watchHistory(String coupleId) {
    final controller = StreamController<List<ChatEvent>>.broadcast();
    List<ChatEvent>? latestMessages;
    List<ChatEvent>? latestTouches;

    void emitCombined() {
      if (latestMessages == null || latestTouches == null) return;
      final combined = [...latestMessages!, ...latestTouches!]
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      controller.add(combined);
    }

    final messagesSub = _firestore
        .collection('couples')
        .doc(coupleId)
        .collection('quick_messages')
        .orderBy('timestamp', descending: true)
        .limit(_historyLimit)
        .snapshots()
        .listen(
          (snapshot) {
            latestMessages = snapshot.docs
                .map(ChatEvent.fromQuickMessageDoc)
                .toList();
            emitCombined();
          },
          onError: controller.addError,
        );

    final touchesSub = _firestore
        .collection('couples')
        .doc(coupleId)
        .collection('haptic_signals')
        .orderBy('timestamp', descending: true)
        .limit(_historyLimit)
        .snapshots()
        .listen(
          (snapshot) {
            latestTouches = snapshot.docs
                .map(ChatEvent.fromHapticTouchDoc)
                .toList();
            emitCombined();
          },
          onError: controller.addError,
        );

    controller.onCancel = () async {
      await messagesSub.cancel();
      await touchesSub.cancel();
    };

    return controller.stream;
  }
}

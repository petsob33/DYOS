import 'package:cloud_firestore/cloud_firestore.dart';

enum ChatEventType { quickMessage, hapticTouch }

/// A single item in the couple's chat history: either a quick message or a
/// haptic touch, merged into one chronological timeline.
class ChatEvent {
  const ChatEvent({
    required this.id,
    required this.type,
    required this.fromUserId,
    required this.timestamp,
    this.message,
    this.durationMs,
  });

  final String id;
  final ChatEventType type;
  final String fromUserId;
  final DateTime timestamp;

  /// Set when [type] is [ChatEventType.quickMessage].
  final String? message;

  /// Set when [type] is [ChatEventType.hapticTouch].
  final int? durationMs;

  factory ChatEvent.fromQuickMessageDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return ChatEvent(
      id: doc.id,
      type: ChatEventType.quickMessage,
      fromUserId: data['fromUserId'] as String? ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      message: data['message'] as String? ?? '',
    );
  }

  factory ChatEvent.fromHapticTouchDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return ChatEvent(
      id: doc.id,
      type: ChatEventType.hapticTouch,
      fromUserId: data['fromUserId'] as String? ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      durationMs: data['durationMs'] as int? ?? 200,
    );
  }
}

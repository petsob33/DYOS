import 'package:cloud_firestore/cloud_firestore.dart';

class CoupleNotificationService {
  CoupleNotificationService({required FirebaseFirestore firestore}) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  Future<void> updateStatus({
    required String coupleId,
    required String userId,
    required String emoji,
    required String text,
  }) async {
    await _firestore.collection('couples').doc(coupleId).update({
      'status.$userId': {
        'emoji': emoji,
        'text': text,
        'updatedAt': Timestamp.now(),
      },
    });
  }

  Future<void> sendHapticTouch({
    required String coupleId,
    required String fromUserId,
    required int durationMs,
  }) async {
    await _firestore
        .collection('couples')
        .doc(coupleId)
        .collection('haptic_signals')
        .doc()
        .set({
      'fromUserId': fromUserId,
      'durationMs': durationMs,
      'timestamp': Timestamp.now(),
      'read': false,
    });
  }

  Future<void> sendQuickMessage({
    required String coupleId,
    required String fromUserId,
    required String message,
  }) async {
    await _firestore
        .collection('couples')
        .doc(coupleId)
        .collection('quick_messages')
        .doc()
        .set({
      'fromUserId': fromUserId,
      'message': message,
      'timestamp': Timestamp.now(),
      'read': false,
    });
  }
}

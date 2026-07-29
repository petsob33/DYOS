import 'package:cloud_firestore/cloud_firestore.dart';

/// A single "heart" sent from one partner to the other via [TapticTouchCard].
class HapticSignal {
  const HapticSignal({required this.fromUserId, required this.timestamp});

  final String fromUserId;
  final DateTime timestamp;

  factory HapticSignal.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HapticSignal(
      fromUserId: data['fromUserId'] as String? ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
}

import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/presentation/auth_providers.dart';

part 'haptic_listener_provider.g.dart';

/// Provider that listens for haptic signals from partner
@riverpod
Stream<DateTime?> hapticSignalsStream(HapticSignalsStreamRef ref) {
  final userAsync = ref.watch(userProvider);
  final user = userAsync.valueOrNull;

  if (user == null || user.coupleId == null || user.coupleId!.isEmpty) {
    return Stream.value(null);
  }

  final firestore = FirebaseFirestore.instance;
  return firestore
      .collection('couples')
      .doc(user.coupleId!)
      .collection('haptic_signals')
      .where('read', isEqualTo: false)
      .orderBy('timestamp', descending: true)
      .limit(1)
      .snapshots(includeMetadataChanges: false)
      .asyncMap((snapshot) async {
    if (snapshot.docs.isNotEmpty) {
      final signal = snapshot.docs.first;
      final data = signal.data();
      final fromUserId = data['fromUserId'] as String? ?? '';
      
      // Only process signals from partner (not from current user)
      if (fromUserId != user.uid) {
        final durationMs = data['durationMs'] as int? ?? 200;
        
        // Trigger haptic feedback
        HapticFeedback.mediumImpact();
        
        // Mark as read (async to avoid blocking)
        signal.reference.update({'read': true}).catchError((e) {
          print('ERROR marking haptic signal as read: $e');
        });
        
        // Return timestamp to trigger notification
        return DateTime.now();
      }
    }
    return null;
  });
}

/// Provider that listens for quick messages from partner
@riverpod
Stream<Map<String, dynamic>?> quickMessagesStream(QuickMessagesStreamRef ref) {
  final userAsync = ref.watch(userProvider);
  final user = userAsync.valueOrNull;

  if (user == null || user.coupleId == null || user.coupleId!.isEmpty) {
    return Stream.value(null);
  }

  final firestore = FirebaseFirestore.instance;
  return firestore
      .collection('couples')
      .doc(user.coupleId!)
      .collection('quick_messages')
      .where('read', isEqualTo: false)
      .orderBy('timestamp', descending: true)
      .limit(1)
      .snapshots(includeMetadataChanges: false)
      .map((snapshot) {
    if (snapshot.docs.isNotEmpty) {
      final message = snapshot.docs.first;
      final data = message.data();
      final fromUserId = data['fromUserId'] as String? ?? '';
      
      // Only process messages from partner (not from current user)
      if (fromUserId != user.uid) {
        // Mark as read
        message.reference.update({'read': true});
        
        return {
          'message': data['message'] as String? ?? '',
          'timestamp': data['timestamp'] as Timestamp?,
        };
      }
    }
    return null;
  });
}

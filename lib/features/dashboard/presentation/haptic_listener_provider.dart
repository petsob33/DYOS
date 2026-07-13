import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/presentation/auth_providers.dart';

part 'haptic_listener_provider.g.dart';

/// Picks the most recent unread signal/message from the partner out of
/// [docs] and marks every unread one from the partner as read (so backlog
/// doesn't linger and get replayed on the next reconnect). Returns null if
/// [isBacklogSnapshot] is true - those documents were already unread the
/// moment the listener (re)subscribed (e.g. every cold start, since a
/// document is only ever marked read by a client that's actively
/// subscribed), so replaying a buzz/notification for them would fire on
/// every app open instead of only for genuinely new events.
@visibleForTesting
QueryDocumentSnapshot<Map<String, dynamic>>? pickLatestUnreadFromPartner(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> docs, {
  required String currentUserId,
  required bool isBacklogSnapshot,
}) {
  DateTime? latestTimestamp;
  QueryDocumentSnapshot<Map<String, dynamic>>? latest;

  for (final doc in docs) {
    final data = doc.data();
    final fromUserId = data['fromUserId'] as String? ?? '';
    final timestamp = data['timestamp'] as Timestamp?;

    // Only process signals/messages from partner (not from current user).
    if (fromUserId != currentUserId && timestamp != null) {
      doc.reference.update({'read': true}).catchError((e) {
        debugPrint('Error marking ${doc.reference.path} as read: $e');
      });
      final docTime = timestamp.toDate();
      if (latestTimestamp == null || docTime.isAfter(latestTimestamp)) {
        latestTimestamp = docTime;
        latest = doc;
      }
    }
  }

  return isBacklogSnapshot ? null : latest;
}

/// Provider that listens for haptic signals from partner
@riverpod
Stream<DateTime?> hapticSignalsStream(HapticSignalsStreamRef ref) {
  final userAsync = ref.watch(userProvider);

  // Handle loading/error states
  if (userAsync.isLoading) {
    return Stream.value(null);
  }

  if (userAsync.hasError) {
    debugPrint('Error in hapticSignalsStream - userProvider error: ${userAsync.error}');
    return Stream.value(null);
  }

  final user = userAsync.valueOrNull;

  if (user == null || user.coupleId == null || user.coupleId!.isEmpty) {
    return Stream.value(null);
  }

  final firestore = FirebaseFirestore.instance;
  final coupleId = user.coupleId!;
  final currentUserId = user.uid;

  debugPrint('Setting up hapticSignalsStream for coupleId: $coupleId, userId: $currentUserId');

  // See pickLatestUnreadFromPartner's doc comment: don't replay a buzz for
  // whatever's already unread the moment this stream (re)subscribes.
  var isFirstSnapshot = true;

  try {
    // Listen to all unread signals, then filter in memory
    // This avoids needing a composite index
    return firestore
        .collection('couples')
        .doc(coupleId)
        .collection('haptic_signals')
        .where('read', isEqualTo: false)
        .snapshots(includeMetadataChanges: false)
        .asyncMap((snapshot) async {
      final isBacklogSnapshot = isFirstSnapshot;
      isFirstSnapshot = false;
      debugPrint(
        'Haptic signals snapshot received: ${snapshot.docs.length} documents'
        '${isBacklogSnapshot ? ' (backlog on connect)' : ''}',
      );

      final latestSignal = pickLatestUnreadFromPartner(
        snapshot.docs,
        currentUserId: currentUserId,
        isBacklogSnapshot: isBacklogSnapshot,
      );

      if (latestSignal != null) {
        final data = latestSignal.data();
        final fromUserId = data['fromUserId'] as String? ?? '';
        final durationMs = data['durationMs'] as int? ?? 200;

        debugPrint('Processing haptic signal from partner: $fromUserId, duration: $durationMs');

        // Trigger haptic feedback
        HapticFeedback.mediumImpact();

        debugPrint('Haptic signal processed successfully');
        // Return timestamp to trigger notification
        return DateTime.now();
      }

      return null;
    }).handleError((error) {
      debugPrint('Error in hapticSignalsStream query: $error');
      debugPrint('Error stack: ${error.toString()}');
      // Return null on error to prevent stream from crashing
      return null;
    });
  } catch (e, stackTrace) {
    debugPrint('Error setting up hapticSignalsStream: $e');
    debugPrint('Stack trace: $stackTrace');
    return Stream.value(null);
  }
}

/// Provider that listens for quick messages from partner
@riverpod
Stream<Map<String, dynamic>?> quickMessagesStream(QuickMessagesStreamRef ref) {
  final userAsync = ref.watch(userProvider);

  // Handle loading/error states
  if (userAsync.isLoading) {
    return Stream.value(null);
  }

  if (userAsync.hasError) {
    debugPrint('Error in quickMessagesStream - userProvider error: ${userAsync.error}');
    return Stream.value(null);
  }

  final user = userAsync.valueOrNull;

  if (user == null || user.coupleId == null || user.coupleId!.isEmpty) {
    return Stream.value(null);
  }

  final firestore = FirebaseFirestore.instance;
  final coupleId = user.coupleId!;
  final currentUserId = user.uid;

  debugPrint('Setting up quickMessagesStream for coupleId: $coupleId, userId: $currentUserId');

  // See pickLatestUnreadFromPartner's doc comment: don't replay a
  // notification for whatever's already unread the moment this stream
  // (re)subscribes.
  var isFirstSnapshot = true;

  try {
    // Listen to all unread messages, then filter in memory
    // This avoids needing a composite index
    return firestore
        .collection('couples')
        .doc(coupleId)
        .collection('quick_messages')
        .where('read', isEqualTo: false)
        .snapshots(includeMetadataChanges: false)
        .map((snapshot) {
      final isBacklogSnapshot = isFirstSnapshot;
      isFirstSnapshot = false;
      debugPrint(
        'Quick messages snapshot received: ${snapshot.docs.length} documents'
        '${isBacklogSnapshot ? ' (backlog on connect)' : ''}',
      );

      final latestMessage = pickLatestUnreadFromPartner(
        snapshot.docs,
        currentUserId: currentUserId,
        isBacklogSnapshot: isBacklogSnapshot,
      );

      if (latestMessage != null) {
        final data = latestMessage.data();
        final messageText = data['message'] as String? ?? '';

        debugPrint('Processing quick message from partner: $messageText');
        debugPrint('Quick message processed successfully');
        return {
          'message': messageText,
          'timestamp': data['timestamp'] as Timestamp?,
        };
      }

      return null;
    }).handleError((error) {
      debugPrint('Error in quickMessagesStream query: $error');
      debugPrint('Error stack: ${error.toString()}');
      // Return null on error to prevent stream from crashing
      return null;
    });
  } catch (e, stackTrace) {
    debugPrint('Error setting up quickMessagesStream: $e');
    debugPrint('Stack trace: $stackTrace');
    return Stream.value(null);
  }
}

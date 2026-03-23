import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/presentation/auth_providers.dart';

part 'haptic_listener_provider.g.dart';

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
      debugPrint('Haptic signals snapshot received: ${snapshot.docs.length} documents');
      
      if (snapshot.docs.isEmpty) {
        return null;
      }
      
      // Find the most recent unread signal from partner
      DateTime? latestTimestamp;
      DocumentSnapshot? latestSignal;
      
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final fromUserId = data['fromUserId'] as String? ?? '';
        final timestamp = data['timestamp'] as Timestamp?;
        
        // Only process signals from partner (not from current user)
        if (fromUserId != currentUserId && timestamp != null) {
          final docTime = timestamp.toDate();
          if (latestTimestamp == null || docTime.isAfter(latestTimestamp)) {
            latestTimestamp = docTime;
            latestSignal = doc;
          }
        }
      }
      
      if (latestSignal != null) {
        final data = latestSignal.data() as Map<String, dynamic>;
        final fromUserId = data['fromUserId'] as String? ?? '';
        final durationMs = data['durationMs'] as int? ?? 200;
        
        debugPrint('Processing haptic signal from partner: $fromUserId, duration: $durationMs');
        
        // Trigger haptic feedback
        HapticFeedback.mediumImpact();
        
        // Mark as read (async to avoid blocking)
        latestSignal.reference.update({'read': true}).catchError((e) {
          debugPrint('Error marking haptic signal as read: $e');
        });
        
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
      debugPrint('Quick messages snapshot received: ${snapshot.docs.length} documents');
      
      if (snapshot.docs.isEmpty) {
        return null;
      }
      
      // Find the most recent unread message from partner
      DateTime? latestTimestamp;
      DocumentSnapshot? latestMessage;
      
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final fromUserId = data['fromUserId'] as String? ?? '';
        final timestamp = data['timestamp'] as Timestamp?;
        
        // Only process messages from partner (not from current user)
        if (fromUserId != currentUserId && timestamp != null) {
          final docTime = timestamp.toDate();
          if (latestTimestamp == null || docTime.isAfter(latestTimestamp)) {
            latestTimestamp = docTime;
            latestMessage = doc;
          }
        }
      }
      
      if (latestMessage != null) {
        final data = latestMessage.data() as Map<String, dynamic>;
        final messageText = data['message'] as String? ?? '';
        
        debugPrint('Processing quick message from partner: $messageText');
        
        // Mark as read
        latestMessage.reference.update({'read': true}).catchError((e) {
          debugPrint('Error marking quick message as read: $e');
        });
        
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

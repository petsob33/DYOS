import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/haptic_signal.dart';

part 'haptic_signal_repository.g.dart';

@riverpod
HapticSignalRepository hapticSignalRepository(HapticSignalRepositoryRef ref) {
  return HapticSignalRepository();
}

/// Repository for reading the full history of haptic "heart" signals sent
/// between a couple (see couple_notification_service.dart for writes).
class HapticSignalRepository {
  HapticSignalRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Signals sent for [coupleId] in the last [windowDays] days, regardless
  /// of read status (unlike hapticSignalsStream, which only surfaces unread
  /// ones for notification purposes).
  ///
  /// Bounded rather than full history: the only consumer (heartsStreak) only
  /// ever looks at consecutive recent days, and 90 days comfortably covers
  /// any realistic streak while keeping reads from growing unboundedly with
  /// a couple's account age.
  Stream<List<HapticSignal>> watchSignals(
    String coupleId, {
    int windowDays = 90,
    DateTime? now,
  }) {
    if (coupleId.isEmpty) return Stream.value([]);

    final cutoff = (now ?? DateTime.now()).subtract(Duration(days: windowDays));

    return _firestore
        .collection('couples')
        .doc(coupleId)
        .collection('haptic_signals')
        .where('timestamp', isGreaterThan: Timestamp.fromDate(cutoff))
        .snapshots()
        .map((snapshot) => snapshot.docs.map(HapticSignal.fromFirestore).toList());
  }
}

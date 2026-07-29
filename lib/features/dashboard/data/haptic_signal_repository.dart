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

  /// All signals ever sent for [coupleId], regardless of read status
  /// (unlike hapticSignalsStream, which only surfaces unread ones for
  /// notification purposes).
  Stream<List<HapticSignal>> watchSignals(String coupleId) {
    if (coupleId.isEmpty) return Stream.value([]);

    return _firestore
        .collection('couples')
        .doc(coupleId)
        .collection('haptic_signals')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(HapticSignal.fromFirestore).toList());
  }
}

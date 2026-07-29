import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/presentation/auth_providers.dart';
import '../data/haptic_signal_repository.dart';
import '../domain/haptic_signal.dart';

part 'hearts_streak_provider.g.dart';

/// Full history of haptic signals for the current user's couple, used to
/// compute the "hearts streak" highlight on the Data & Analytics screen.
@riverpod
Stream<List<HapticSignal>> hapticSignalsHistory(HapticSignalsHistoryRef ref) {
  final userAsync = ref.watch(userProvider);
  final user = userAsync.valueOrNull;

  if (user == null || user.coupleId == null || user.coupleId!.isEmpty) {
    return Stream.value([]);
  }

  final repository = ref.watch(hapticSignalRepositoryProvider);
  return repository.watchSignals(user.coupleId!);
}

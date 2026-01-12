import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/presentation/auth_providers.dart';
import '../data/intimacy_repository.dart';
import '../domain/intimacy_log_model.dart';

part 'intimacy_provider.g.dart';

/// Stream provider that watches intimacy logs for the current user's couple
/// 
/// This provider automatically updates when logs are added, updated, or deleted.
/// It requires the user to be paired (have a coupleId).
@riverpod
Stream<List<IntimacyLog>> intimacyLogsStream(IntimacyLogsStreamRef ref) {
  final userAsync = ref.watch(userProvider);
  final user = userAsync.valueOrNull;

  if (user == null || user.coupleId == null || user.coupleId!.isEmpty) {
    return Stream.value([]);
  }

  final repository = ref.watch(intimacyRepositoryProvider);
  return repository.watchLogs(user.coupleId!);
}

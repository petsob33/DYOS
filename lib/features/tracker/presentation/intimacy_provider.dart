import 'dart:async';

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

/// Paginated feed state for the full intimacy history screen - see
/// [IntimacyFeedController].
class IntimacyFeedState {
  const IntimacyFeedState({
    this.logs = const [],
    this.isLoadingMore = false,
    this.hasMore = true,
  });

  final List<IntimacyLog> logs;
  final bool isLoadingMore;
  final bool hasMore;

  IntimacyFeedState copyWith({
    List<IntimacyLog>? logs,
    bool? isLoadingMore,
    bool? hasMore,
  }) {
    return IntimacyFeedState(
      logs: logs ?? this.logs,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

/// Bounds the full intimacy history screen to a live window of the most
/// recent logs, with a manual "load more" for older pages - see
/// intimacy_repository.dart's getRecentLogsFeed/getOlderLogs for why this
/// is separate from [intimacyLogsStreamProvider] (which streams the full,
/// unbounded collection and is still used by data_screen.dart's small
/// preview, insight_provider.dart and cycle_tracking_screen.dart's stats).
///
/// Same live-then-static tradeoff as TimelineFeedController: stays live
/// while showing just the first page, then pauses live updates once the
/// user loads more pages to avoid merging a moving window with static
/// older pages.
class IntimacyFeedController extends StateNotifier<IntimacyFeedState> {
  IntimacyFeedController(this._ref, this._coupleId) : super(const IntimacyFeedState()) {
    if (_coupleId.isNotEmpty) {
      _subscribeToRecent();
    }
  }

  final Ref _ref;
  final String _coupleId;
  static const _pageSize = 50;
  StreamSubscription<List<IntimacyLog>>? _subscription;
  bool _paginating = false;

  void _subscribeToRecent() {
    final repository = _ref.read(intimacyRepositoryProvider);
    _subscription =
        repository.getRecentLogsFeed(_coupleId, limit: _pageSize).listen((recent) {
      if (_paginating) return;
      state = IntimacyFeedState(logs: recent, hasMore: recent.length >= _pageSize);
    });
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.logs.isEmpty) return;
    _paginating = true;
    state = state.copyWith(isLoadingMore: true);

    final repository = _ref.read(intimacyRepositoryProvider);
    final older = await repository.getOlderLogs(
      _coupleId,
      before: state.logs.last.date,
      limit: _pageSize,
    );

    state = IntimacyFeedState(
      logs: [...state.logs, ...older],
      isLoadingMore: false,
      hasMore: older.length >= _pageSize,
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final intimacyFeedControllerProvider =
    StateNotifierProvider.autoDispose<IntimacyFeedController, IntimacyFeedState>((ref) {
  final userAsync = ref.watch(userProvider);
  final coupleId = userAsync.valueOrNull?.coupleId ?? '';
  return IntimacyFeedController(ref, coupleId);
});

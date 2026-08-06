import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../domain/memory_model.dart';
import '../data/memory_repository.dart';
import '../../auth/presentation/auth_providers.dart';

final selectedCategoryProvider = StateProvider<MemoryCategory?>((ref) => null);

final memoriesStreamProvider = StreamProvider<List<Memory>>((ref) {
  final userAsync = ref.watch(userProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);

  final user = userAsync.valueOrNull;

  if (user == null || user.coupleId == null || user.coupleId!.isEmpty) {
    return Stream.value([]);
  }

  final repository = ref.watch(memoryRepositoryProvider);

  return repository.getMemories(user.coupleId!, category: selectedCategory);
});

/// Paginated feed state for the timeline's default (no category filter)
/// view - see [TimelineFeedController].
class TimelineFeedState {
  const TimelineFeedState({
    this.memories = const [],
    this.isLoadingMore = false,
    this.hasMore = true,
  });

  final List<Memory> memories;
  final bool isLoadingMore;
  final bool hasMore;

  TimelineFeedState copyWith({
    List<Memory>? memories,
    bool? isLoadingMore,
    bool? hasMore,
  }) {
    return TimelineFeedState(
      memories: memories ?? this.memories,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

/// Bounds the timeline's default feed to a live window of the most recent
/// memories, with a manual "load more" for older pages - see
/// memory_repository.dart's getRecentMemoriesFeed/getOlderMemories for why
/// this is separate from [memoriesStreamProvider] (which streams the full,
/// unbounded collection and is still used by the memories map and
/// dashboard insights).
///
/// Only handles the unfiltered ("All categories") view: filtering by
/// category is a much smaller read (couples rarely have 50+ memories in a
/// single category) and continues to use [memoriesStreamProvider], which
/// avoids needing a category+date composite Firestore index.
///
/// Stays live (auto-updating) while showing just the first page; once the
/// user loads more pages, live updates pause to avoid the complexity of
/// merging a moving live window with static older pages - a fresh load of
/// the screen picks up new memories again.
class TimelineFeedController extends StateNotifier<TimelineFeedState> {
  TimelineFeedController(this._ref, this._coupleId) : super(const TimelineFeedState()) {
    if (_coupleId.isNotEmpty) {
      _subscribeToRecent();
    }
  }

  final Ref _ref;
  final String _coupleId;
  static const _pageSize = 50;
  StreamSubscription<List<Memory>>? _subscription;
  bool _paginating = false;

  void _subscribeToRecent() {
    final repository = _ref.read(memoryRepositoryProvider);
    _subscription =
        repository.getRecentMemoriesFeed(_coupleId, limit: _pageSize).listen((recent) {
      if (_paginating) return;
      state = TimelineFeedState(memories: recent, hasMore: recent.length >= _pageSize);
    });
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.memories.isEmpty) return;
    _paginating = true;
    state = state.copyWith(isLoadingMore: true);

    final repository = _ref.read(memoryRepositoryProvider);
    final older = await repository.getOlderMemories(
      _coupleId,
      before: state.memories.last.date,
      limit: _pageSize,
    );

    state = TimelineFeedState(
      memories: [...state.memories, ...older],
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

final timelineFeedControllerProvider =
    StateNotifierProvider.autoDispose<TimelineFeedController, TimelineFeedState>((ref) {
  final userAsync = ref.watch(userProvider);
  final coupleId = userAsync.valueOrNull?.coupleId ?? '';
  return TimelineFeedController(ref, coupleId);
});

sealed class AddMemoryState {}

class AddMemoryInitial extends AddMemoryState {}

class AddMemoryUploading extends AddMemoryState {}

class AddMemorySuccess extends AddMemoryState {
  final Memory memory;
  AddMemorySuccess(this.memory);
}

class AddMemoryError extends AddMemoryState {
  final String message;
  AddMemoryError(this.message);
}

class AddMemoryController extends StateNotifier<AddMemoryState> {
  AddMemoryController(this.ref) : super(AddMemoryInitial());

  final Ref ref;

  Future<void> uploadMemory({
    required Memory memory,
    required List<XFile> mediaFiles,
  }) async {
    try {
      final userAsync = ref.watch(userProvider);
      final user = userAsync.valueOrNull;

      if (user == null) {
        state = AddMemoryError('User not authenticated');
        return;
      }

      if (user.coupleId == null || user.coupleId!.isEmpty) {
        state = AddMemoryError('User is not paired. Please pair with your partner first.');
        return;
      }

      final authUser = ref.read(currentUserProvider);
      if (authUser == null) {
        state = AddMemoryError('Authentication error');
        return;
      }

      final memoryToCreate = memory.copyWith(
        pairId: user.coupleId!,
        authorId: authUser.uid,
      );

      state = AddMemoryUploading();

      final repository = ref.read(memoryRepositoryProvider);
      final createdMemory = await repository.createMemory(
        memory: memoryToCreate,
        mediaFiles: mediaFiles,
      );

      state = AddMemorySuccess(createdMemory);
    } catch (e) {
      state = AddMemoryError(
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<bool> updateMemory(Memory memory) async {
    try {
      final repository = ref.read(memoryRepositoryProvider);
      await repository.updateMemory(memory);
      state = AddMemorySuccess(memory);
      return true;
    } catch (e) {
      state = AddMemoryError(
        e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  void reset() {
    state = AddMemoryInitial();
  }

  bool get isUploading => state is AddMemoryUploading;
  bool get isSuccess => state is AddMemorySuccess;
  bool get hasError => state is AddMemoryError;
}

final addMemoryControllerProvider =
    StateNotifierProvider<AddMemoryController, AddMemoryState>(
        (ref) => AddMemoryController(ref));


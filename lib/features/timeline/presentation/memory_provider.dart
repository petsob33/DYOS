import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/memory_model.dart';
import '../data/memory_repository.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../auth/domain/user_model.dart';

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
    required List<File> mediaFiles,
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


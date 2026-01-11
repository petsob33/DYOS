import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/memory_model.dart';
import '../data/memory_repository.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../auth/domain/user_model.dart';

part 'memory_provider.freezed.dart';
part 'memory_provider.g.dart';

// MemoryRepository provider is defined in memory_repository.dart
// Import it from there: import '../../data/memory_repository.dart';

/// StreamProvider that provides a stream of memories for the current user's couple
/// 
/// This provider automatically listens to Firestore changes and updates the UI
/// whenever memories are added, updated, or deleted. It depends on the user's
/// coupleId, which is obtained from the userProvider.
/// 
/// Stream behavior:
/// - Emits empty list if user is not paired or not authenticated
/// - Emits List<Memory> ordered by date descending (newest first)
/// - Automatically updates when memories change in Firestore
/// - Returns empty list if there's an error
/// 
/// Example:
/// ```dart
/// final memoriesAsync = ref.watch(memoriesStreamProvider);
/// memoriesAsync.when(
///   data: (memories) => ListView.builder(
///     itemCount: memories.length,
///     itemBuilder: (context, index) => MemoryCard(memory: memories[index]),
///   ),
///   loading: () => CircularProgressIndicator(),
///   error: (error, stack) => Text('Error: $error'),
/// );
/// ```
@riverpod
Stream<List<Memory>> memoriesStream(MemoriesStreamRef ref) {
  // 1. Sledujeme userProvider. Jakmile se změní user, celá tato funkce se spustí znovu.
  final userAsync = ref.watch(userProvider);

  // 2. Získáme aktuální hodnotu uživatele
  final user = userAsync.valueOrNull;

  // 3. Validace: Pokud nemáme uživatele nebo coupleId, vracíme prázdný stream
  if (user == null || user.coupleId == null || user.coupleId!.isEmpty) {
    return Stream.value([]);
  }

  // 4. Získáme repo
  final repository = ref.watch(memoryRepositoryProvider);

  // 5. Vrátíme přímo stream z repozitáře. 
  // Riverpod se postará o open/close subscription.
  return repository.getMemories(user.coupleId!);
}

/// State class for the add memory controller
/// 
/// This class represents the different states when adding a memory:
/// - initial: No operation in progress
/// - uploading: Memory is currently being uploaded
/// - success: Memory was successfully created
/// - error: An error occurred during upload
@freezed
class AddMemoryState with _$AddMemoryState {
  const factory AddMemoryState.initial() = _Initial;
  const factory AddMemoryState.uploading() = _Uploading;
  const factory AddMemoryState.success(Memory memory) = _Success;
  const factory AddMemoryState.error(String message) = _Error;
}

/// Controller provider for handling memory upload UI state
/// 
/// This provider manages the state of adding a new memory, including:
/// - Loading states (isUploading)
/// - Success state (with created Memory)
/// - Error state (with error message)
/// 
/// Usage:
/// ```dart
/// final controller = ref.read(addMemoryControllerProvider.notifier);
/// final state = ref.watch(addMemoryControllerProvider);
/// 
/// // Upload a memory
/// await controller.uploadMemory(
///   memory: Memory(...),
///   mediaFiles: [File('path/to/image.jpg')],
/// );
/// 
/// // Check state
/// state.when(
///   initial: () => Text('Ready to upload'),
///   uploading: () => CircularProgressIndicator(),
///   success: (memory) => Text('Success! ${memory.caption}'),
///   error: (message) => Text('Error: $message'),
/// );
/// ```
@riverpod
class AddMemoryController extends _$AddMemoryController {
  @override
  AddMemoryState build() {
    return const AddMemoryState.initial();
  }

  /// Upload a memory with media files
  /// 
  /// This method:
  /// 1. Validates that the user is paired (has a coupleId)
  /// 2. Sets state to uploading
  /// 3. Calls the repository to create the memory
  /// 4. Sets state to success with the created memory
  /// 5. Handles errors and sets error state
  /// 
  /// [memory] - The Memory object to create (should have pairId set)
  /// [mediaFiles] - List of image/video files to upload (can be empty)
  /// 
  /// The memory's pairId will be automatically set from the current user's coupleId
  /// if not already set. The authorId will be set from the current user's UID.
  /// 
  /// Throws: Does not throw - errors are captured in state
  Future<void> uploadMemory({
    required Memory memory,
    required List<File> mediaFiles,
  }) async {
    try {
      // Get current user to validate pairing and get IDs
      final userAsync = ref.watch(userProvider);
      final user = userAsync.valueOrNull;

      if (user == null) {
        state = const AddMemoryState.error('User not authenticated');
        return;
      }

      if (user.coupleId == null || user.coupleId!.isEmpty) {
        state = const AddMemoryState.error('User is not paired. Please pair with your partner first.');
        return;
      }

      // Get current auth user for authorId
      final authUser = ref.read(currentUserProvider);
      if (authUser == null) {
        state = const AddMemoryState.error('Authentication error');
        return;
      }

      // Ensure memory has correct pairId and authorId
      final memoryToCreate = memory.copyWith(
        pairId: user.coupleId!,
        authorId: authUser.uid,
      );

      // Set state to uploading
      state = const AddMemoryState.uploading();

      // Get repository and create memory
      final repository = ref.read(memoryRepositoryProvider);
      final createdMemory = await repository.createMemory(
        memory: memoryToCreate,
        mediaFiles: mediaFiles,
      );

      // Set state to success with created memory
      state = AddMemoryState.success(createdMemory);

      // Optionally: Invalidate the memories stream to refresh the list
      // This is usually not needed as the stream will update automatically,
      // but you can do it if you want to ensure immediate refresh
      // ref.invalidate(memoriesStreamProvider);
    } catch (e) {
      // Capture any errors and set error state
      state = AddMemoryState.error(
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  /// Reset the state to initial
  /// 
  /// Call this after showing success/error messages to allow
  /// the user to upload another memory.
  void reset() {
    state = const AddMemoryState.initial();
  }

  /// Check if currently uploading
  /// 
  /// Helper method to easily check upload state in UI
  bool get isUploading {
    return state.maybeWhen(
      uploading: () => true,
      orElse: () => false,
    );
  }

  /// Check if upload was successful
  /// 
  /// Helper method to easily check success state in UI
  bool get isSuccess {
    return state.maybeWhen(
      success: (_) => true,
      orElse: () => false,
    );
  }

  /// Check if there was an error
  /// 
  /// Helper method to easily check error state in UI
  bool get hasError {
    return state.maybeWhen(
      error: (_) => true,
      orElse: () => false,
    );
  }
}

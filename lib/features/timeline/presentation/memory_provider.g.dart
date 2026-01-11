// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memory_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$memoriesStreamHash() => r'0244c941004823c1ae29feb955fe9562920b2e43';

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
///
/// Copied from [memoriesStream].
@ProviderFor(memoriesStream)
final memoriesStreamProvider = AutoDisposeStreamProvider<List<Memory>>.internal(
  memoriesStream,
  name: r'memoriesStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$memoriesStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MemoriesStreamRef = AutoDisposeStreamProviderRef<List<Memory>>;
String _$addMemoryControllerHash() =>
    r'35cbb174061b4199da3840337103e6c8553c8eca';

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
///
/// Copied from [AddMemoryController].
@ProviderFor(AddMemoryController)
final addMemoryControllerProvider =
    AutoDisposeNotifierProvider<AddMemoryController, AddMemoryState>.internal(
      AddMemoryController.new,
      name: r'addMemoryControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$addMemoryControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AddMemoryController = AutoDisposeNotifier<AddMemoryState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notes_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$latestSharedNoteHash() => r'2441259499566f10ebf3605380423b3e1869b110';

/// Provider for the latest shared note (for QuickNoteCard)
///
/// Copied from [latestSharedNote].
@ProviderFor(latestSharedNote)
final latestSharedNoteProvider = AutoDisposeStreamProvider<NoteItem?>.internal(
  latestSharedNote,
  name: r'latestSharedNoteProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$latestSharedNoteHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LatestSharedNoteRef = AutoDisposeStreamProviderRef<NoteItem?>;
String _$coupleNotesHash() => r'4cfdcbd89836fb52b4fc73a2bb59cf8f55bcbda9';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Provider for all notes of a couple
///
/// Copied from [coupleNotes].
@ProviderFor(coupleNotes)
const coupleNotesProvider = CoupleNotesFamily();

/// Provider for all notes of a couple
///
/// Copied from [coupleNotes].
class CoupleNotesFamily extends Family<AsyncValue<List<NoteItem>>> {
  /// Provider for all notes of a couple
  ///
  /// Copied from [coupleNotes].
  const CoupleNotesFamily();

  /// Provider for all notes of a couple
  ///
  /// Copied from [coupleNotes].
  CoupleNotesProvider call({NoteType? type}) {
    return CoupleNotesProvider(type: type);
  }

  @override
  CoupleNotesProvider getProviderOverride(
    covariant CoupleNotesProvider provider,
  ) {
    return call(type: provider.type);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'coupleNotesProvider';
}

/// Provider for all notes of a couple
///
/// Copied from [coupleNotes].
class CoupleNotesProvider extends AutoDisposeStreamProvider<List<NoteItem>> {
  /// Provider for all notes of a couple
  ///
  /// Copied from [coupleNotes].
  CoupleNotesProvider({NoteType? type})
    : this._internal(
        (ref) => coupleNotes(ref as CoupleNotesRef, type: type),
        from: coupleNotesProvider,
        name: r'coupleNotesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$coupleNotesHash,
        dependencies: CoupleNotesFamily._dependencies,
        allTransitiveDependencies: CoupleNotesFamily._allTransitiveDependencies,
        type: type,
      );

  CoupleNotesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.type,
  }) : super.internal();

  final NoteType? type;

  @override
  Override overrideWith(
    Stream<List<NoteItem>> Function(CoupleNotesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CoupleNotesProvider._internal(
        (ref) => create(ref as CoupleNotesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        type: type,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<NoteItem>> createElement() {
    return _CoupleNotesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CoupleNotesProvider && other.type == type;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, type.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CoupleNotesRef on AutoDisposeStreamProviderRef<List<NoteItem>> {
  /// The parameter `type` of this provider.
  NoteType? get type;
}

class _CoupleNotesProviderElement
    extends AutoDisposeStreamProviderElement<List<NoteItem>>
    with CoupleNotesRef {
  _CoupleNotesProviderElement(super.provider);

  @override
  NoteType? get type => (origin as CoupleNotesProvider).type;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

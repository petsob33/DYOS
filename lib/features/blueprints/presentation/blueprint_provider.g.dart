// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blueprint_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$blueprintSectionsHash() => r'25b248c908f3cd6250cc575c59ae91b77f34a712';

/// All Blueprint sections, ordered. Falls back to the bundled
/// [BlueprintMockData] if Firestore has no seeded sections yet, so the
/// feature keeps working before/without running the seed script.
///
/// Copied from [blueprintSections].
@ProviderFor(blueprintSections)
final blueprintSectionsProvider =
    AutoDisposeStreamProvider<List<BlueprintSection>>.internal(
      blueprintSections,
      name: r'blueprintSectionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$blueprintSectionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BlueprintSectionsRef =
    AutoDisposeStreamProviderRef<List<BlueprintSection>>;
String _$blueprintSectionHash() => r'558cdcfcde16caeaeea4b92af9584624460e33a5';

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

/// A single Blueprint section by id, for the detail screen. Falls back to
/// [BlueprintMockData.sectionById] if not found in Firestore.
///
/// Copied from [blueprintSection].
@ProviderFor(blueprintSection)
const blueprintSectionProvider = BlueprintSectionFamily();

/// A single Blueprint section by id, for the detail screen. Falls back to
/// [BlueprintMockData.sectionById] if not found in Firestore.
///
/// Copied from [blueprintSection].
class BlueprintSectionFamily extends Family<AsyncValue<BlueprintSection?>> {
  /// A single Blueprint section by id, for the detail screen. Falls back to
  /// [BlueprintMockData.sectionById] if not found in Firestore.
  ///
  /// Copied from [blueprintSection].
  const BlueprintSectionFamily();

  /// A single Blueprint section by id, for the detail screen. Falls back to
  /// [BlueprintMockData.sectionById] if not found in Firestore.
  ///
  /// Copied from [blueprintSection].
  BlueprintSectionProvider call(String sectionId) {
    return BlueprintSectionProvider(sectionId);
  }

  @override
  BlueprintSectionProvider getProviderOverride(
    covariant BlueprintSectionProvider provider,
  ) {
    return call(provider.sectionId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'blueprintSectionProvider';
}

/// A single Blueprint section by id, for the detail screen. Falls back to
/// [BlueprintMockData.sectionById] if not found in Firestore.
///
/// Copied from [blueprintSection].
class BlueprintSectionProvider
    extends AutoDisposeFutureProvider<BlueprintSection?> {
  /// A single Blueprint section by id, for the detail screen. Falls back to
  /// [BlueprintMockData.sectionById] if not found in Firestore.
  ///
  /// Copied from [blueprintSection].
  BlueprintSectionProvider(String sectionId)
    : this._internal(
        (ref) => blueprintSection(ref as BlueprintSectionRef, sectionId),
        from: blueprintSectionProvider,
        name: r'blueprintSectionProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$blueprintSectionHash,
        dependencies: BlueprintSectionFamily._dependencies,
        allTransitiveDependencies:
            BlueprintSectionFamily._allTransitiveDependencies,
        sectionId: sectionId,
      );

  BlueprintSectionProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.sectionId,
  }) : super.internal();

  final String sectionId;

  @override
  Override overrideWith(
    FutureOr<BlueprintSection?> Function(BlueprintSectionRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: BlueprintSectionProvider._internal(
        (ref) => create(ref as BlueprintSectionRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        sectionId: sectionId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<BlueprintSection?> createElement() {
    return _BlueprintSectionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BlueprintSectionProvider && other.sectionId == sectionId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, sectionId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin BlueprintSectionRef on AutoDisposeFutureProviderRef<BlueprintSection?> {
  /// The parameter `sectionId` of this provider.
  String get sectionId;
}

class _BlueprintSectionProviderElement
    extends AutoDisposeFutureProviderElement<BlueprintSection?>
    with BlueprintSectionRef {
  _BlueprintSectionProviderElement(super.provider);

  @override
  String get sectionId => (origin as BlueprintSectionProvider).sectionId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

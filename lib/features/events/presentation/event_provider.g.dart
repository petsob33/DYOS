// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$eventsStreamHash() => r'fd81db78b05a990dcc3526ef09f7e35f09e66813';

/// Provider that watches all events for the current couple
///
/// Copied from [eventsStream].
@ProviderFor(eventsStream)
final eventsStreamProvider = AutoDisposeStreamProvider<List<Event>>.internal(
  eventsStream,
  name: r'eventsStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$eventsStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EventsStreamRef = AutoDisposeStreamProviderRef<List<Event>>;
String _$nextEventHash() => r'c33e698b2e04b3e1cb0fab36535c48a418f09277';

/// Provider that gets the next upcoming event
///
/// Copied from [nextEvent].
@ProviderFor(nextEvent)
final nextEventProvider = AutoDisposeStreamProvider<Event?>.internal(
  nextEvent,
  name: r'nextEventProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$nextEventHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NextEventRef = AutoDisposeStreamProviderRef<Event?>;
String _$eventsForDateHash() => r'2e3339fa8b41580aa7f27d3ca627d3828ef98e58';

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

/// Provider that gets events for a specific date
///
/// Copied from [eventsForDate].
@ProviderFor(eventsForDate)
const eventsForDateProvider = EventsForDateFamily();

/// Provider that gets events for a specific date
///
/// Copied from [eventsForDate].
class EventsForDateFamily extends Family<AsyncValue<List<Event>>> {
  /// Provider that gets events for a specific date
  ///
  /// Copied from [eventsForDate].
  const EventsForDateFamily();

  /// Provider that gets events for a specific date
  ///
  /// Copied from [eventsForDate].
  EventsForDateProvider call(DateTime date) {
    return EventsForDateProvider(date);
  }

  @override
  EventsForDateProvider getProviderOverride(
    covariant EventsForDateProvider provider,
  ) {
    return call(provider.date);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'eventsForDateProvider';
}

/// Provider that gets events for a specific date
///
/// Copied from [eventsForDate].
class EventsForDateProvider extends AutoDisposeStreamProvider<List<Event>> {
  /// Provider that gets events for a specific date
  ///
  /// Copied from [eventsForDate].
  EventsForDateProvider(DateTime date)
    : this._internal(
        (ref) => eventsForDate(ref as EventsForDateRef, date),
        from: eventsForDateProvider,
        name: r'eventsForDateProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$eventsForDateHash,
        dependencies: EventsForDateFamily._dependencies,
        allTransitiveDependencies:
            EventsForDateFamily._allTransitiveDependencies,
        date: date,
      );

  EventsForDateProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.date,
  }) : super.internal();

  final DateTime date;

  @override
  Override overrideWith(
    Stream<List<Event>> Function(EventsForDateRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: EventsForDateProvider._internal(
        (ref) => create(ref as EventsForDateRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        date: date,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Event>> createElement() {
    return _EventsForDateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EventsForDateProvider && other.date == date;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, date.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin EventsForDateRef on AutoDisposeStreamProviderRef<List<Event>> {
  /// The parameter `date` of this provider.
  DateTime get date;
}

class _EventsForDateProviderElement
    extends AutoDisposeStreamProviderElement<List<Event>>
    with EventsForDateRef {
  _EventsForDateProviderElement(super.provider);

  @override
  DateTime get date => (origin as EventsForDateProvider).date;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

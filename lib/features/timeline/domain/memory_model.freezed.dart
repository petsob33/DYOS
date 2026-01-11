// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'memory_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Memory _$MemoryFromJson(Map<String, dynamic> json) {
  return _Memory.fromJson(json);
}

/// @nodoc
mixin _$Memory {
  String get id => throw _privateConstructorUsedError;
  String get pairId => throw _privateConstructorUsedError; // Link to the couple
  String get authorId => throw _privateConstructorUsedError; // Who posted it
  List<String> get mediaUrls =>
      throw _privateConstructorUsedError; // Multiple photos/videos
  String get caption => throw _privateConstructorUsedError;
  @RequiredTimestampConverter()
  DateTime get date => throw _privateConstructorUsedError;
  @MemoryCategoryConverter()
  MemoryCategory get category => throw _privateConstructorUsedError;
  Map<String, dynamic>? get location =>
      throw _privateConstructorUsedError; // Generic location data (name, lat, lng)
  @RequiredTimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Memory to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Memory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MemoryCopyWith<Memory> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MemoryCopyWith<$Res> {
  factory $MemoryCopyWith(Memory value, $Res Function(Memory) then) =
      _$MemoryCopyWithImpl<$Res, Memory>;
  @useResult
  $Res call({
    String id,
    String pairId,
    String authorId,
    List<String> mediaUrls,
    String caption,
    @RequiredTimestampConverter() DateTime date,
    @MemoryCategoryConverter() MemoryCategory category,
    Map<String, dynamic>? location,
    @RequiredTimestampConverter() DateTime createdAt,
  });
}

/// @nodoc
class _$MemoryCopyWithImpl<$Res, $Val extends Memory>
    implements $MemoryCopyWith<$Res> {
  _$MemoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Memory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? pairId = null,
    Object? authorId = null,
    Object? mediaUrls = null,
    Object? caption = null,
    Object? date = null,
    Object? category = null,
    Object? location = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            pairId: null == pairId
                ? _value.pairId
                : pairId // ignore: cast_nullable_to_non_nullable
                      as String,
            authorId: null == authorId
                ? _value.authorId
                : authorId // ignore: cast_nullable_to_non_nullable
                      as String,
            mediaUrls: null == mediaUrls
                ? _value.mediaUrls
                : mediaUrls // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            caption: null == caption
                ? _value.caption
                : caption // ignore: cast_nullable_to_non_nullable
                      as String,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as MemoryCategory,
            location: freezed == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MemoryImplCopyWith<$Res> implements $MemoryCopyWith<$Res> {
  factory _$$MemoryImplCopyWith(
    _$MemoryImpl value,
    $Res Function(_$MemoryImpl) then,
  ) = __$$MemoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String pairId,
    String authorId,
    List<String> mediaUrls,
    String caption,
    @RequiredTimestampConverter() DateTime date,
    @MemoryCategoryConverter() MemoryCategory category,
    Map<String, dynamic>? location,
    @RequiredTimestampConverter() DateTime createdAt,
  });
}

/// @nodoc
class __$$MemoryImplCopyWithImpl<$Res>
    extends _$MemoryCopyWithImpl<$Res, _$MemoryImpl>
    implements _$$MemoryImplCopyWith<$Res> {
  __$$MemoryImplCopyWithImpl(
    _$MemoryImpl _value,
    $Res Function(_$MemoryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Memory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? pairId = null,
    Object? authorId = null,
    Object? mediaUrls = null,
    Object? caption = null,
    Object? date = null,
    Object? category = null,
    Object? location = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$MemoryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        pairId: null == pairId
            ? _value.pairId
            : pairId // ignore: cast_nullable_to_non_nullable
                  as String,
        authorId: null == authorId
            ? _value.authorId
            : authorId // ignore: cast_nullable_to_non_nullable
                  as String,
        mediaUrls: null == mediaUrls
            ? _value._mediaUrls
            : mediaUrls // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        caption: null == caption
            ? _value.caption
            : caption // ignore: cast_nullable_to_non_nullable
                  as String,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as MemoryCategory,
        location: freezed == location
            ? _value._location
            : location // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$MemoryImpl implements _Memory {
  const _$MemoryImpl({
    required this.id,
    required this.pairId,
    required this.authorId,
    final List<String> mediaUrls = const [],
    required this.caption,
    @RequiredTimestampConverter() required this.date,
    @MemoryCategoryConverter() required this.category,
    final Map<String, dynamic>? location,
    @RequiredTimestampConverter() required this.createdAt,
  }) : _mediaUrls = mediaUrls,
       _location = location;

  factory _$MemoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$MemoryImplFromJson(json);

  @override
  final String id;
  @override
  final String pairId;
  // Link to the couple
  @override
  final String authorId;
  // Who posted it
  final List<String> _mediaUrls;
  // Who posted it
  @override
  @JsonKey()
  List<String> get mediaUrls {
    if (_mediaUrls is EqualUnmodifiableListView) return _mediaUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_mediaUrls);
  }

  // Multiple photos/videos
  @override
  final String caption;
  @override
  @RequiredTimestampConverter()
  final DateTime date;
  @override
  @MemoryCategoryConverter()
  final MemoryCategory category;
  final Map<String, dynamic>? _location;
  @override
  Map<String, dynamic>? get location {
    final value = _location;
    if (value == null) return null;
    if (_location is EqualUnmodifiableMapView) return _location;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  // Generic location data (name, lat, lng)
  @override
  @RequiredTimestampConverter()
  final DateTime createdAt;

  @override
  String toString() {
    return 'Memory(id: $id, pairId: $pairId, authorId: $authorId, mediaUrls: $mediaUrls, caption: $caption, date: $date, category: $category, location: $location, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MemoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.pairId, pairId) || other.pairId == pairId) &&
            (identical(other.authorId, authorId) ||
                other.authorId == authorId) &&
            const DeepCollectionEquality().equals(
              other._mediaUrls,
              _mediaUrls,
            ) &&
            (identical(other.caption, caption) || other.caption == caption) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.category, category) ||
                other.category == category) &&
            const DeepCollectionEquality().equals(other._location, _location) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    pairId,
    authorId,
    const DeepCollectionEquality().hash(_mediaUrls),
    caption,
    date,
    category,
    const DeepCollectionEquality().hash(_location),
    createdAt,
  );

  /// Create a copy of Memory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MemoryImplCopyWith<_$MemoryImpl> get copyWith =>
      __$$MemoryImplCopyWithImpl<_$MemoryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MemoryImplToJson(this);
  }
}

abstract class _Memory implements Memory {
  const factory _Memory({
    required final String id,
    required final String pairId,
    required final String authorId,
    final List<String> mediaUrls,
    required final String caption,
    @RequiredTimestampConverter() required final DateTime date,
    @MemoryCategoryConverter() required final MemoryCategory category,
    final Map<String, dynamic>? location,
    @RequiredTimestampConverter() required final DateTime createdAt,
  }) = _$MemoryImpl;

  factory _Memory.fromJson(Map<String, dynamic> json) = _$MemoryImpl.fromJson;

  @override
  String get id;
  @override
  String get pairId; // Link to the couple
  @override
  String get authorId; // Who posted it
  @override
  List<String> get mediaUrls; // Multiple photos/videos
  @override
  String get caption;
  @override
  @RequiredTimestampConverter()
  DateTime get date;
  @override
  @MemoryCategoryConverter()
  MemoryCategory get category;
  @override
  Map<String, dynamic>? get location; // Generic location data (name, lat, lng)
  @override
  @RequiredTimestampConverter()
  DateTime get createdAt;

  /// Create a copy of Memory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MemoryImplCopyWith<_$MemoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

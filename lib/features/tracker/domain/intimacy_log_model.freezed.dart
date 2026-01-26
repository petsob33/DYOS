// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'intimacy_log_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

IntimacyLog _$IntimacyLogFromJson(Map<String, dynamic> json) {
  return _IntimacyLog.fromJson(json);
}

/// @nodoc
mixin _$IntimacyLog {
  String get id => throw _privateConstructorUsedError;
  @RequiredTimestampConverter()
  DateTime get date => throw _privateConstructorUsedError;
  String get initiatorId =>
      throw _privateConstructorUsedError; // userId who initiated
  int get rating => throw _privateConstructorUsedError; // 1-5 rating
  List<String> get tags =>
      throw _privateConstructorUsedError; // e.g., "Romantic", "Quickie", "Morning", "Experiment"
  List<String> get positions =>
      throw _privateConstructorUsedError; // e.g., "Missionary", "Doggy", "Cowgirl"
  int get userOrgasmCount =>
      throw _privateConstructorUsedError; // Number of orgasms for the user
  int get partnerOrgasmCount =>
      throw _privateConstructorUsedError; // Number of orgasms for the partner
  int? get duration =>
      throw _privateConstructorUsedError; // Duration in minutes (optional)
  String? get location =>
      throw _privateConstructorUsedError; // Optional location where intimacy occurred
  bool get protectionUsed => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;

  /// Serializes this IntimacyLog to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of IntimacyLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $IntimacyLogCopyWith<IntimacyLog> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IntimacyLogCopyWith<$Res> {
  factory $IntimacyLogCopyWith(
    IntimacyLog value,
    $Res Function(IntimacyLog) then,
  ) = _$IntimacyLogCopyWithImpl<$Res, IntimacyLog>;
  @useResult
  $Res call({
    String id,
    @RequiredTimestampConverter() DateTime date,
    String initiatorId,
    int rating,
    List<String> tags,
    List<String> positions,
    int userOrgasmCount,
    int partnerOrgasmCount,
    int? duration,
    String? location,
    bool protectionUsed,
    String? note,
  });
}

/// @nodoc
class _$IntimacyLogCopyWithImpl<$Res, $Val extends IntimacyLog>
    implements $IntimacyLogCopyWith<$Res> {
  _$IntimacyLogCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of IntimacyLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? initiatorId = null,
    Object? rating = null,
    Object? tags = null,
    Object? positions = null,
    Object? userOrgasmCount = null,
    Object? partnerOrgasmCount = null,
    Object? duration = freezed,
    Object? location = freezed,
    Object? protectionUsed = null,
    Object? note = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            initiatorId: null == initiatorId
                ? _value.initiatorId
                : initiatorId // ignore: cast_nullable_to_non_nullable
                      as String,
            rating: null == rating
                ? _value.rating
                : rating // ignore: cast_nullable_to_non_nullable
                      as int,
            tags: null == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            positions: null == positions
                ? _value.positions
                : positions // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            userOrgasmCount: null == userOrgasmCount
                ? _value.userOrgasmCount
                : userOrgasmCount // ignore: cast_nullable_to_non_nullable
                      as int,
            partnerOrgasmCount: null == partnerOrgasmCount
                ? _value.partnerOrgasmCount
                : partnerOrgasmCount // ignore: cast_nullable_to_non_nullable
                      as int,
            duration: freezed == duration
                ? _value.duration
                : duration // ignore: cast_nullable_to_non_nullable
                      as int?,
            location: freezed == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as String?,
            protectionUsed: null == protectionUsed
                ? _value.protectionUsed
                : protectionUsed // ignore: cast_nullable_to_non_nullable
                      as bool,
            note: freezed == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$IntimacyLogImplCopyWith<$Res>
    implements $IntimacyLogCopyWith<$Res> {
  factory _$$IntimacyLogImplCopyWith(
    _$IntimacyLogImpl value,
    $Res Function(_$IntimacyLogImpl) then,
  ) = __$$IntimacyLogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @RequiredTimestampConverter() DateTime date,
    String initiatorId,
    int rating,
    List<String> tags,
    List<String> positions,
    int userOrgasmCount,
    int partnerOrgasmCount,
    int? duration,
    String? location,
    bool protectionUsed,
    String? note,
  });
}

/// @nodoc
class __$$IntimacyLogImplCopyWithImpl<$Res>
    extends _$IntimacyLogCopyWithImpl<$Res, _$IntimacyLogImpl>
    implements _$$IntimacyLogImplCopyWith<$Res> {
  __$$IntimacyLogImplCopyWithImpl(
    _$IntimacyLogImpl _value,
    $Res Function(_$IntimacyLogImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of IntimacyLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? initiatorId = null,
    Object? rating = null,
    Object? tags = null,
    Object? positions = null,
    Object? userOrgasmCount = null,
    Object? partnerOrgasmCount = null,
    Object? duration = freezed,
    Object? location = freezed,
    Object? protectionUsed = null,
    Object? note = freezed,
  }) {
    return _then(
      _$IntimacyLogImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        initiatorId: null == initiatorId
            ? _value.initiatorId
            : initiatorId // ignore: cast_nullable_to_non_nullable
                  as String,
        rating: null == rating
            ? _value.rating
            : rating // ignore: cast_nullable_to_non_nullable
                  as int,
        tags: null == tags
            ? _value._tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        positions: null == positions
            ? _value._positions
            : positions // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        userOrgasmCount: null == userOrgasmCount
            ? _value.userOrgasmCount
            : userOrgasmCount // ignore: cast_nullable_to_non_nullable
                  as int,
        partnerOrgasmCount: null == partnerOrgasmCount
            ? _value.partnerOrgasmCount
            : partnerOrgasmCount // ignore: cast_nullable_to_non_nullable
                  as int,
        duration: freezed == duration
            ? _value.duration
            : duration // ignore: cast_nullable_to_non_nullable
                  as int?,
        location: freezed == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as String?,
        protectionUsed: null == protectionUsed
            ? _value.protectionUsed
            : protectionUsed // ignore: cast_nullable_to_non_nullable
                  as bool,
        note: freezed == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$IntimacyLogImpl implements _IntimacyLog {
  const _$IntimacyLogImpl({
    required this.id,
    @RequiredTimestampConverter() required this.date,
    required this.initiatorId,
    required this.rating,
    final List<String> tags = const [],
    final List<String> positions = const [],
    this.userOrgasmCount = 0,
    this.partnerOrgasmCount = 0,
    this.duration,
    this.location,
    required this.protectionUsed,
    this.note,
  }) : _tags = tags,
       _positions = positions;

  factory _$IntimacyLogImpl.fromJson(Map<String, dynamic> json) =>
      _$$IntimacyLogImplFromJson(json);

  @override
  final String id;
  @override
  @RequiredTimestampConverter()
  final DateTime date;
  @override
  final String initiatorId;
  // userId who initiated
  @override
  final int rating;
  // 1-5 rating
  final List<String> _tags;
  // 1-5 rating
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  // e.g., "Romantic", "Quickie", "Morning", "Experiment"
  final List<String> _positions;
  // e.g., "Romantic", "Quickie", "Morning", "Experiment"
  @override
  @JsonKey()
  List<String> get positions {
    if (_positions is EqualUnmodifiableListView) return _positions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_positions);
  }

  // e.g., "Missionary", "Doggy", "Cowgirl"
  @override
  @JsonKey()
  final int userOrgasmCount;
  // Number of orgasms for the user
  @override
  @JsonKey()
  final int partnerOrgasmCount;
  // Number of orgasms for the partner
  @override
  final int? duration;
  // Duration in minutes (optional)
  @override
  final String? location;
  // Optional location where intimacy occurred
  @override
  final bool protectionUsed;
  @override
  final String? note;

  @override
  String toString() {
    return 'IntimacyLog(id: $id, date: $date, initiatorId: $initiatorId, rating: $rating, tags: $tags, positions: $positions, userOrgasmCount: $userOrgasmCount, partnerOrgasmCount: $partnerOrgasmCount, duration: $duration, location: $location, protectionUsed: $protectionUsed, note: $note)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IntimacyLogImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.initiatorId, initiatorId) ||
                other.initiatorId == initiatorId) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            const DeepCollectionEquality().equals(
              other._positions,
              _positions,
            ) &&
            (identical(other.userOrgasmCount, userOrgasmCount) ||
                other.userOrgasmCount == userOrgasmCount) &&
            (identical(other.partnerOrgasmCount, partnerOrgasmCount) ||
                other.partnerOrgasmCount == partnerOrgasmCount) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.protectionUsed, protectionUsed) ||
                other.protectionUsed == protectionUsed) &&
            (identical(other.note, note) || other.note == note));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    date,
    initiatorId,
    rating,
    const DeepCollectionEquality().hash(_tags),
    const DeepCollectionEquality().hash(_positions),
    userOrgasmCount,
    partnerOrgasmCount,
    duration,
    location,
    protectionUsed,
    note,
  );

  /// Create a copy of IntimacyLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$IntimacyLogImplCopyWith<_$IntimacyLogImpl> get copyWith =>
      __$$IntimacyLogImplCopyWithImpl<_$IntimacyLogImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$IntimacyLogImplToJson(this);
  }
}

abstract class _IntimacyLog implements IntimacyLog {
  const factory _IntimacyLog({
    required final String id,
    @RequiredTimestampConverter() required final DateTime date,
    required final String initiatorId,
    required final int rating,
    final List<String> tags,
    final List<String> positions,
    final int userOrgasmCount,
    final int partnerOrgasmCount,
    final int? duration,
    final String? location,
    required final bool protectionUsed,
    final String? note,
  }) = _$IntimacyLogImpl;

  factory _IntimacyLog.fromJson(Map<String, dynamic> json) =
      _$IntimacyLogImpl.fromJson;

  @override
  String get id;
  @override
  @RequiredTimestampConverter()
  DateTime get date;
  @override
  String get initiatorId; // userId who initiated
  @override
  int get rating; // 1-5 rating
  @override
  List<String> get tags; // e.g., "Romantic", "Quickie", "Morning", "Experiment"
  @override
  List<String> get positions; // e.g., "Missionary", "Doggy", "Cowgirl"
  @override
  int get userOrgasmCount; // Number of orgasms for the user
  @override
  int get partnerOrgasmCount; // Number of orgasms for the partner
  @override
  int? get duration; // Duration in minutes (optional)
  @override
  String? get location; // Optional location where intimacy occurred
  @override
  bool get protectionUsed;
  @override
  String? get note;

  /// Create a copy of IntimacyLog
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$IntimacyLogImplCopyWith<_$IntimacyLogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

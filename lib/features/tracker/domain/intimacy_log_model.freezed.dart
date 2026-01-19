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
  bool get protectionUsed => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError; // Optional note
  int get orgasmsMe =>
      throw _privateConstructorUsedError; // Orgasm count for the user who created the log
  int get orgasmsPartner =>
      throw _privateConstructorUsedError; // Orgasm count for the partner
  int? get durationMinutes =>
      throw _privateConstructorUsedError; // Duration in minutes (optional)
  String? get location => throw _privateConstructorUsedError;

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
    bool protectionUsed,
    String? note,
    int orgasmsMe,
    int orgasmsPartner,
    int? durationMinutes,
    String? location,
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
    Object? protectionUsed = null,
    Object? note = freezed,
    Object? orgasmsMe = null,
    Object? orgasmsPartner = null,
    Object? durationMinutes = freezed,
    Object? location = freezed,
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
            protectionUsed: null == protectionUsed
                ? _value.protectionUsed
                : protectionUsed // ignore: cast_nullable_to_non_nullable
                      as bool,
            note: freezed == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                      as String?,
            orgasmsMe: null == orgasmsMe
                ? _value.orgasmsMe
                : orgasmsMe // ignore: cast_nullable_to_non_nullable
                      as int,
            orgasmsPartner: null == orgasmsPartner
                ? _value.orgasmsPartner
                : orgasmsPartner // ignore: cast_nullable_to_non_nullable
                      as int,
            durationMinutes: freezed == durationMinutes
                ? _value.durationMinutes
                : durationMinutes // ignore: cast_nullable_to_non_nullable
                      as int?,
            location: freezed == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
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
    bool protectionUsed,
    String? note,
    int orgasmsMe,
    int orgasmsPartner,
    int? durationMinutes,
    String? location,
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
    Object? protectionUsed = null,
    Object? note = freezed,
    Object? orgasmsMe = null,
    Object? orgasmsPartner = null,
    Object? durationMinutes = freezed,
    Object? location = freezed,
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
        protectionUsed: null == protectionUsed
            ? _value.protectionUsed
            : protectionUsed // ignore: cast_nullable_to_non_nullable
                  as bool,
        note: freezed == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
                  as String?,
        orgasmsMe: null == orgasmsMe
            ? _value.orgasmsMe
            : orgasmsMe // ignore: cast_nullable_to_non_nullable
                  as int,
        orgasmsPartner: null == orgasmsPartner
            ? _value.orgasmsPartner
            : orgasmsPartner // ignore: cast_nullable_to_non_nullable
                  as int,
        durationMinutes: freezed == durationMinutes
            ? _value.durationMinutes
            : durationMinutes // ignore: cast_nullable_to_non_nullable
                  as int?,
        location: freezed == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$IntimacyLogImpl implements _IntimacyLog {
  const _$IntimacyLogImpl({
    required this.id,
    @RequiredTimestampConverter() required this.date,
    required this.initiatorId,
    required this.rating,
    final List<String> tags = const [],
    required this.protectionUsed,
    this.note,
    this.orgasmsMe = 0,
    this.orgasmsPartner = 0,
    this.durationMinutes,
    this.location,
  }) : _tags = tags;

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
  @override
  final bool protectionUsed;
  @override
  final String? note;
  // Optional note
  @override
  @JsonKey()
  final int orgasmsMe;
  // Orgasm count for the user who created the log
  @override
  @JsonKey()
  final int orgasmsPartner;
  // Orgasm count for the partner
  @override
  final int? durationMinutes;
  // Duration in minutes (optional)
  @override
  final String? location;

  @override
  String toString() {
    return 'IntimacyLog(id: $id, date: $date, initiatorId: $initiatorId, rating: $rating, tags: $tags, protectionUsed: $protectionUsed, note: $note, orgasmsMe: $orgasmsMe, orgasmsPartner: $orgasmsPartner, durationMinutes: $durationMinutes, location: $location)';
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
            (identical(other.protectionUsed, protectionUsed) ||
                other.protectionUsed == protectionUsed) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.orgasmsMe, orgasmsMe) ||
                other.orgasmsMe == orgasmsMe) &&
            (identical(other.orgasmsPartner, orgasmsPartner) ||
                other.orgasmsPartner == orgasmsPartner) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.location, location) ||
                other.location == location));
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
    protectionUsed,
    note,
    orgasmsMe,
    orgasmsPartner,
    durationMinutes,
    location,
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
    required final bool protectionUsed,
    final String? note,
    final int orgasmsMe,
    final int orgasmsPartner,
    final int? durationMinutes,
    final String? location,
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
  bool get protectionUsed;
  @override
  String? get note; // Optional note
  @override
  int get orgasmsMe; // Orgasm count for the user who created the log
  @override
  int get orgasmsPartner; // Orgasm count for the partner
  @override
  int? get durationMinutes; // Duration in minutes (optional)
  @override
  String? get location;

  /// Create a copy of IntimacyLog
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$IntimacyLogImplCopyWith<_$IntimacyLogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

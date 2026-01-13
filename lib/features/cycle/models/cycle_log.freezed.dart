// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cycle_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CycleLog _$CycleLogFromJson(Map<String, dynamic> json) {
  return _CycleLog.fromJson(json);
}

/// @nodoc
mixin _$CycleLog {
  DateTime get date => throw _privateConstructorUsedError;
  FlowIntensity get flowIntensity => throw _privateConstructorUsedError;
  Mood get mood => throw _privateConstructorUsedError;

  /// Serializes this CycleLog to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CycleLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CycleLogCopyWith<CycleLog> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CycleLogCopyWith<$Res> {
  factory $CycleLogCopyWith(CycleLog value, $Res Function(CycleLog) then) =
      _$CycleLogCopyWithImpl<$Res, CycleLog>;
  @useResult
  $Res call({DateTime date, FlowIntensity flowIntensity, Mood mood});
}

/// @nodoc
class _$CycleLogCopyWithImpl<$Res, $Val extends CycleLog>
    implements $CycleLogCopyWith<$Res> {
  _$CycleLogCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CycleLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? flowIntensity = null,
    Object? mood = null,
  }) {
    return _then(
      _value.copyWith(
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            flowIntensity: null == flowIntensity
                ? _value.flowIntensity
                : flowIntensity // ignore: cast_nullable_to_non_nullable
                      as FlowIntensity,
            mood: null == mood
                ? _value.mood
                : mood // ignore: cast_nullable_to_non_nullable
                      as Mood,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CycleLogImplCopyWith<$Res>
    implements $CycleLogCopyWith<$Res> {
  factory _$$CycleLogImplCopyWith(
    _$CycleLogImpl value,
    $Res Function(_$CycleLogImpl) then,
  ) = __$$CycleLogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DateTime date, FlowIntensity flowIntensity, Mood mood});
}

/// @nodoc
class __$$CycleLogImplCopyWithImpl<$Res>
    extends _$CycleLogCopyWithImpl<$Res, _$CycleLogImpl>
    implements _$$CycleLogImplCopyWith<$Res> {
  __$$CycleLogImplCopyWithImpl(
    _$CycleLogImpl _value,
    $Res Function(_$CycleLogImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CycleLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? flowIntensity = null,
    Object? mood = null,
  }) {
    return _then(
      _$CycleLogImpl(
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        flowIntensity: null == flowIntensity
            ? _value.flowIntensity
            : flowIntensity // ignore: cast_nullable_to_non_nullable
                  as FlowIntensity,
        mood: null == mood
            ? _value.mood
            : mood // ignore: cast_nullable_to_non_nullable
                  as Mood,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$CycleLogImpl implements _CycleLog {
  const _$CycleLogImpl({
    required this.date,
    required this.flowIntensity,
    required this.mood,
  });

  factory _$CycleLogImpl.fromJson(Map<String, dynamic> json) =>
      _$$CycleLogImplFromJson(json);

  @override
  final DateTime date;
  @override
  final FlowIntensity flowIntensity;
  @override
  final Mood mood;

  @override
  String toString() {
    return 'CycleLog(date: $date, flowIntensity: $flowIntensity, mood: $mood)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CycleLogImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.flowIntensity, flowIntensity) ||
                other.flowIntensity == flowIntensity) &&
            (identical(other.mood, mood) || other.mood == mood));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, date, flowIntensity, mood);

  /// Create a copy of CycleLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CycleLogImplCopyWith<_$CycleLogImpl> get copyWith =>
      __$$CycleLogImplCopyWithImpl<_$CycleLogImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CycleLogImplToJson(this);
  }
}

abstract class _CycleLog implements CycleLog {
  const factory _CycleLog({
    required final DateTime date,
    required final FlowIntensity flowIntensity,
    required final Mood mood,
  }) = _$CycleLogImpl;

  factory _CycleLog.fromJson(Map<String, dynamic> json) =
      _$CycleLogImpl.fromJson;

  @override
  DateTime get date;
  @override
  FlowIntensity get flowIntensity;
  @override
  Mood get mood;

  /// Create a copy of CycleLog
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CycleLogImplCopyWith<_$CycleLogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

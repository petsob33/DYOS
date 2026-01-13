// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cycle_settings_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CycleSettings _$CycleSettingsFromJson(Map<String, dynamic> json) {
  return _CycleSettings.fromJson(json);
}

/// @nodoc
mixin _$CycleSettings {
  String get id => throw _privateConstructorUsedError;
  int get averageCycleLength => throw _privateConstructorUsedError;
  int get periodLength => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get lastPeriodDate => throw _privateConstructorUsedError;

  /// Serializes this CycleSettings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CycleSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CycleSettingsCopyWith<CycleSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CycleSettingsCopyWith<$Res> {
  factory $CycleSettingsCopyWith(
    CycleSettings value,
    $Res Function(CycleSettings) then,
  ) = _$CycleSettingsCopyWithImpl<$Res, CycleSettings>;
  @useResult
  $Res call({
    String id,
    int averageCycleLength,
    int periodLength,
    @TimestampConverter() DateTime? lastPeriodDate,
  });
}

/// @nodoc
class _$CycleSettingsCopyWithImpl<$Res, $Val extends CycleSettings>
    implements $CycleSettingsCopyWith<$Res> {
  _$CycleSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CycleSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? averageCycleLength = null,
    Object? periodLength = null,
    Object? lastPeriodDate = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            averageCycleLength: null == averageCycleLength
                ? _value.averageCycleLength
                : averageCycleLength // ignore: cast_nullable_to_non_nullable
                      as int,
            periodLength: null == periodLength
                ? _value.periodLength
                : periodLength // ignore: cast_nullable_to_non_nullable
                      as int,
            lastPeriodDate: freezed == lastPeriodDate
                ? _value.lastPeriodDate
                : lastPeriodDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CycleSettingsImplCopyWith<$Res>
    implements $CycleSettingsCopyWith<$Res> {
  factory _$$CycleSettingsImplCopyWith(
    _$CycleSettingsImpl value,
    $Res Function(_$CycleSettingsImpl) then,
  ) = __$$CycleSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    int averageCycleLength,
    int periodLength,
    @TimestampConverter() DateTime? lastPeriodDate,
  });
}

/// @nodoc
class __$$CycleSettingsImplCopyWithImpl<$Res>
    extends _$CycleSettingsCopyWithImpl<$Res, _$CycleSettingsImpl>
    implements _$$CycleSettingsImplCopyWith<$Res> {
  __$$CycleSettingsImplCopyWithImpl(
    _$CycleSettingsImpl _value,
    $Res Function(_$CycleSettingsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CycleSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? averageCycleLength = null,
    Object? periodLength = null,
    Object? lastPeriodDate = freezed,
  }) {
    return _then(
      _$CycleSettingsImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        averageCycleLength: null == averageCycleLength
            ? _value.averageCycleLength
            : averageCycleLength // ignore: cast_nullable_to_non_nullable
                  as int,
        periodLength: null == periodLength
            ? _value.periodLength
            : periodLength // ignore: cast_nullable_to_non_nullable
                  as int,
        lastPeriodDate: freezed == lastPeriodDate
            ? _value.lastPeriodDate
            : lastPeriodDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$CycleSettingsImpl implements _CycleSettings {
  const _$CycleSettingsImpl({
    required this.id,
    this.averageCycleLength = 28,
    this.periodLength = 5,
    @TimestampConverter() this.lastPeriodDate,
  });

  factory _$CycleSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$CycleSettingsImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey()
  final int averageCycleLength;
  @override
  @JsonKey()
  final int periodLength;
  @override
  @TimestampConverter()
  final DateTime? lastPeriodDate;

  @override
  String toString() {
    return 'CycleSettings(id: $id, averageCycleLength: $averageCycleLength, periodLength: $periodLength, lastPeriodDate: $lastPeriodDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CycleSettingsImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.averageCycleLength, averageCycleLength) ||
                other.averageCycleLength == averageCycleLength) &&
            (identical(other.periodLength, periodLength) ||
                other.periodLength == periodLength) &&
            (identical(other.lastPeriodDate, lastPeriodDate) ||
                other.lastPeriodDate == lastPeriodDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    averageCycleLength,
    periodLength,
    lastPeriodDate,
  );

  /// Create a copy of CycleSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CycleSettingsImplCopyWith<_$CycleSettingsImpl> get copyWith =>
      __$$CycleSettingsImplCopyWithImpl<_$CycleSettingsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CycleSettingsImplToJson(this);
  }
}

abstract class _CycleSettings implements CycleSettings {
  const factory _CycleSettings({
    required final String id,
    final int averageCycleLength,
    final int periodLength,
    @TimestampConverter() final DateTime? lastPeriodDate,
  }) = _$CycleSettingsImpl;

  factory _CycleSettings.fromJson(Map<String, dynamic> json) =
      _$CycleSettingsImpl.fromJson;

  @override
  String get id;
  @override
  int get averageCycleLength;
  @override
  int get periodLength;
  @override
  @TimestampConverter()
  DateTime? get lastPeriodDate;

  /// Create a copy of CycleSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CycleSettingsImplCopyWith<_$CycleSettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

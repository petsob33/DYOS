// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'blueprint_question.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BlueprintQuestion _$BlueprintQuestionFromJson(Map<String, dynamic> json) {
  return _BlueprintQuestion.fromJson(json);
}

/// @nodoc
mixin _$BlueprintQuestion {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  BlueprintQuestionType get type => throw _privateConstructorUsedError;

  /// Slider: left label (e.g. "Relax").
  String? get sliderLeftLabel => throw _privateConstructorUsedError;

  /// Slider: right label (e.g. "Adventure").
  String? get sliderRightLabel => throw _privateConstructorUsedError;

  /// Choice chips / multiSelect: list of options.
  List<String>? get options => throw _privateConstructorUsedError;

  /// Measurement: suffix shown after input (e.g. "US" for ring size).
  String? get measurementSuffix => throw _privateConstructorUsedError;

  /// Measurement: optional placeholder.
  String? get measurementPlaceholder => throw _privateConstructorUsedError;

  /// Serializes this BlueprintQuestion to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BlueprintQuestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BlueprintQuestionCopyWith<BlueprintQuestion> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BlueprintQuestionCopyWith<$Res> {
  factory $BlueprintQuestionCopyWith(
    BlueprintQuestion value,
    $Res Function(BlueprintQuestion) then,
  ) = _$BlueprintQuestionCopyWithImpl<$Res, BlueprintQuestion>;
  @useResult
  $Res call({
    String id,
    String title,
    BlueprintQuestionType type,
    String? sliderLeftLabel,
    String? sliderRightLabel,
    List<String>? options,
    String? measurementSuffix,
    String? measurementPlaceholder,
  });
}

/// @nodoc
class _$BlueprintQuestionCopyWithImpl<$Res, $Val extends BlueprintQuestion>
    implements $BlueprintQuestionCopyWith<$Res> {
  _$BlueprintQuestionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BlueprintQuestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? type = null,
    Object? sliderLeftLabel = freezed,
    Object? sliderRightLabel = freezed,
    Object? options = freezed,
    Object? measurementSuffix = freezed,
    Object? measurementPlaceholder = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as BlueprintQuestionType,
            sliderLeftLabel: freezed == sliderLeftLabel
                ? _value.sliderLeftLabel
                : sliderLeftLabel // ignore: cast_nullable_to_non_nullable
                      as String?,
            sliderRightLabel: freezed == sliderRightLabel
                ? _value.sliderRightLabel
                : sliderRightLabel // ignore: cast_nullable_to_non_nullable
                      as String?,
            options: freezed == options
                ? _value.options
                : options // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            measurementSuffix: freezed == measurementSuffix
                ? _value.measurementSuffix
                : measurementSuffix // ignore: cast_nullable_to_non_nullable
                      as String?,
            measurementPlaceholder: freezed == measurementPlaceholder
                ? _value.measurementPlaceholder
                : measurementPlaceholder // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BlueprintQuestionImplCopyWith<$Res>
    implements $BlueprintQuestionCopyWith<$Res> {
  factory _$$BlueprintQuestionImplCopyWith(
    _$BlueprintQuestionImpl value,
    $Res Function(_$BlueprintQuestionImpl) then,
  ) = __$$BlueprintQuestionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    BlueprintQuestionType type,
    String? sliderLeftLabel,
    String? sliderRightLabel,
    List<String>? options,
    String? measurementSuffix,
    String? measurementPlaceholder,
  });
}

/// @nodoc
class __$$BlueprintQuestionImplCopyWithImpl<$Res>
    extends _$BlueprintQuestionCopyWithImpl<$Res, _$BlueprintQuestionImpl>
    implements _$$BlueprintQuestionImplCopyWith<$Res> {
  __$$BlueprintQuestionImplCopyWithImpl(
    _$BlueprintQuestionImpl _value,
    $Res Function(_$BlueprintQuestionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BlueprintQuestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? type = null,
    Object? sliderLeftLabel = freezed,
    Object? sliderRightLabel = freezed,
    Object? options = freezed,
    Object? measurementSuffix = freezed,
    Object? measurementPlaceholder = freezed,
  }) {
    return _then(
      _$BlueprintQuestionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as BlueprintQuestionType,
        sliderLeftLabel: freezed == sliderLeftLabel
            ? _value.sliderLeftLabel
            : sliderLeftLabel // ignore: cast_nullable_to_non_nullable
                  as String?,
        sliderRightLabel: freezed == sliderRightLabel
            ? _value.sliderRightLabel
            : sliderRightLabel // ignore: cast_nullable_to_non_nullable
                  as String?,
        options: freezed == options
            ? _value._options
            : options // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        measurementSuffix: freezed == measurementSuffix
            ? _value.measurementSuffix
            : measurementSuffix // ignore: cast_nullable_to_non_nullable
                  as String?,
        measurementPlaceholder: freezed == measurementPlaceholder
            ? _value.measurementPlaceholder
            : measurementPlaceholder // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BlueprintQuestionImpl implements _BlueprintQuestion {
  const _$BlueprintQuestionImpl({
    required this.id,
    required this.title,
    required this.type,
    this.sliderLeftLabel,
    this.sliderRightLabel,
    final List<String>? options,
    this.measurementSuffix,
    this.measurementPlaceholder,
  }) : _options = options;

  factory _$BlueprintQuestionImpl.fromJson(Map<String, dynamic> json) =>
      _$$BlueprintQuestionImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final BlueprintQuestionType type;

  /// Slider: left label (e.g. "Relax").
  @override
  final String? sliderLeftLabel;

  /// Slider: right label (e.g. "Adventure").
  @override
  final String? sliderRightLabel;

  /// Choice chips / multiSelect: list of options.
  final List<String>? _options;

  /// Choice chips / multiSelect: list of options.
  @override
  List<String>? get options {
    final value = _options;
    if (value == null) return null;
    if (_options is EqualUnmodifiableListView) return _options;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  /// Measurement: suffix shown after input (e.g. "US" for ring size).
  @override
  final String? measurementSuffix;

  /// Measurement: optional placeholder.
  @override
  final String? measurementPlaceholder;

  @override
  String toString() {
    return 'BlueprintQuestion(id: $id, title: $title, type: $type, sliderLeftLabel: $sliderLeftLabel, sliderRightLabel: $sliderRightLabel, options: $options, measurementSuffix: $measurementSuffix, measurementPlaceholder: $measurementPlaceholder)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BlueprintQuestionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.sliderLeftLabel, sliderLeftLabel) ||
                other.sliderLeftLabel == sliderLeftLabel) &&
            (identical(other.sliderRightLabel, sliderRightLabel) ||
                other.sliderRightLabel == sliderRightLabel) &&
            const DeepCollectionEquality().equals(other._options, _options) &&
            (identical(other.measurementSuffix, measurementSuffix) ||
                other.measurementSuffix == measurementSuffix) &&
            (identical(other.measurementPlaceholder, measurementPlaceholder) ||
                other.measurementPlaceholder == measurementPlaceholder));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    type,
    sliderLeftLabel,
    sliderRightLabel,
    const DeepCollectionEquality().hash(_options),
    measurementSuffix,
    measurementPlaceholder,
  );

  /// Create a copy of BlueprintQuestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BlueprintQuestionImplCopyWith<_$BlueprintQuestionImpl> get copyWith =>
      __$$BlueprintQuestionImplCopyWithImpl<_$BlueprintQuestionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$BlueprintQuestionImplToJson(this);
  }
}

abstract class _BlueprintQuestion implements BlueprintQuestion {
  const factory _BlueprintQuestion({
    required final String id,
    required final String title,
    required final BlueprintQuestionType type,
    final String? sliderLeftLabel,
    final String? sliderRightLabel,
    final List<String>? options,
    final String? measurementSuffix,
    final String? measurementPlaceholder,
  }) = _$BlueprintQuestionImpl;

  factory _BlueprintQuestion.fromJson(Map<String, dynamic> json) =
      _$BlueprintQuestionImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  BlueprintQuestionType get type;

  /// Slider: left label (e.g. "Relax").
  @override
  String? get sliderLeftLabel;

  /// Slider: right label (e.g. "Adventure").
  @override
  String? get sliderRightLabel;

  /// Choice chips / multiSelect: list of options.
  @override
  List<String>? get options;

  /// Measurement: suffix shown after input (e.g. "US" for ring size).
  @override
  String? get measurementSuffix;

  /// Measurement: optional placeholder.
  @override
  String? get measurementPlaceholder;

  /// Create a copy of BlueprintQuestion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BlueprintQuestionImplCopyWith<_$BlueprintQuestionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'blueprint_section.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BlueprintSection _$BlueprintSectionFromJson(Map<String, dynamic> json) {
  return _BlueprintSection.fromJson(json);
}

/// @nodoc
mixin _$BlueprintSection {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get emoji => throw _privateConstructorUsedError;
  int get order => throw _privateConstructorUsedError;
  List<BlueprintQuestion> get questions => throw _privateConstructorUsedError;

  /// Serializes this BlueprintSection to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BlueprintSection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BlueprintSectionCopyWith<BlueprintSection> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BlueprintSectionCopyWith<$Res> {
  factory $BlueprintSectionCopyWith(
    BlueprintSection value,
    $Res Function(BlueprintSection) then,
  ) = _$BlueprintSectionCopyWithImpl<$Res, BlueprintSection>;
  @useResult
  $Res call({
    String id,
    String title,
    String emoji,
    int order,
    List<BlueprintQuestion> questions,
  });
}

/// @nodoc
class _$BlueprintSectionCopyWithImpl<$Res, $Val extends BlueprintSection>
    implements $BlueprintSectionCopyWith<$Res> {
  _$BlueprintSectionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BlueprintSection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? emoji = null,
    Object? order = null,
    Object? questions = null,
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
            emoji: null == emoji
                ? _value.emoji
                : emoji // ignore: cast_nullable_to_non_nullable
                      as String,
            order: null == order
                ? _value.order
                : order // ignore: cast_nullable_to_non_nullable
                      as int,
            questions: null == questions
                ? _value.questions
                : questions // ignore: cast_nullable_to_non_nullable
                      as List<BlueprintQuestion>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BlueprintSectionImplCopyWith<$Res>
    implements $BlueprintSectionCopyWith<$Res> {
  factory _$$BlueprintSectionImplCopyWith(
    _$BlueprintSectionImpl value,
    $Res Function(_$BlueprintSectionImpl) then,
  ) = __$$BlueprintSectionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String emoji,
    int order,
    List<BlueprintQuestion> questions,
  });
}

/// @nodoc
class __$$BlueprintSectionImplCopyWithImpl<$Res>
    extends _$BlueprintSectionCopyWithImpl<$Res, _$BlueprintSectionImpl>
    implements _$$BlueprintSectionImplCopyWith<$Res> {
  __$$BlueprintSectionImplCopyWithImpl(
    _$BlueprintSectionImpl _value,
    $Res Function(_$BlueprintSectionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BlueprintSection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? emoji = null,
    Object? order = null,
    Object? questions = null,
  }) {
    return _then(
      _$BlueprintSectionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        emoji: null == emoji
            ? _value.emoji
            : emoji // ignore: cast_nullable_to_non_nullable
                  as String,
        order: null == order
            ? _value.order
            : order // ignore: cast_nullable_to_non_nullable
                  as int,
        questions: null == questions
            ? _value._questions
            : questions // ignore: cast_nullable_to_non_nullable
                  as List<BlueprintQuestion>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BlueprintSectionImpl implements _BlueprintSection {
  const _$BlueprintSectionImpl({
    required this.id,
    required this.title,
    required this.emoji,
    this.order = 0,
    required final List<BlueprintQuestion> questions,
  }) : _questions = questions;

  factory _$BlueprintSectionImpl.fromJson(Map<String, dynamic> json) =>
      _$$BlueprintSectionImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String emoji;
  @override
  @JsonKey()
  final int order;
  final List<BlueprintQuestion> _questions;
  @override
  List<BlueprintQuestion> get questions {
    if (_questions is EqualUnmodifiableListView) return _questions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_questions);
  }

  @override
  String toString() {
    return 'BlueprintSection(id: $id, title: $title, emoji: $emoji, order: $order, questions: $questions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BlueprintSectionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.emoji, emoji) || other.emoji == emoji) &&
            (identical(other.order, order) || other.order == order) &&
            const DeepCollectionEquality().equals(
              other._questions,
              _questions,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    emoji,
    order,
    const DeepCollectionEquality().hash(_questions),
  );

  /// Create a copy of BlueprintSection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BlueprintSectionImplCopyWith<_$BlueprintSectionImpl> get copyWith =>
      __$$BlueprintSectionImplCopyWithImpl<_$BlueprintSectionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$BlueprintSectionImplToJson(this);
  }
}

abstract class _BlueprintSection implements BlueprintSection {
  const factory _BlueprintSection({
    required final String id,
    required final String title,
    required final String emoji,
    final int order,
    required final List<BlueprintQuestion> questions,
  }) = _$BlueprintSectionImpl;

  factory _BlueprintSection.fromJson(Map<String, dynamic> json) =
      _$BlueprintSectionImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get emoji;
  @override
  int get order;
  @override
  List<BlueprintQuestion> get questions;

  /// Create a copy of BlueprintSection
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BlueprintSectionImplCopyWith<_$BlueprintSectionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'note_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

NoteItem _$NoteItemFromJson(Map<String, dynamic> json) {
  return _NoteItem.fromJson(json);
}

/// @nodoc
mixin _$NoteItem {
  String get id => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  @RequiredTimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  @NoteTypeConverter()
  NoteType get type => throw _privateConstructorUsedError;
  String get authorId => throw _privateConstructorUsedError;

  /// Serializes this NoteItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NoteItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NoteItemCopyWith<NoteItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NoteItemCopyWith<$Res> {
  factory $NoteItemCopyWith(NoteItem value, $Res Function(NoteItem) then) =
      _$NoteItemCopyWithImpl<$Res, NoteItem>;
  @useResult
  $Res call({
    String id,
    String content,
    String? title,
    @RequiredTimestampConverter() DateTime createdAt,
    @NoteTypeConverter() NoteType type,
    String authorId,
  });
}

/// @nodoc
class _$NoteItemCopyWithImpl<$Res, $Val extends NoteItem>
    implements $NoteItemCopyWith<$Res> {
  _$NoteItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NoteItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? content = null,
    Object? title = freezed,
    Object? createdAt = null,
    Object? type = null,
    Object? authorId = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            title: freezed == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as NoteType,
            authorId: null == authorId
                ? _value.authorId
                : authorId // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NoteItemImplCopyWith<$Res>
    implements $NoteItemCopyWith<$Res> {
  factory _$$NoteItemImplCopyWith(
    _$NoteItemImpl value,
    $Res Function(_$NoteItemImpl) then,
  ) = __$$NoteItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String content,
    String? title,
    @RequiredTimestampConverter() DateTime createdAt,
    @NoteTypeConverter() NoteType type,
    String authorId,
  });
}

/// @nodoc
class __$$NoteItemImplCopyWithImpl<$Res>
    extends _$NoteItemCopyWithImpl<$Res, _$NoteItemImpl>
    implements _$$NoteItemImplCopyWith<$Res> {
  __$$NoteItemImplCopyWithImpl(
    _$NoteItemImpl _value,
    $Res Function(_$NoteItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NoteItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? content = null,
    Object? title = freezed,
    Object? createdAt = null,
    Object? type = null,
    Object? authorId = null,
  }) {
    return _then(
      _$NoteItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        title: freezed == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as NoteType,
        authorId: null == authorId
            ? _value.authorId
            : authorId // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$NoteItemImpl implements _NoteItem {
  const _$NoteItemImpl({
    required this.id,
    required this.content,
    this.title,
    @RequiredTimestampConverter() required this.createdAt,
    @NoteTypeConverter() required this.type,
    required this.authorId,
  });

  factory _$NoteItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$NoteItemImplFromJson(json);

  @override
  final String id;
  @override
  final String content;
  @override
  final String? title;
  @override
  @RequiredTimestampConverter()
  final DateTime createdAt;
  @override
  @NoteTypeConverter()
  final NoteType type;
  @override
  final String authorId;

  @override
  String toString() {
    return 'NoteItem(id: $id, content: $content, title: $title, createdAt: $createdAt, type: $type, authorId: $authorId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NoteItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.authorId, authorId) ||
                other.authorId == authorId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, content, title, createdAt, type, authorId);

  /// Create a copy of NoteItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NoteItemImplCopyWith<_$NoteItemImpl> get copyWith =>
      __$$NoteItemImplCopyWithImpl<_$NoteItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NoteItemImplToJson(this);
  }
}

abstract class _NoteItem implements NoteItem {
  const factory _NoteItem({
    required final String id,
    required final String content,
    final String? title,
    @RequiredTimestampConverter() required final DateTime createdAt,
    @NoteTypeConverter() required final NoteType type,
    required final String authorId,
  }) = _$NoteItemImpl;

  factory _NoteItem.fromJson(Map<String, dynamic> json) =
      _$NoteItemImpl.fromJson;

  @override
  String get id;
  @override
  String get content;
  @override
  String? get title;
  @override
  @RequiredTimestampConverter()
  DateTime get createdAt;
  @override
  @NoteTypeConverter()
  NoteType get type;
  @override
  String get authorId;

  /// Create a copy of NoteItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NoteItemImplCopyWith<_$NoteItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

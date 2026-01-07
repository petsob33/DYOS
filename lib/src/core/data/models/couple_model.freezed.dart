// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'couple_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CoupleModel _$CoupleModelFromJson(Map<String, dynamic> json) {
  return _CoupleModel.fromJson(json);
}

/// @nodoc
mixin _$CoupleModel {
  String get id => throw _privateConstructorUsedError;
  List<String> get members =>
      throw _privateConstructorUsedError; // Array of user UIDs
  DateTime? get anniversaryDate => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this CoupleModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CoupleModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CoupleModelCopyWith<CoupleModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CoupleModelCopyWith<$Res> {
  factory $CoupleModelCopyWith(
    CoupleModel value,
    $Res Function(CoupleModel) then,
  ) = _$CoupleModelCopyWithImpl<$Res, CoupleModel>;
  @useResult
  $Res call({
    String id,
    List<String> members,
    DateTime? anniversaryDate,
    @TimestampConverter() DateTime? createdAt,
  });
}

/// @nodoc
class _$CoupleModelCopyWithImpl<$Res, $Val extends CoupleModel>
    implements $CoupleModelCopyWith<$Res> {
  _$CoupleModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CoupleModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? members = null,
    Object? anniversaryDate = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            members: null == members
                ? _value.members
                : members // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            anniversaryDate: freezed == anniversaryDate
                ? _value.anniversaryDate
                : anniversaryDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CoupleModelImplCopyWith<$Res>
    implements $CoupleModelCopyWith<$Res> {
  factory _$$CoupleModelImplCopyWith(
    _$CoupleModelImpl value,
    $Res Function(_$CoupleModelImpl) then,
  ) = __$$CoupleModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    List<String> members,
    DateTime? anniversaryDate,
    @TimestampConverter() DateTime? createdAt,
  });
}

/// @nodoc
class __$$CoupleModelImplCopyWithImpl<$Res>
    extends _$CoupleModelCopyWithImpl<$Res, _$CoupleModelImpl>
    implements _$$CoupleModelImplCopyWith<$Res> {
  __$$CoupleModelImplCopyWithImpl(
    _$CoupleModelImpl _value,
    $Res Function(_$CoupleModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CoupleModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? members = null,
    Object? anniversaryDate = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$CoupleModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        members: null == members
            ? _value._members
            : members // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        anniversaryDate: freezed == anniversaryDate
            ? _value.anniversaryDate
            : anniversaryDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$CoupleModelImpl implements _CoupleModel {
  const _$CoupleModelImpl({
    required this.id,
    required final List<String> members,
    this.anniversaryDate,
    @TimestampConverter() this.createdAt,
  }) : _members = members;

  factory _$CoupleModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CoupleModelImplFromJson(json);

  @override
  final String id;
  final List<String> _members;
  @override
  List<String> get members {
    if (_members is EqualUnmodifiableListView) return _members;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_members);
  }

  // Array of user UIDs
  @override
  final DateTime? anniversaryDate;
  @override
  @TimestampConverter()
  final DateTime? createdAt;

  @override
  String toString() {
    return 'CoupleModel(id: $id, members: $members, anniversaryDate: $anniversaryDate, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CoupleModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            const DeepCollectionEquality().equals(other._members, _members) &&
            (identical(other.anniversaryDate, anniversaryDate) ||
                other.anniversaryDate == anniversaryDate) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    const DeepCollectionEquality().hash(_members),
    anniversaryDate,
    createdAt,
  );

  /// Create a copy of CoupleModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CoupleModelImplCopyWith<_$CoupleModelImpl> get copyWith =>
      __$$CoupleModelImplCopyWithImpl<_$CoupleModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CoupleModelImplToJson(this);
  }
}

abstract class _CoupleModel implements CoupleModel {
  const factory _CoupleModel({
    required final String id,
    required final List<String> members,
    final DateTime? anniversaryDate,
    @TimestampConverter() final DateTime? createdAt,
  }) = _$CoupleModelImpl;

  factory _CoupleModel.fromJson(Map<String, dynamic> json) =
      _$CoupleModelImpl.fromJson;

  @override
  String get id;
  @override
  List<String> get members; // Array of user UIDs
  @override
  DateTime? get anniversaryDate;
  @override
  @TimestampConverter()
  DateTime? get createdAt;

  /// Create a copy of CoupleModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CoupleModelImplCopyWith<_$CoupleModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

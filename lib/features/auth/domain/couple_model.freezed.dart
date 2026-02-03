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
  @JsonKey(includeFromJson: true, includeToJson: false)
  String get id => throw _privateConstructorUsedError;
  List<String> get members =>
      throw _privateConstructorUsedError; // Array of user UIDs (important for Security Rules!)
  DateTime? get anniversaryDate =>
      throw _privateConstructorUsedError; // For counting days together
  @TimestampConverter()
  DateTime? get createdAt => throw _privateConstructorUsedError; // Subscription fields
  String get subscriptionTier =>
      throw _privateConstructorUsedError; // "free" | "premium" | "trial"
  @TimestampConverter()
  DateTime? get subscriptionExpiry => throw _privateConstructorUsedError; // When premium subscription ends
  // Status widget data - stored here to avoid reading extra documents on app start
  // Key is user UID, value is their status (emoji + text)
  Map<String, CoupleStatus>? get status => throw _privateConstructorUsedError;

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
    @JsonKey(includeFromJson: true, includeToJson: false) String id,
    List<String> members,
    DateTime? anniversaryDate,
    @TimestampConverter() DateTime? createdAt,
    String subscriptionTier,
    @TimestampConverter() DateTime? subscriptionExpiry,
    Map<String, CoupleStatus>? status,
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
    Object? subscriptionTier = null,
    Object? subscriptionExpiry = freezed,
    Object? status = freezed,
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
            subscriptionTier: null == subscriptionTier
                ? _value.subscriptionTier
                : subscriptionTier // ignore: cast_nullable_to_non_nullable
                      as String,
            subscriptionExpiry: freezed == subscriptionExpiry
                ? _value.subscriptionExpiry
                : subscriptionExpiry // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            status: freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as Map<String, CoupleStatus>?,
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
    @JsonKey(includeFromJson: true, includeToJson: false) String id,
    List<String> members,
    DateTime? anniversaryDate,
    @TimestampConverter() DateTime? createdAt,
    String subscriptionTier,
    @TimestampConverter() DateTime? subscriptionExpiry,
    Map<String, CoupleStatus>? status,
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
    Object? subscriptionTier = null,
    Object? subscriptionExpiry = freezed,
    Object? status = freezed,
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
        subscriptionTier: null == subscriptionTier
            ? _value.subscriptionTier
            : subscriptionTier // ignore: cast_nullable_to_non_nullable
                  as String,
        subscriptionExpiry: freezed == subscriptionExpiry
            ? _value.subscriptionExpiry
            : subscriptionExpiry // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        status: freezed == status
            ? _value._status
            : status // ignore: cast_nullable_to_non_nullable
                  as Map<String, CoupleStatus>?,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$CoupleModelImpl extends _CoupleModel {
  const _$CoupleModelImpl({
    @JsonKey(includeFromJson: true, includeToJson: false) required this.id,
    required final List<String> members,
    this.anniversaryDate,
    @TimestampConverter() this.createdAt,
    this.subscriptionTier = 'free',
    @TimestampConverter() this.subscriptionExpiry,
    final Map<String, CoupleStatus>? status,
  }) : _members = members,
       _status = status,
       super._();

  factory _$CoupleModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CoupleModelImplFromJson(json);

  @override
  @JsonKey(includeFromJson: true, includeToJson: false)
  final String id;
  final List<String> _members;
  @override
  List<String> get members {
    if (_members is EqualUnmodifiableListView) return _members;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_members);
  }

  // Array of user UIDs (important for Security Rules!)
  @override
  final DateTime? anniversaryDate;
  // For counting days together
  @override
  @TimestampConverter()
  final DateTime? createdAt;
  // Subscription fields
  @override
  @JsonKey()
  final String subscriptionTier;
  // "free" | "premium" | "trial"
  @override
  @TimestampConverter()
  final DateTime? subscriptionExpiry;
  // When premium subscription ends
  // Status widget data - stored here to avoid reading extra documents on app start
  // Key is user UID, value is their status (emoji + text)
  final Map<String, CoupleStatus>? _status;
  // When premium subscription ends
  // Status widget data - stored here to avoid reading extra documents on app start
  // Key is user UID, value is their status (emoji + text)
  @override
  Map<String, CoupleStatus>? get status {
    final value = _status;
    if (value == null) return null;
    if (_status is EqualUnmodifiableMapView) return _status;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'CoupleModel(id: $id, members: $members, anniversaryDate: $anniversaryDate, createdAt: $createdAt, subscriptionTier: $subscriptionTier, subscriptionExpiry: $subscriptionExpiry, status: $status)';
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
                other.createdAt == createdAt) &&
            (identical(other.subscriptionTier, subscriptionTier) ||
                other.subscriptionTier == subscriptionTier) &&
            (identical(other.subscriptionExpiry, subscriptionExpiry) ||
                other.subscriptionExpiry == subscriptionExpiry) &&
            const DeepCollectionEquality().equals(other._status, _status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    const DeepCollectionEquality().hash(_members),
    anniversaryDate,
    createdAt,
    subscriptionTier,
    subscriptionExpiry,
    const DeepCollectionEquality().hash(_status),
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

abstract class _CoupleModel extends CoupleModel {
  const factory _CoupleModel({
    @JsonKey(includeFromJson: true, includeToJson: false)
    required final String id,
    required final List<String> members,
    final DateTime? anniversaryDate,
    @TimestampConverter() final DateTime? createdAt,
    final String subscriptionTier,
    @TimestampConverter() final DateTime? subscriptionExpiry,
    final Map<String, CoupleStatus>? status,
  }) = _$CoupleModelImpl;
  const _CoupleModel._() : super._();

  factory _CoupleModel.fromJson(Map<String, dynamic> json) =
      _$CoupleModelImpl.fromJson;

  @override
  @JsonKey(includeFromJson: true, includeToJson: false)
  String get id;
  @override
  List<String> get members; // Array of user UIDs (important for Security Rules!)
  @override
  DateTime? get anniversaryDate; // For counting days together
  @override
  @TimestampConverter()
  DateTime? get createdAt; // Subscription fields
  @override
  String get subscriptionTier; // "free" | "premium" | "trial"
  @override
  @TimestampConverter()
  DateTime? get subscriptionExpiry; // When premium subscription ends
  // Status widget data - stored here to avoid reading extra documents on app start
  // Key is user UID, value is their status (emoji + text)
  @override
  Map<String, CoupleStatus>? get status;

  /// Create a copy of CoupleModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CoupleModelImplCopyWith<_$CoupleModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CoupleStatus _$CoupleStatusFromJson(Map<String, dynamic> json) {
  return _CoupleStatus.fromJson(json);
}

/// @nodoc
mixin _$CoupleStatus {
  String get emoji => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this CoupleStatus to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CoupleStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CoupleStatusCopyWith<CoupleStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CoupleStatusCopyWith<$Res> {
  factory $CoupleStatusCopyWith(
    CoupleStatus value,
    $Res Function(CoupleStatus) then,
  ) = _$CoupleStatusCopyWithImpl<$Res, CoupleStatus>;
  @useResult
  $Res call({
    String emoji,
    String text,
    @TimestampConverter() DateTime? updatedAt,
  });
}

/// @nodoc
class _$CoupleStatusCopyWithImpl<$Res, $Val extends CoupleStatus>
    implements $CoupleStatusCopyWith<$Res> {
  _$CoupleStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CoupleStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? emoji = null,
    Object? text = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            emoji: null == emoji
                ? _value.emoji
                : emoji // ignore: cast_nullable_to_non_nullable
                      as String,
            text: null == text
                ? _value.text
                : text // ignore: cast_nullable_to_non_nullable
                      as String,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CoupleStatusImplCopyWith<$Res>
    implements $CoupleStatusCopyWith<$Res> {
  factory _$$CoupleStatusImplCopyWith(
    _$CoupleStatusImpl value,
    $Res Function(_$CoupleStatusImpl) then,
  ) = __$$CoupleStatusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String emoji,
    String text,
    @TimestampConverter() DateTime? updatedAt,
  });
}

/// @nodoc
class __$$CoupleStatusImplCopyWithImpl<$Res>
    extends _$CoupleStatusCopyWithImpl<$Res, _$CoupleStatusImpl>
    implements _$$CoupleStatusImplCopyWith<$Res> {
  __$$CoupleStatusImplCopyWithImpl(
    _$CoupleStatusImpl _value,
    $Res Function(_$CoupleStatusImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CoupleStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? emoji = null,
    Object? text = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$CoupleStatusImpl(
        emoji: null == emoji
            ? _value.emoji
            : emoji // ignore: cast_nullable_to_non_nullable
                  as String,
        text: null == text
            ? _value.text
            : text // ignore: cast_nullable_to_non_nullable
                  as String,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$CoupleStatusImpl implements _CoupleStatus {
  const _$CoupleStatusImpl({
    required this.emoji,
    required this.text,
    @TimestampConverter() this.updatedAt,
  });

  factory _$CoupleStatusImpl.fromJson(Map<String, dynamic> json) =>
      _$$CoupleStatusImplFromJson(json);

  @override
  final String emoji;
  @override
  final String text;
  @override
  @TimestampConverter()
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'CoupleStatus(emoji: $emoji, text: $text, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CoupleStatusImpl &&
            (identical(other.emoji, emoji) || other.emoji == emoji) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, emoji, text, updatedAt);

  /// Create a copy of CoupleStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CoupleStatusImplCopyWith<_$CoupleStatusImpl> get copyWith =>
      __$$CoupleStatusImplCopyWithImpl<_$CoupleStatusImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CoupleStatusImplToJson(this);
  }
}

abstract class _CoupleStatus implements CoupleStatus {
  const factory _CoupleStatus({
    required final String emoji,
    required final String text,
    @TimestampConverter() final DateTime? updatedAt,
  }) = _$CoupleStatusImpl;

  factory _CoupleStatus.fromJson(Map<String, dynamic> json) =
      _$CoupleStatusImpl.fromJson;

  @override
  String get emoji;
  @override
  String get text;
  @override
  @TimestampConverter()
  DateTime? get updatedAt;

  /// Create a copy of CoupleStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CoupleStatusImplCopyWith<_$CoupleStatusImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

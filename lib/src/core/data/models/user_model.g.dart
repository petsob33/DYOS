// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserModelImpl _$$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      inviteCode: json['inviteCode'] as String?,
      coupleId: json['coupleId'] as String?,
      dateOfBirth: json['dateOfBirth'] == null
          ? null
          : DateTime.parse(json['dateOfBirth'] as String),
      status: json['status'] == null
          ? null
          : UserStatus.fromJson(json['status'] as Map<String, dynamic>),
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'email': instance.email,
      'displayName': instance.displayName,
      'photoUrl': instance.photoUrl,
      'inviteCode': instance.inviteCode,
      'coupleId': instance.coupleId,
      'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
      'status': instance.status?.toJson(),
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
    };

_$UserStatusImpl _$$UserStatusImplFromJson(Map<String, dynamic> json) =>
    _$UserStatusImpl(
      emoji: json['emoji'] as String,
      text: json['text'] as String,
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
    );

Map<String, dynamic> _$$UserStatusImplToJson(_$UserStatusImpl instance) =>
    <String, dynamic>{
      'emoji': instance.emoji,
      'text': instance.text,
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
    };

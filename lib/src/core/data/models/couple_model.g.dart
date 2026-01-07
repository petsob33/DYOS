// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'couple_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CoupleModelImpl _$$CoupleModelImplFromJson(Map<String, dynamic> json) =>
    _$CoupleModelImpl(
      id: json['id'] as String,
      members: (json['members'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      anniversaryDate: json['anniversaryDate'] == null
          ? null
          : DateTime.parse(json['anniversaryDate'] as String),
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
    );

Map<String, dynamic> _$$CoupleModelImplToJson(_$CoupleModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'members': instance.members,
      'anniversaryDate': instance.anniversaryDate?.toIso8601String(),
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'couple_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CoupleModelImpl _$$CoupleModelImplFromJson(
  Map<String, dynamic> json,
) => _$CoupleModelImpl(
  id: json['id'] as String,
  members: (json['members'] as List<dynamic>).map((e) => e as String).toList(),
  anniversaryDate: json['anniversaryDate'] == null
      ? null
      : DateTime.parse(json['anniversaryDate'] as String),
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
  subscriptionTier: json['subscriptionTier'] as String? ?? 'free',
  subscriptionExpiry: const TimestampConverter().fromJson(
    json['subscriptionExpiry'],
  ),
  status: (json['status'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, CoupleStatus.fromJson(e as Map<String, dynamic>)),
  ),
  xp: (json['xp'] as num?)?.toInt() ?? 0,
  blueprintAnswers: json['blueprintAnswers'] as Map<String, dynamic>?,
  completedBlueprintSections:
      (json['completedBlueprintSections'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
  questXpLastGrantedAt: (json['questXpLastGrantedAt'] as Map<String, dynamic>?)
      ?.map((k, e) => MapEntry(k, e as String)),
);

Map<String, dynamic> _$$CoupleModelImplToJson(_$CoupleModelImpl instance) =>
    <String, dynamic>{
      'members': instance.members,
      'anniversaryDate': instance.anniversaryDate?.toIso8601String(),
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'subscriptionTier': instance.subscriptionTier,
      'subscriptionExpiry': const TimestampConverter().toJson(
        instance.subscriptionExpiry,
      ),
      'status': instance.status?.map((k, e) => MapEntry(k, e.toJson())),
      'xp': instance.xp,
      'blueprintAnswers': instance.blueprintAnswers,
      'completedBlueprintSections': instance.completedBlueprintSections,
      'questXpLastGrantedAt': instance.questXpLastGrantedAt,
    };

_$CoupleStatusImpl _$$CoupleStatusImplFromJson(Map<String, dynamic> json) =>
    _$CoupleStatusImpl(
      emoji: json['emoji'] as String,
      text: json['text'] as String,
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
    );

Map<String, dynamic> _$$CoupleStatusImplToJson(_$CoupleStatusImpl instance) =>
    <String, dynamic>{
      'emoji': instance.emoji,
      'text': instance.text,
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
    };

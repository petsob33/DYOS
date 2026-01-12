// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'intimacy_log_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$IntimacyLogImpl _$$IntimacyLogImplFromJson(Map<String, dynamic> json) =>
    _$IntimacyLogImpl(
      id: json['id'] as String,
      date: const RequiredTimestampConverter().fromJson(json['date']),
      initiatorId: json['initiatorId'] as String,
      rating: (json['rating'] as num).toInt(),
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      protectionUsed: json['protectionUsed'] as bool,
      note: json['note'] as String?,
    );

Map<String, dynamic> _$$IntimacyLogImplToJson(_$IntimacyLogImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': const RequiredTimestampConverter().toJson(instance.date),
      'initiatorId': instance.initiatorId,
      'rating': instance.rating,
      'tags': instance.tags,
      'protectionUsed': instance.protectionUsed,
      'note': instance.note,
    };

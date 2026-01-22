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
      positions:
          (json['positions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      userOrgasmCount: (json['userOrgasmCount'] as num?)?.toInt() ?? 0,
      partnerOrgasmCount: (json['partnerOrgasmCount'] as num?)?.toInt() ?? 0,
      duration: (json['duration'] as num?)?.toInt(),
      location: json['location'] as String?,
      protectionUsed: json['protectionUsed'] as bool,
      note: json['note'] as String?,
      orgasmsMe: (json['orgasmsMe'] as num?)?.toInt() ?? 0,
      orgasmsPartner: (json['orgasmsPartner'] as num?)?.toInt() ?? 0,
      durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
      location: json['location'] as String?,
    );

Map<String, dynamic> _$$IntimacyLogImplToJson(_$IntimacyLogImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': const RequiredTimestampConverter().toJson(instance.date),
      'initiatorId': instance.initiatorId,
      'rating': instance.rating,
      'tags': instance.tags,
      'positions': instance.positions,
      'userOrgasmCount': instance.userOrgasmCount,
      'partnerOrgasmCount': instance.partnerOrgasmCount,
      'duration': instance.duration,
      'protectionUsed': instance.protectionUsed,
      'note': instance.note,
      'orgasmsMe': instance.orgasmsMe,
      'orgasmsPartner': instance.orgasmsPartner,
      'durationMinutes': instance.durationMinutes,
      'location': instance.location,
    };

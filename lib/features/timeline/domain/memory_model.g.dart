// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memory_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MemoryImpl _$$MemoryImplFromJson(Map<String, dynamic> json) => _$MemoryImpl(
  id: json['id'] as String,
  pairId: json['pairId'] as String,
  authorId: json['authorId'] as String,
  mediaUrls:
      (json['mediaUrls'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  caption: json['caption'] as String,
  date: const RequiredTimestampConverter().fromJson(json['date']),
  category: const MemoryCategoryConverter().fromJson(
    json['category'] as String,
  ),
  location: json['location'] as Map<String, dynamic>?,
  createdAt: const RequiredTimestampConverter().fromJson(json['createdAt']),
);

Map<String, dynamic> _$$MemoryImplToJson(
  _$MemoryImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'pairId': instance.pairId,
  'authorId': instance.authorId,
  'mediaUrls': instance.mediaUrls,
  'caption': instance.caption,
  'date': const RequiredTimestampConverter().toJson(instance.date),
  'category': const MemoryCategoryConverter().toJson(instance.category),
  'location': instance.location,
  'createdAt': const RequiredTimestampConverter().toJson(instance.createdAt),
};

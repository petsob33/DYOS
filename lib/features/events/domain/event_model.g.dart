// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EventImpl _$$EventImplFromJson(Map<String, dynamic> json) => _$EventImpl(
  id: json['id'] as String,
  date: const RequiredTimestampConverter().fromJson(json['date']),
  title: json['title'] as String,
);

Map<String, dynamic> _$$EventImplToJson(_$EventImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': const RequiredTimestampConverter().toJson(instance.date),
      'title': instance.title,
    };

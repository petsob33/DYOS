// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cycle_log_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CycleLogImpl _$$CycleLogImplFromJson(Map<String, dynamic> json) =>
    _$CycleLogImpl(
      id: json['id'] as String,
      date: const RequiredTimestampConverter().fromJson(json['date']),
      flowIntensity: $enumDecode(_$FlowIntensityEnumMap, json['flowIntensity']),
      mood: $enumDecode(_$MoodEnumMap, json['mood']),
      symptoms:
          (json['symptoms'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$CycleLogImplToJson(_$CycleLogImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': const RequiredTimestampConverter().toJson(instance.date),
      'flowIntensity': _$FlowIntensityEnumMap[instance.flowIntensity]!,
      'mood': _$MoodEnumMap[instance.mood]!,
      'symptoms': instance.symptoms,
    };

const _$FlowIntensityEnumMap = {
  FlowIntensity.light: 'light',
  FlowIntensity.medium: 'medium',
  FlowIntensity.heavy: 'heavy',
  FlowIntensity.spotting: 'spotting',
};

const _$MoodEnumMap = {
  Mood.happy: 'happy',
  Mood.sensitive: 'sensitive',
  Mood.energetic: 'energetic',
  Mood.irritable: 'irritable',
};

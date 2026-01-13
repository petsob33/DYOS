// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cycle_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CycleLogImpl _$$CycleLogImplFromJson(Map<String, dynamic> json) =>
    _$CycleLogImpl(
      date: DateTime.parse(json['date'] as String),
      flowIntensity: $enumDecode(_$FlowIntensityEnumMap, json['flowIntensity']),
      mood: $enumDecode(_$MoodEnumMap, json['mood']),
    );

Map<String, dynamic> _$$CycleLogImplToJson(_$CycleLogImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'flowIntensity': _$FlowIntensityEnumMap[instance.flowIntensity]!,
      'mood': _$MoodEnumMap[instance.mood]!,
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

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blueprint_question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BlueprintQuestionImpl _$$BlueprintQuestionImplFromJson(
  Map<String, dynamic> json,
) => _$BlueprintQuestionImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  type: $enumDecode(_$BlueprintQuestionTypeEnumMap, json['type']),
  sliderLeftLabel: json['sliderLeftLabel'] as String?,
  sliderRightLabel: json['sliderRightLabel'] as String?,
  options: (json['options'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  measurementSuffix: json['measurementSuffix'] as String?,
  measurementPlaceholder: json['measurementPlaceholder'] as String?,
);

Map<String, dynamic> _$$BlueprintQuestionImplToJson(
  _$BlueprintQuestionImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'type': _$BlueprintQuestionTypeEnumMap[instance.type]!,
  'sliderLeftLabel': instance.sliderLeftLabel,
  'sliderRightLabel': instance.sliderRightLabel,
  'options': instance.options,
  'measurementSuffix': instance.measurementSuffix,
  'measurementPlaceholder': instance.measurementPlaceholder,
};

const _$BlueprintQuestionTypeEnumMap = {
  BlueprintQuestionType.slider: 'slider',
  BlueprintQuestionType.choiceChips: 'choiceChips',
  BlueprintQuestionType.multiSelect: 'multiSelect',
  BlueprintQuestionType.measurement: 'measurement',
  BlueprintQuestionType.switchType: 'switchType',
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blueprint_section.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BlueprintSectionImpl _$$BlueprintSectionImplFromJson(
  Map<String, dynamic> json,
) => _$BlueprintSectionImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  emoji: json['emoji'] as String,
  order: (json['order'] as num?)?.toInt() ?? 0,
  questions: (json['questions'] as List<dynamic>)
      .map((e) => BlueprintQuestion.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$BlueprintSectionImplToJson(
  _$BlueprintSectionImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'emoji': instance.emoji,
  'order': instance.order,
  'questions': instance.questions.map((e) => e.toJson()).toList(),
};

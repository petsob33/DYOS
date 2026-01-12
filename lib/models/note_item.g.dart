// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NoteItemImpl _$$NoteItemImplFromJson(Map<String, dynamic> json) =>
    _$NoteItemImpl(
      id: json['id'] as String,
      content: json['content'] as String,
      title: json['title'] as String?,
      createdAt: const RequiredTimestampConverter().fromJson(json['createdAt']),
      type: const NoteTypeConverter().fromJson(json['type'] as String),
      authorId: json['authorId'] as String,
    );

Map<String, dynamic> _$$NoteItemImplToJson(
  _$NoteItemImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'content': instance.content,
  'title': instance.title,
  'createdAt': const RequiredTimestampConverter().toJson(instance.createdAt),
  'type': const NoteTypeConverter().toJson(instance.type),
  'authorId': instance.authorId,
};

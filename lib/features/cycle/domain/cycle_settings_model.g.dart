// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cycle_settings_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CycleSettingsImpl _$$CycleSettingsImplFromJson(Map<String, dynamic> json) =>
    _$CycleSettingsImpl(
      id: json['id'] as String,
      averageCycleLength: (json['averageCycleLength'] as num?)?.toInt() ?? 28,
      periodLength: (json['periodLength'] as num?)?.toInt() ?? 5,
      lastPeriodDate: const TimestampConverter().fromJson(
        json['lastPeriodDate'],
      ),
    );

Map<String, dynamic> _$$CycleSettingsImplToJson(
  _$CycleSettingsImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'averageCycleLength': instance.averageCycleLength,
  'periodLength': instance.periodLength,
  'lastPeriodDate': const TimestampConverter().toJson(instance.lastPeriodDate),
};

import 'package:freezed_annotation/freezed_annotation.dart';

import '../domain/cycle_log_model.dart' show FlowIntensity, Mood;

part 'cycle_log.freezed.dart';
part 'cycle_log.g.dart';

/// Model representing a menstrual cycle log entry
/// 
/// This model stores information about a day in the menstrual cycle,
/// including flow intensity and mood.
@freezed
class CycleLog with _$CycleLog {
  const factory CycleLog({
    required DateTime date,
    required FlowIntensity flowIntensity,
    required Mood mood,
  }) = _CycleLog;

  factory CycleLog.fromJson(Map<String, dynamic> json) =>
      _$CycleLogFromJson(json);
}
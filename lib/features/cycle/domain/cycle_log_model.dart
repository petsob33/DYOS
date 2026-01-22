import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'cycle_log_model.freezed.dart';
part 'cycle_log_model.g.dart';

/// Converter for Firestore Timestamp to DateTime (required/non-nullable)
/// 
/// Handles conversion between Firestore's Timestamp type and Dart's DateTime
/// for required DateTime fields.
class RequiredTimestampConverter implements JsonConverter<DateTime, dynamic> {
  const RequiredTimestampConverter();

  @override
  DateTime fromJson(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed;
    }
    if (value is DateTime) return value;
    throw FormatException('Cannot convert $value to DateTime');
  }

  @override
  dynamic toJson(DateTime date) => Timestamp.fromDate(date);
}

/// Enum representing flow intensity levels
@JsonEnum()
enum FlowIntensity {
  @JsonValue('light')
  light,
  @JsonValue('medium')
  medium,
  @JsonValue('heavy')
  heavy,
  @JsonValue('spotting')
  spotting,
}

/// Enum representing mood states
@JsonEnum()
enum Mood {
  @JsonValue('happy')
  happy,
  @JsonValue('sensitive')
  sensitive,
  @JsonValue('energetic')
  energetic,
  @JsonValue('irritable')
  irritable,
}

/// Model representing a menstrual cycle log entry
/// 
/// This model stores information about a day in the menstrual cycle,
/// including flow intensity, mood, and notes.
@freezed
class CycleLog with _$CycleLog {
  @JsonSerializable(explicitToJson: true)
  const factory CycleLog({
    required String id,
    @RequiredTimestampConverter() required DateTime date,
    required FlowIntensity flowIntensity,
    required Mood mood,
    String? notes, // Optional notes
  }) = _CycleLog;

  factory CycleLog.fromJson(Map<String, dynamic> json) =>
      _$CycleLogFromJson(json);

  /// Create CycleLog from Firestore document
  factory CycleLog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CycleLog.fromJson(data).copyWith(id: doc.id);
  }
}
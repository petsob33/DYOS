import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'cycle_settings_model.freezed.dart';
part 'cycle_settings_model.g.dart';

/// Converter for Firestore Timestamp to DateTime (nullable)
/// 
/// Handles conversion between Firestore's Timestamp type and Dart's DateTime
/// for nullable DateTime fields.
class TimestampConverter implements JsonConverter<DateTime?, dynamic> {
  const TimestampConverter();

  @override
  DateTime? fromJson(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed;
    }
    if (value is DateTime) return value;
    return null;
  }

  @override
  dynamic toJson(DateTime? date) =>
      date != null ? Timestamp.fromDate(date) : null;
}

/// Model representing menstrual cycle settings
/// 
/// This model stores user preferences and tracking data for the menstrual cycle,
/// including average cycle length, period length, and the last period start date.
@freezed
class CycleSettings with _$CycleSettings {
  const factory CycleSettings({
    required String id,
    @Default(28) int averageCycleLength, // CRITICAL: This must be editable
    @Default(5) int periodLength,
    @TimestampConverter() DateTime? lastPeriodDate,
    @Default(false) bool isTryingToConceive,
    @Default(false) bool hideMenstruation, // Hide menstruation tracking and display
  }) = _CycleSettings;

  factory CycleSettings.fromJson(Map<String, dynamic> json) =>
      _$CycleSettingsFromJson(json);

  /// Create CycleSettings from Firestore document
  factory CycleSettings.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CycleSettings.fromJson(data).copyWith(id: doc.id);
  }
}
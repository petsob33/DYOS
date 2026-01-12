import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'intimacy_log_model.freezed.dart';
part 'intimacy_log_model.g.dart';

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

/// Model representing an intimacy log entry
/// 
/// This model stores information about an intimacy event in Firestore.
/// Logs are linked to a couple via coupleId and include date, rating, tags, and optional notes.
@freezed
class IntimacyLog with _$IntimacyLog {
  @JsonSerializable(explicitToJson: true)
  const factory IntimacyLog({
    required String id,
    @RequiredTimestampConverter() required DateTime date,
    required String initiatorId, // userId who initiated
    required int rating, // 1-5 rating
    @Default([]) List<String> tags, // e.g., "Romantic", "Quickie", "Morning", "Experiment"
    required bool protectionUsed,
    String? note, // Optional note
  }) = _IntimacyLog;

  factory IntimacyLog.fromJson(Map<String, dynamic> json) =>
      _$IntimacyLogFromJson(json);

  /// Create IntimacyLog from Firestore document
  factory IntimacyLog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return IntimacyLog.fromJson(data).copyWith(id: doc.id);
  }
}

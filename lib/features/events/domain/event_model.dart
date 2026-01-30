import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_model.freezed.dart';
part 'event_model.g.dart';

/// Converter for Firestore Timestamp to DateTime (required/non-nullable)
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

/// Model representing an event
/// 
/// This model stores information about an event including date and title.
@freezed
class Event with _$Event {
  @JsonSerializable(explicitToJson: true)
  const factory Event({
    required String id,
    @RequiredTimestampConverter() required DateTime date,
    required String title,
  }) = _Event;

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);

  /// Create Event from Firestore document
  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Event.fromJson(data).copyWith(id: doc.id);
  }
}

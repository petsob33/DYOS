import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'memory_model.freezed.dart';
part 'memory_model.g.dart';

/// Converter for MemoryCategory enum to/from JSON
class MemoryCategoryConverter implements JsonConverter<MemoryCategory, String> {
  const MemoryCategoryConverter();

  @override
  MemoryCategory fromJson(String json) {
    return MemoryCategory.values.firstWhere(
      (e) => e.name == json,
      orElse: () => MemoryCategory.other,
    );
  }

  @override
  String toJson(MemoryCategory object) => object.name;
}

/// Enum representing different categories of memories
enum MemoryCategory {
  dateNight,
  trip,
  milestone,
  dailyLife,
  food,
  party,
  funny,
  intimacy,
  nature,
  other;

  /// Get display name for the category
  String get displayName {
    switch (this) {
      case MemoryCategory.dateNight:
        return 'Date Night';
      case MemoryCategory.trip:
        return 'Trip';
      case MemoryCategory.milestone:
        return 'Milestone';
      case MemoryCategory.dailyLife:
        return 'Daily Life';
      case MemoryCategory.food:
        return 'Food';
      case MemoryCategory.party:
        return 'Party';
      case MemoryCategory.funny:
        return 'Funny';
      case MemoryCategory.intimacy:
        return 'Intimacy';
      case MemoryCategory.nature:
        return 'Nature';
      case MemoryCategory.other:
        return 'Other';
    }
  }

  /// Get emoji/icon for the category
  String get emoji {
    switch (this) {
      case MemoryCategory.dateNight:
        return '💕';
      case MemoryCategory.trip:
        return '✈️';
      case MemoryCategory.milestone:
        return '🎯';
      case MemoryCategory.dailyLife:
        return '📷';
      case MemoryCategory.food:
        return '🍽️';
      case MemoryCategory.party:
        return '🎉';
      case MemoryCategory.funny:
        return '😄';
      case MemoryCategory.intimacy:
        return '💑';
      case MemoryCategory.nature:
        return '🌳';
      case MemoryCategory.other:
        return '📌';
    }
  }
}

/// Model representing a memory shared between a couple
/// 
/// This model stores information about a memory (photo/video post) in Firestore.
/// Memories are linked to a couple via pairId and include media, caption, date, and location.
@freezed
class Memory with _$Memory {
  @JsonSerializable(explicitToJson: true)
  const factory Memory({
    required String id,
    required String pairId, // Link to the couple
    required String authorId, // Who posted it
    @Default([]) List<String> mediaUrls, // Multiple photos/videos
    required String caption,
    @RequiredTimestampConverter() required DateTime date,
    @MemoryCategoryConverter() required MemoryCategory category,
    Map<String, dynamic>? location, // Generic location data (name, lat, lng)
    @RequiredTimestampConverter() required DateTime createdAt,
  }) = _Memory;

  factory Memory.fromJson(Map<String, dynamic> json) => _$MemoryFromJson(json);

  /// Create Memory from Firestore document
  factory Memory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Memory.fromJson(data).copyWith(id: doc.id);
  }
}

/// Converter for Firestore Timestamp to DateTime (nullable)
/// 
/// Handles conversion between Firestore's Timestamp type and Dart's DateTime.
/// This is needed because Firestore stores dates as Timestamp objects,
/// but we want to work with DateTime in our Dart code.
class TimestampConverter implements JsonConverter<DateTime?, dynamic> {
  const TimestampConverter();

  @override
  DateTime? fromJson(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return value as DateTime?;
  }

  @override
  dynamic toJson(DateTime? date) =>
      date != null ? Timestamp.fromDate(date) : null;
}

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

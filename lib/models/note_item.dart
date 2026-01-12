import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'note_item.freezed.dart';
part 'note_item.g.dart';

/// Converter for NoteType enum to/from JSON
class NoteTypeConverter implements JsonConverter<NoteType, String> {
  const NoteTypeConverter();

  @override
  NoteType fromJson(String json) {
    return NoteType.values.firstWhere(
      (e) => e.name == json,
      orElse: () => NoteType.private,
    );
  }

  @override
  String toJson(NoteType object) => object.name;
}

/// Enum representing different types of notes
enum NoteType {
  shared,
  private,
  bucketList,
  secretGift;
}

/// Model representing a note item
/// 
/// This model stores information about a note with optional title,
/// content, type, and metadata.
@freezed
class NoteItem with _$NoteItem {
  @JsonSerializable(explicitToJson: true)
  const factory NoteItem({
    required String id,
    required String content,
    String? title,
    @RequiredTimestampConverter() required DateTime createdAt,
    @NoteTypeConverter() required NoteType type,
    required String authorId,
  }) = _NoteItem;

  factory NoteItem.fromJson(Map<String, dynamic> json) =>
      _$NoteItemFromJson(json);

  /// Create NoteItem from Firestore document
  factory NoteItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NoteItem.fromJson(data).copyWith(id: doc.id);
  }

  /// Factory constructor for generating dummy data
  factory NoteItem.dummy({
    String? id,
    String? content,
    String? title,
    DateTime? createdAt,
    NoteType? type,
    String? authorId,
  }) {
    return NoteItem(
      id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      content: content ??
          'This is a sample note content. You can write anything here!',
      title: title,
      createdAt: createdAt ?? DateTime.now(),
      type: type ?? NoteType.private,
      authorId: authorId ?? 'dummy_author_123',
    );
  }
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

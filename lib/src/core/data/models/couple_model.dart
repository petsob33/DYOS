import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Generated files
part 'couple_model.freezed.dart';
part 'couple_model.g.dart';

/// Model representing a couple (pair of users)
/// 
/// This model stores information about a paired couple in the system.
/// When two users pair up, a CoupleModel document is created in Firestore.
@freezed
class CoupleModel with _$CoupleModel {
  @JsonSerializable(explicitToJson: true)
  const factory CoupleModel({
    required String id,
    required List<String> members, // Array of user UIDs
    DateTime? anniversaryDate,
    @TimestampConverter() DateTime? createdAt,
  }) = _CoupleModel;

  factory CoupleModel.fromJson(Map<String, dynamic> json) =>
      _$CoupleModelFromJson(json);

  /// Create CoupleModel from Firestore document
  factory CoupleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CoupleModel.fromJson(data).copyWith(id: doc.id);
  }
}

/// Converter for Firestore Timestamp to DateTime
/// 
/// Handles conversion between Firestore's Timestamp type and Dart's DateTime.
/// This is needed because Firestore stores dates as Timestamp objects,
/// but we want to work with DateTime in our Dart code.
class TimestampConverter implements JsonConverter<DateTime?, dynamic> {
  const TimestampConverter();

  @override
  DateTime? fromJson(dynamic value) {
    if (value is Timestamp) return value.toDate();
    return value as DateTime?;
  }

  @override
  dynamic toJson(DateTime? date) =>
      date != null ? Timestamp.fromDate(date) : null;
}

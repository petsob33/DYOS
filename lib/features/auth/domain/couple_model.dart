import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

// Generated files
part 'couple_model.freezed.dart';
part 'couple_model.g.dart';

/// Model representing a couple (pair of users)
/// 
/// This model stores information about a paired couple in the system.
/// When two users pair up, a CoupleModel document is created in Firestore.
@freezed
class CoupleModel with _$CoupleModel {
  const CoupleModel._();
  const factory CoupleModel({
    // Freezed constructor param, not a field/getter yet when the analyzer
    // checks this; source_gen still honors it correctly (id is excluded
    // from toJson in couple_model.g.dart).
    // ignore: invalid_annotation_target
    @JsonKey(includeFromJson: true, includeToJson: false) required String id,
    required List<String> members, // Array of user UIDs (important for Security Rules!)
    DateTime? anniversaryDate, // For counting days together
    @TimestampConverter() DateTime? createdAt,
    
    // Subscription fields
    @Default('free') String subscriptionTier, // "free" | "premium" | "trial"
    @TimestampConverter() DateTime? subscriptionExpiry, // When premium subscription ends
    
    // Status widget data - stored here to avoid reading extra documents on app start
    // Key is user UID, value is their status (emoji + text)
    Map<String, CoupleStatus>? status,

    // Gamification: couple XP (persisted in Firestore)
    @Default(0) int xp,
    // Blueprint answers: sectionId -> userId -> { questionId: value }
    Map<String, dynamic>? blueprintAnswers,
    // Section IDs for which XP was already awarded (once per section per couple)
    List<String>? completedBlueprintSections,
    // Quest XP granted once per day: questId -> "YYYY-MM-DD"
    Map<String, String>? questXpLastGrantedAt,
  }) = _CoupleModel;

  factory CoupleModel.fromJson(Map<String, dynamic> json) =>
      _$CoupleModelFromJson(json);

  /// True when the couple has an active premium subscription.
  bool get isPremium =>
      subscriptionTier == 'premium' &&
      (subscriptionExpiry == null ||
          subscriptionExpiry!.isAfter(DateTime.now()));

  /// When the premium subscription ends; alias for subscriptionExpiry.
  DateTime? get premiumExpiration => subscriptionExpiry;

  /// Create CoupleModel from Firestore document
  factory CoupleModel.fromFirestore(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) {
        throw Exception('Document data is null');
      }
      
      // Convert Firestore data to JSON format
      // Handle anniversaryDate - it might be Timestamp or String
      final convertedData = <String, dynamic>{...data};
      
      // Convert anniversaryDate Timestamp → DateTime so TimestampConverter can handle it
      if (convertedData['anniversaryDate'] is Timestamp) {
        convertedData['anniversaryDate'] =
            (convertedData['anniversaryDate'] as Timestamp).toDate().toIso8601String();
      }
      
      // Convert status map values - ensure CoupleStatus objects are properly converted
      if (convertedData['status'] != null && convertedData['status'] is Map) {
        final statusMap = convertedData['status'] as Map<String, dynamic>;
        final convertedStatus = <String, dynamic>{};
        for (final entry in statusMap.entries) {
          if (entry.value is Map) {
            // Ensure updatedAt is properly converted if it's a Timestamp
            final statusData = Map<String, dynamic>.from(entry.value as Map);
            if (statusData['updatedAt'] != null && statusData['updatedAt'] is Timestamp) {
              statusData['updatedAt'] = (statusData['updatedAt'] as Timestamp).toDate().toIso8601String();
            }
            convertedStatus[entry.key] = statusData;
          } else {
            convertedStatus[entry.key] = entry.value;
          }
        }
        convertedData['status'] = convertedStatus;
      }
      
      // Add id to data since it's required by fromJson but not stored in Firestore
      convertedData['id'] = doc.id;
      
      return CoupleModel.fromJson(convertedData);
    } catch (e, stackTrace) {
      debugPrint('Error in CoupleModel.fromFirestore for doc ${doc.id}: $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('Document data: ${doc.data()}');
      rethrow;
    }
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
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  @override
  dynamic toJson(DateTime? date) =>
      date != null ? Timestamp.fromDate(date) : null;
}

/// Status information for a user within a couple
/// 
/// This stores the emoji and text status that appears in the dashboard.
/// The status is stored in the couple document for quick access.
@freezed
class CoupleStatus with _$CoupleStatus {
  const factory CoupleStatus({
    required String emoji,
    required String text,
    @TimestampConverter() DateTime? updatedAt,
  }) = _CoupleStatus;

  factory CoupleStatus.fromJson(Map<String, dynamic> json) =>
      _$CoupleStatusFromJson(json);
}

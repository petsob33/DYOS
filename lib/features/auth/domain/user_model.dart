import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Tři magické řádky, které propojí generované soubory
part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  // Tady řekneš: Chci, aby se to umělo převést i na JSON (explicitToJson: true)
  @JsonSerializable(explicitToJson: true)
  const factory UserModel({
    required String uid,
    required String email,
    String? displayName,
    String? photoUrl,
    String? inviteCode,
    String? coupleId,
    DateTime? dateOfBirth,
    UserStatus? status,
    
    // Firestore Timestamp musíme převést na DateTime
    @TimestampConverter() DateTime? createdAt, 
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  /// Parses Firestore user docs safely — cache/server may omit or null fields
  /// that [fromJson] expects as non-null [String] (e.g. legacy or in-flight writes).
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    if (!doc.exists) {
      throw StateError('User document does not exist');
    }
    final raw = doc.data();
    if (raw == null) {
      throw StateError('User document has no data');
    }
    final data = Map<String, dynamic>.from(raw as Map);
    data['uid'] = doc.id;
    final emailRaw = data['email'];
    data['email'] = emailRaw is String
        ? emailRaw
        : (emailRaw == null ? '' : emailRaw.toString());

    final statusRaw = data['status'];
    if (statusRaw is Map) {
      final sm = Map<String, dynamic>.from(statusRaw);
      if (sm['emoji'] == null || sm['text'] == null) {
        data.remove('status');
      }
    }

    return UserModel.fromJson(data).copyWith(uid: doc.id);
  }
}

// Pomocná třída pro status
@freezed
class UserStatus with _$UserStatus {
  const factory UserStatus({
    required String emoji,
    required String text,
    @TimestampConverter() DateTime? updatedAt,
  }) = _UserStatus;

  factory UserStatus.fromJson(Map<String, dynamic> json) => _$UserStatusFromJson(json);
}

// Konvertor pro datum (zkopíruj a neřeš)
class TimestampConverter implements JsonConverter<DateTime?, dynamic> {
  const TimestampConverter();

  @override
  DateTime? fromJson(dynamic value) {
    if (value is Timestamp) return value.toDate();
    return value as DateTime?;
  }

  @override
  dynamic toJson(DateTime? date) => date != null ? Timestamp.fromDate(date) : null;
}

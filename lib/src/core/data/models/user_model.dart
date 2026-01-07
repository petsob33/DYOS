import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String uid,
    required String email,
    required String displayName,
    String? photoUrl,
    String? coupleId,
    required String inviteCode,
    String? fcmToken,
    @TimestampConverter() required DateTime createdAt,
    String? platform,
    @Default(UserSettings()) UserSettings settings,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

@freezed
class UserSettings with _$UserSettings {
  const factory UserSettings({
    @Default('system') String theme,
    @Default(true) bool notificationsEnabled,
  }) = _UserSettings;

  factory UserSettings.fromJson(Map<String, dynamic> json) =>
      _$UserSettingsFromJson(json);
}

class TimestampConverter implements JsonConverter<DateTime, Object> {
  const TimestampConverter();

  @override
  DateTime fromJson(Object json) {
    if (json is Timestamp) {
      return json.toDate();
    }
    if (json is String) {
      return DateTime.parse(json);
    }
    throw ArgumentError('Cannot convert $json to DateTime');
  }

  @override
  Object toJson(DateTime object) => Timestamp.fromDate(object);
}

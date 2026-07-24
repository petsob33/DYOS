import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'blueprint_question.dart';

part 'blueprint_section.freezed.dart';
part 'blueprint_section.g.dart';

/// One Blueprint section (category) with title, emoji, and questions.
///
/// Backed by Firestore (`blueprint_sections/{id}`, seeded via
/// `scripts/seed_blueprint_sections.js`) so content can be edited without an
/// app release; [BlueprintMockData] in `data/blueprint_mock_data.dart` is
/// both the seed source and an offline/pre-seed fallback.
@freezed
class BlueprintSection with _$BlueprintSection {
  const factory BlueprintSection({
    required String id,
    required String title,
    required String emoji,
    @Default(0) int order,
    required List<BlueprintQuestion> questions,
  }) = _BlueprintSection;

  factory BlueprintSection.fromJson(Map<String, dynamic> json) =>
      _$BlueprintSectionFromJson(json);

  factory BlueprintSection.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return BlueprintSection.fromJson({...data, 'id': doc.id});
  }
}

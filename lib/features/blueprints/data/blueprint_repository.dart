import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/blueprint_section.dart';

part 'blueprint_repository.g.dart';

/// Reads Blueprint section content from the top-level `blueprint_sections`
/// collection. This is shared, non-couple-scoped content (the questionnaire
/// itself, not answers) seeded via `scripts/seed_blueprint_sections.js`.
class BlueprintRepository {
  BlueprintRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _sections =>
      _firestore.collection('blueprint_sections');

  Stream<List<BlueprintSection>> watchSections() {
    return _sections.orderBy('order').snapshots().map(
          (snapshot) => snapshot.docs
              .map(BlueprintSection.fromFirestore)
              .toList(),
        );
  }

  Future<BlueprintSection?> getSection(String sectionId) async {
    final doc = await _sections.doc(sectionId).get();
    if (!doc.exists) return null;
    return BlueprintSection.fromFirestore(doc);
  }
}

@riverpod
BlueprintRepository blueprintRepository(BlueprintRepositoryRef ref) {
  return BlueprintRepository(firestore: FirebaseFirestore.instance);
}

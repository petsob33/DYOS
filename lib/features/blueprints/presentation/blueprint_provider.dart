import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/blueprint_mock_data.dart';
import '../data/blueprint_repository.dart';
import '../domain/blueprint_section.dart';

part 'blueprint_provider.g.dart';

/// All Blueprint sections, ordered. Falls back to the bundled
/// [BlueprintMockData] if Firestore has no seeded sections yet, so the
/// feature keeps working before/without running the seed script.
@riverpod
Stream<List<BlueprintSection>> blueprintSections(BlueprintSectionsRef ref) {
  return ref.watch(blueprintRepositoryProvider).watchSections().map(
        (sections) => sections.isEmpty ? BlueprintMockData.allSections : sections,
      );
}

/// A single Blueprint section by id, for the detail screen. Falls back to
/// [BlueprintMockData.sectionById] if not found in Firestore.
@riverpod
Future<BlueprintSection?> blueprintSection(
  BlueprintSectionRef ref,
  String sectionId,
) async {
  final fromFirestore =
      await ref.watch(blueprintRepositoryProvider).getSection(sectionId);
  return fromFirestore ?? BlueprintMockData.sectionById(sectionId);
}

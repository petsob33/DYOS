// Dumps BlueprintMockData.allSections as JSON, one object per section, for
// scripts/seed_blueprint_sections.js to upload to the `blueprint_sections`
// Firestore collection.
//
// Run through `flutter test` (not `dart run`): blueprint_section.dart pulls
// in cloud_firestore, which transitively needs dart:ui - only available
// under Flutter's test/app bindings, not the plain Dart VM.
//
// Usage:
//   flutter test scripts/export_blueprint_sections.dart
//   (writes scripts/blueprint_sections_seed.json)
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ouros_app/features/blueprints/data/blueprint_mock_data.dart';

void main() {
  test('export BlueprintMockData.allSections to scripts/blueprint_sections_seed.json', () {
    final sections = BlueprintMockData.allSections;
    final json = sections.map((s) => s.toJson()).toList();
    final file = File('scripts/blueprint_sections_seed.json');
    file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(json));
    // ignore: avoid_print
    print('Wrote ${sections.length} sections to ${file.path}');
  });
}

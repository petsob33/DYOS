# Czech/English Localization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add Czech and English localization for all everyday UI text across the app (~140 Dart files), with English as the default and a manual language override in Settings, using Flutter's official `flutter_localizations`/`intl`/`gen-l10n` tooling.

**Architecture:** ARB source-of-truth files (`lib/l10n/app_en.arb`, `lib/l10n/app_cs.arb`) generate a type-safe `AppLocalizations` class via `flutter gen-l10n`. A `LocaleController` (Riverpod, mirroring the existing `ThemeModeController`) persists the user's language choice to `shared_preferences` and feeds `MaterialApp.router.locale`. Every feature folder is migrated file-by-file from hardcoded strings to `context.l10n.<key>` calls, following one fully-worked reference migration (the Data screen).

**Tech Stack:** `flutter_localizations` (Flutter SDK), `intl`, `flutter gen-l10n`, existing `flutter_riverpod` + `shared_preferences` stack.

## Global Constraints

- English is the default/fallback locale; Czech is opt-in via Settings (System / Čeština / English selector, mirroring the existing Appearance selector pattern).
- Out of scope: Terms of Service, Privacy Policy, and longer marketing/paywall copy in `lib/features/premium/domain/premium_copy.dart` and equivalent long-form marketing text — these stay English-only.
- Out of scope: any language beyond Czech/English; translation of user-generated content (chat messages, notes, etc.) — only static UI chrome is localized.
- ARB key naming: flat namespace, `<screenPrefix><PascalCaseDescription>`, e.g. `dataScreenTotalCountTitle`. Reusable generic action words (Cancel/Delete/Edit/Confirm/Save) use `common<Word>` keys instead of per-screen duplicates.
- Every new/changed ARB key must be added to **both** `app_en.arb` and `app_cs.arb` in the same task — never leave a key untranslated in one locale.
- **`build_runner` caution (per `AUDIT.md` section 4):** `dart run build_runner build --delete-conflicting-outputs` regenerates every `@riverpod`/`@freezed` file in `lib/` and has previously silently dropped `explicitToJson: true` from 6 unrelated `.freezed.dart` files (`couple_model`, `user_model`, `event_model`, `note_item`, `memory_model`, `cycle_settings_model`). Any task in this plan that runs this command must diff the result afterward and `git checkout` back any unrelated file that changed before committing.

---

### Task 1: Add localization dependencies, ARB scaffold, and generated pipeline

**Files:**
- Modify: `pubspec.yaml:30-39` (dependencies), `pubspec.yaml` `flutter:` section (~line 91)
- Create: `l10n.yaml`
- Create: `lib/l10n/app_en.arb`
- Create: `lib/l10n/app_cs.arb`
- Create: `lib/core/l10n/build_context_l10n_extension.dart`
- Create (generated): `lib/l10n/generated/app_localizations.dart`, `lib/l10n/generated/app_localizations_en.dart`, `lib/l10n/generated/app_localizations_cs.dart`

**Interfaces:**
- Produces: `AppLocalizations` class (generated, from `package:ouros_app/l10n/generated/app_localizations.dart`) with `.localizationsDelegates` / `.supportedLocales` statics and per-key getters (e.g. `.commonCancel`); `BuildContext.l10n` extension getter returning `AppLocalizations`. Both are consumed by every later task.

- [ ] **Step 1: Add `flutter_localizations` and `intl` to `pubspec.yaml`**

Current (`pubspec.yaml:30-39`):

```yaml
dependencies:
  flutter:
    sdk: flutter

  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  go_router: ^17.3.0
  google_fonts: ^7.0.0
  freezed_annotation: ^2.4.4
  flutter_staggered_grid_view: ^0.7.0
```

Replace with:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  intl: ^0.20.2
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  go_router: ^17.3.0
  google_fonts: ^7.0.0
  freezed_annotation: ^2.4.4
  flutter_staggered_grid_view: ^0.7.0
```

- [ ] **Step 2: Enable ARB codegen in the `flutter:` section**

In `pubspec.yaml`, find:

```yaml
  # The following line ensures that the Material Icons font is
  # included with your application, so that you can use the icons in
  # the material Icons class.
  uses-material-design: true
```

Add directly after it:

```yaml

  # Generates AppLocalizations from lib/l10n/*.arb per l10n.yaml.
  generate: true
```

- [ ] **Step 3: Create `l10n.yaml` at the repo root**

```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-dir: lib/l10n/generated
output-localization-file: app_localizations.dart
output-class: AppLocalizations
synthetic-package: false
```

- [ ] **Step 4: Create the English template ARB with the initial common keys**

`lib/l10n/app_en.arb`:

```json
{
  "@@locale": "en",
  "commonCancel": "Cancel",
  "commonDelete": "Delete",
  "commonEdit": "Edit",
  "commonConfirm": "Confirm",
  "commonSave": "Save"
}
```

- [ ] **Step 5: Create the Czech ARB with matching translations**

`lib/l10n/app_cs.arb`:

```json
{
  "@@locale": "cs",
  "commonCancel": "Zrušit",
  "commonDelete": "Smazat",
  "commonEdit": "Upravit",
  "commonConfirm": "Potvrdit",
  "commonSave": "Uložit"
}
```

- [ ] **Step 6: Fetch dependencies and generate**

Run: `flutter pub get`
Expected: resolves cleanly. If it fails with an `intl` version conflict, the error names the version `flutter_localizations` requires for this SDK — change the `intl: ^0.20.2` constraint in `pubspec.yaml` to that version and re-run `flutter pub get`.

Run: `flutter gen-l10n`
Expected: creates `lib/l10n/generated/app_localizations.dart`, `app_localizations_en.dart`, `app_localizations_cs.dart` with no errors.

- [ ] **Step 7: Create the `context.l10n` convenience extension**

`lib/core/l10n/build_context_l10n_extension.dart`:

```dart
import 'package:flutter/widgets.dart';

import '../../l10n/generated/app_localizations.dart';

extension BuildContextL10n on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
```

- [ ] **Step 8: Run static analysis**

Run: `flutter analyze`
Expected: no new errors introduced by this task (pre-existing `info`-level lints elsewhere are unrelated).

- [ ] **Step 9: Commit**

```bash
git add pubspec.yaml pubspec.lock l10n.yaml lib/l10n/ lib/core/l10n/
git commit -m "feat(l10n): scaffold flutter_localizations + ARB pipeline"
```

---

### Task 2: `LocaleController` — persisted language preference

**Files:**
- Create: `lib/core/l10n/locale_provider.dart`
- Create (generated): `lib/core/l10n/locale_provider.g.dart`
- Test: `test/l10n/locale_provider_test.dart`

**Interfaces:**
- Consumes: `sharedPreferencesProvider` (from `lib/features/auth/presentation/auth_providers.dart:104`, already used identically by `lib/core/theme/theme_mode_provider.dart`).
- Produces: `localeControllerProvider` (an `AsyncNotifierProvider<LocaleController, Locale?>`) with `.setLocale(Locale? locale)`. `null` state/argument means "follow system". Consumed by Task 3 (Settings UI) and Task 4 (`app.dart` wiring).

- [ ] **Step 1: Write the failing test**

`test/l10n/locale_provider_test.dart`:

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ouros_app/core/l10n/locale_provider.dart';

void main() {
  test('defaults to null (system) locale when no preference saved', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final locale = await container.read(localeControllerProvider.future);

    expect(locale, isNull);
  });

  test('loads a previously saved preference', () async {
    SharedPreferences.setMockInitialValues({'locale': 'cs'});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final locale = await container.read(localeControllerProvider.future);

    expect(locale, const Locale('cs'));
  });

  test('setLocale updates state and persists the choice', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(localeControllerProvider.future);

    await container
        .read(localeControllerProvider.notifier)
        .setLocale(const Locale('cs'));

    expect(container.read(localeControllerProvider).value, const Locale('cs'));
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('locale'), 'cs');
  });

  test('setLocale(null) clears the persisted preference', () async {
    SharedPreferences.setMockInitialValues({'locale': 'cs'});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(localeControllerProvider.future);

    await container.read(localeControllerProvider.notifier).setLocale(null);

    expect(container.read(localeControllerProvider).value, isNull);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('locale'), isNull);
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/l10n/locale_provider_test.dart`
Expected: FAIL — `package:ouros_app/core/l10n/locale_provider.dart` does not exist.

- [ ] **Step 3: Write `LocaleController`**

`lib/core/l10n/locale_provider.dart`:

```dart
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/auth_providers.dart';

part 'locale_provider.g.dart';

@riverpod
class LocaleController extends _$LocaleController {
  static const _prefsKey = 'locale';

  @override
  Future<Locale?> build() async {
    final prefs = await ref.watch(sharedPreferencesProvider.future);
    final saved = prefs.getString(_prefsKey);
    return switch (saved) {
      'cs' => const Locale('cs'),
      'en' => const Locale('en'),
      _ => null,
    };
  }

  Future<void> setLocale(Locale? locale) async {
    state = AsyncData(locale);
    final prefs = await ref.read(sharedPreferencesProvider.future);
    if (locale == null) {
      await prefs.remove(_prefsKey);
    } else {
      await prefs.setString(_prefsKey, locale.languageCode);
    }
  }
}
```

- [ ] **Step 4: Generate the `.g.dart` file**

Run: `dart run build_runner build --delete-conflicting-outputs`

**Caution (per `AUDIT.md` section 4, same risk already documented for `theme_mode_provider.g.dart`):** this regenerates every `@riverpod`/`@freezed` file in `lib/`. Before committing, run `git status` / `git diff` and confirm only `lib/core/l10n/locale_provider.g.dart` is new. If any of `couple_model.freezed.dart`, `user_model.freezed.dart`, `event_model.freezed.dart`, `note_item.freezed.dart`, `memory_model.freezed.dart`, or `cycle_settings_model.freezed.dart` show a diff (e.g. losing `explicitToJson: true`), run `git checkout -- <that file>` to revert it before committing.

- [ ] **Step 5: Run tests to verify they pass**

Run: `flutter test test/l10n/locale_provider_test.dart`
Expected: PASS (4 tests)

- [ ] **Step 6: Commit**

```bash
git add lib/core/l10n/locale_provider.dart lib/core/l10n/locale_provider.g.dart test/l10n/locale_provider_test.dart
git commit -m "feat(l10n): add persisted LocaleController"
```

---

### Task 3: "Language" card in Settings

**Files:**
- Modify: `lib/features/lists/settings_screen.dart:1-12` (imports), `lib/features/lists/settings_screen.dart:508-509` (insert new card)

**Interfaces:**
- Consumes: `localeControllerProvider` + `.setLocale()` (Task 2).
- Produces: nothing consumed elsewhere.

- [ ] **Step 1: Add the import**

In `lib/features/lists/settings_screen.dart`, after the existing:

```dart
import '../../../core/theme/theme_mode_provider.dart';
```

add:

```dart
import '../../../core/l10n/locale_provider.dart';
```

- [ ] **Step 2: Insert the Language card**

In `lib/features/lists/settings_screen.dart`, the Appearance card ends at line 508 with:

```dart
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // Pairing button
```

Insert a new card between the closing `),` of Appearance and the `// Pairing button` comment, so it reads:

```dart
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // Language card
              Material(
                color: context.colors.card,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            PhosphorIconsBold.translate,
                            color: context.colors.primary,
                            size: 24,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Text(
                            'Language',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: context.colors.text,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Consumer(
                        builder: (context, ref, child) {
                          final currentLocale =
                              ref.watch(localeControllerProvider).valueOrNull;
                          return SegmentedButton<Locale?>(
                            segments: const [
                              ButtonSegment(
                                value: null,
                                label: Text('System'),
                              ),
                              ButtonSegment(
                                value: Locale('cs'),
                                label: Text('Čeština'),
                              ),
                              ButtonSegment(
                                value: Locale('en'),
                                label: Text('English'),
                              ),
                            ],
                            selected: {currentLocale},
                            onSelectionChanged: (selection) {
                              ref
                                  .read(localeControllerProvider.notifier)
                                  .setLocale(selection.first);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // Pairing button
```

Note: `PhosphorIconsBold.translate` is used for consistency with the existing `PhosphorIconsBold.moon` icon on the Appearance card — verify this icon name exists in the installed `phosphor_flutter: ^2.0.1` package (run Step 3 below; if the analyzer reports it's undefined, use `PhosphorIconsBold.globe` instead, which is a standard Phosphor icon name).

- [ ] **Step 3: Run static analysis**

Run: `flutter analyze lib/features/lists/settings_screen.dart`
Expected: no new errors. If `PhosphorIconsBold.translate` is reported as undefined, replace it with `PhosphorIconsBold.globe` and re-run.

- [ ] **Step 4: Manual verification**

Run: `flutter run`, open Settings, confirm a "Language" card appears below "Appearance" with System / Čeština / English segments, and that selecting a segment doesn't crash (visible app text won't change yet — string migration happens in later tasks).

- [ ] **Step 5: Commit**

```bash
git add lib/features/lists/settings_screen.dart
git commit -m "feat(settings): add Language selector"
```

---

### Task 4: Wire locale into `MaterialApp` and verify end-to-end

**Files:**
- Modify: `lib/app.dart`

**Interfaces:**
- Consumes: `localeControllerProvider` (Task 2), `AppLocalizations.localizationsDelegates` / `.supportedLocales` (Task 1).

- [ ] **Step 1: Modify `lib/app.dart`**

Current:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_provider.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';
```

Replace with:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_provider.dart';
import 'core/l10n/locale_provider.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';
import 'l10n/generated/app_localizations.dart';
```

Current `build`:

```dart
  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final themeMode =
        ref.watch(themeModeControllerProvider).valueOrNull ?? ThemeMode.system;
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'OurOS',
      themeMode: themeMode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
```

Replace with:

```dart
  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final themeMode =
        ref.watch(themeModeControllerProvider).valueOrNull ?? ThemeMode.system;
    final locale = ref.watch(localeControllerProvider).valueOrNull;
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'OurOS',
      themeMode: themeMode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
```

(Leave the rest of `build` — including the `builder:` callback — unchanged.)

- [ ] **Step 2: Run static analysis**

Run: `flutter analyze lib/app.dart`
Expected: no new errors.

- [ ] **Step 3: Manual end-to-end verification**

Run: `flutter run`. Go to Settings → Language → select "Čeština". Open the "Add Intimacy" sheet (Tracker tab → add button) and tap the date field to open the date picker (`lib/features/tracker/presentation/widgets/add_intimacy_sheet.dart:117`).
Expected: the date picker's built-in Material buttons (e.g. "Zrušit"/"OK" instead of "Cancel"/"OK") render in Czech, confirming `localizationsDelegates`/`locale` are wired correctly — even though the app's own strings aren't migrated yet. Switch back to "English" and confirm the picker reverts to "Cancel"/"OK".

- [ ] **Step 4: Commit**

```bash
git add lib/app.dart
git commit -m "feat(l10n): wire locale into MaterialApp"
```

---

### Task 5: Reference migration — fully localize the Data screen

This is the worked example every later feature-folder task follows: find every user-facing string literal, add matching `en`/`cs` ARB entries (reusing `common*` keys where they apply), replace the literal with `context.l10n.<key>`, and replace hardcoded weekday/month name arrays with locale-aware `intl` formatting.

**Files:**
- Modify: `lib/features/tracker/presentation/data_screen.dart` (all string literals + weekday/month arrays)
- Modify: `lib/l10n/app_en.arb`, `lib/l10n/app_cs.arb` (add `dataScreen*` keys)

**Interfaces:**
- Consumes: `context.l10n` (Task 1), `AppLocalizations` generated getters.
- Produces: nothing consumed elsewhere — demonstrates the pattern for Tasks 6+.

- [ ] **Step 1: Add the `dataScreen*` keys to both ARB files**

Add to `lib/l10n/app_en.arb` (keep existing `common*` keys, add these):

```json
  "dataScreenTitle": "Data & Analytics",
  "dataScreenError": "Error: {error}",
  "@dataScreenError": {
    "placeholders": { "error": { "type": "String" } }
  },
  "dataScreenHeading": "Relationship Insights",
  "dataScreenSubheading": "Track patterns and trends in your relationship",
  "dataScreenTotalCountTitle": "Total Count",
  "dataScreenAllTime": "All time",
  "dataScreenAvgPerWeekTitle": "Avg/Week",
  "dataScreenAverage": "Average",
  "dataScreenFavoriteDayTitle": "Favorite Day",
  "dataScreenMostActive": "Most active",
  "dataScreenBestOfHeading": "Best Of",
  "dataScreenLongestSexTitle": "Longest Sex",
  "dataScreenThisMonthSubtitle": "This month",
  "dataScreenHeartsStreakTitle": "Hearts Streak",
  "dataScreenStreakDaySubtitle": "{count, plural, one{day in a row} other{days in a row}}",
  "@dataScreenStreakDaySubtitle": {
    "placeholders": { "count": { "type": "int" } }
  },
  "dataScreenCurrentMonthHeading": "This Month",
  "dataScreenTotalTitle": "Total",
  "dataScreenAvgDurationTitle": "Avg Duration",
  "dataScreenAvgOrgasmsTitle": "Avg Orgasms",
  "dataScreenFrequencyChartHeading": "Frequency Chart",
  "dataScreenInitiatorChartHeading": "Initiator Chart",
  "dataScreenYouLabel": "You",
  "dataScreenPartnerLabel": "Partner",
  "dataScreenOrgasmComparisonHeading": "Orgasm Comparison",
  "dataScreenNoDataYet": "No data yet",
  "dataScreenTagsRadarHeading": "Tags Radar",
  "dataScreenNoTagsYet": "No tags yet",
  "dataScreenHistoryHeading": "History"
```

Add to `lib/l10n/app_cs.arb` (keep existing `common*` keys, add these):

```json
  "dataScreenTitle": "Data a analýzy",
  "dataScreenError": "Chyba: {error}",
  "dataScreenHeading": "Přehled vztahu",
  "dataScreenSubheading": "Sleduj vzorce a trendy ve vašem vztahu",
  "dataScreenTotalCountTitle": "Celkem",
  "dataScreenAllTime": "Za celou dobu",
  "dataScreenAvgPerWeekTitle": "Prům./týden",
  "dataScreenAverage": "Průměr",
  "dataScreenFavoriteDayTitle": "Oblíbený den",
  "dataScreenMostActive": "Nejaktivnější",
  "dataScreenBestOfHeading": "To nejlepší",
  "dataScreenLongestSexTitle": "Nejdelší sex",
  "dataScreenThisMonthSubtitle": "Tento měsíc",
  "dataScreenHeartsStreakTitle": "Série srdíček",
  "dataScreenStreakDaySubtitle": "{count, plural, one{den v řadě} few{dny v řadě} many{dne v řadě} other{dní v řadě}}",
  "dataScreenCurrentMonthHeading": "Tento měsíc",
  "dataScreenTotalTitle": "Celkem",
  "dataScreenAvgDurationTitle": "Prům. délka",
  "dataScreenAvgOrgasmsTitle": "Prům. orgasmy",
  "dataScreenFrequencyChartHeading": "Graf četnosti",
  "dataScreenInitiatorChartHeading": "Graf iniciace",
  "dataScreenYouLabel": "Ty",
  "dataScreenPartnerLabel": "Partner",
  "dataScreenOrgasmComparisonHeading": "Porovnání orgasmů",
  "dataScreenNoDataYet": "Zatím žádná data",
  "dataScreenTagsRadarHeading": "Radar štítků",
  "dataScreenNoTagsYet": "Zatím žádné štítky",
  "dataScreenHistoryHeading": "Historie"
```

(The ICU `@dataScreenError` / `@dataScreenStreakDaySubtitle` metadata blocks only need to exist once, in the template `app_en.arb` — `flutter gen-l10n` uses the template's placeholder metadata for both locales.)

- [ ] **Step 2: Regenerate and verify the new keys compile**

Run: `flutter gen-l10n`
Expected: no errors; `AppLocalizations` now exposes `dataScreenTitle`, `dataScreenError(String error)`, `dataScreenStreakDaySubtitle(int count)`, etc.

- [ ] **Step 3: Add the `intl` and `context.l10n` imports to `data_screen.dart`**

At the top of `lib/features/tracker/presentation/data_screen.dart`, after:

```dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
```

add:

```dart
import 'package:intl/intl.dart';
```

and after the existing:

```dart
import '../../../core/theme/app_theme.dart';
```

add:

```dart
import '../../../core/l10n/build_context_l10n_extension.dart';
```

- [ ] **Step 4: Replace the AppBar title and error text**

Change:

```dart
      appBar: AppBar(title: const Text('Data & Analytics')),
```

to:

```dart
      appBar: AppBar(title: Text(context.l10n.dataScreenTitle)),
```

Change:

```dart
          error: (error, stack) => Center(
            child: Text('Error: ${error.toString()}'),
          ),
```

to:

```dart
          error: (error, stack) => Center(
            child: Text(context.l10n.dataScreenError(error.toString())),
          ),
```

- [ ] **Step 5: Replace the heading/subheading**

Change:

```dart
                        Text(
                          'Relationship Insights',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: context.colors.text,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Track patterns and trends in your relationship',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
```

to:

```dart
                        Text(
                          context.l10n.dataScreenHeading,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: context.colors.text,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          context.l10n.dataScreenSubheading,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
```

- [ ] **Step 6: Replace History heading**

Change:

```dart
                    child: Text(
                      'History',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
```

to:

```dart
                    child: Text(
                      context.l10n.dataScreenHistoryHeading,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
```

- [ ] **Step 7: `_StatsRow` — replace titles/subtitles and the weekday array**

Change:

```dart
    // Calculate favorite day
    final dayCounts = <int, int>{};
    for (final log in logs) {
      final weekday = log.date.weekday;
      dayCounts[weekday] = (dayCounts[weekday] ?? 0) + 1;
    }
    final favoriteDayIndex = dayCounts.entries.isEmpty
        ? 1
        : dayCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final favoriteDay = weekdays[favoriteDayIndex - 1];

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: PhosphorIconsBold.heart,
            title: 'Total Count',
            value: totalCount.toString(),
            subtitle: 'All time',
            color: context.colors.love,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _StatCard(
            icon: PhosphorIconsBold.calendar,
            title: 'Avg/Week',
            value: avgPerWeek.toStringAsFixed(1),
            subtitle: 'Average',
            color: context.colors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _StatCard(
            icon: PhosphorIconsBold.star,
            title: 'Favorite Day',
            value: favoriteDay,
            subtitle: 'Most active',
            color: context.colors.warning,
          ),
        ),
      ],
    );
```

to:

```dart
    // Calculate favorite day
    final dayCounts = <int, int>{};
    for (final log in logs) {
      final weekday = log.date.weekday;
      dayCounts[weekday] = (dayCounts[weekday] ?? 0) + 1;
    }
    final favoriteDayIndex = dayCounts.entries.isEmpty
        ? 1
        : dayCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    // DateTime(2024, 1, N) for N=1..7 lands on Mon..Sun respectively, so this
    // is a locale-agnostic way to format an arbitrary weekday index.
    final favoriteDay = DateFormat.E(Localizations.localeOf(context).toString())
        .format(DateTime(2024, 1, favoriteDayIndex));

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: PhosphorIconsBold.heart,
            title: context.l10n.dataScreenTotalCountTitle,
            value: totalCount.toString(),
            subtitle: context.l10n.dataScreenAllTime,
            color: context.colors.love,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _StatCard(
            icon: PhosphorIconsBold.calendar,
            title: context.l10n.dataScreenAvgPerWeekTitle,
            value: avgPerWeek.toStringAsFixed(1),
            subtitle: context.l10n.dataScreenAverage,
            color: context.colors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _StatCard(
            icon: PhosphorIconsBold.star,
            title: context.l10n.dataScreenFavoriteDayTitle,
            value: favoriteDay,
            subtitle: context.l10n.dataScreenMostActive,
            color: context.colors.warning,
          ),
        ),
      ],
    );
```

- [ ] **Step 8: `_BestOfCarousel` — replace heading, titles, and the streak plural**

Change:

```dart
              Text(
                'Best Of',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
```

to:

```dart
              Text(
                context.l10n.dataScreenBestOfHeading,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
```

Change the `cards` list:

```dart
    final cards = [
      _StatCard(
        icon: PhosphorIconsBold.trophy,
        title: 'Longest Sex',
        value: allTimeLongest == null ? '–' : '${allTimeLongest}m',
        subtitle: 'All time',
        color: context.colors.primary,
      ),
      _StatCard(
        icon: PhosphorIconsBold.clock,
        title: 'Longest Sex',
        value: monthLongest == null ? '–' : '${monthLongest}m',
        subtitle: 'This month',
        color: context.colors.warning,
      ),
      _StatCard(
        icon: PhosphorIconsBold.fire,
        title: 'Hearts Streak',
        value: streak.toString(),
        subtitle: streak == 1 ? 'day in a row' : 'days in a row',
        color: context.colors.love,
      ),
    ];
```

to:

```dart
    final cards = [
      _StatCard(
        icon: PhosphorIconsBold.trophy,
        title: context.l10n.dataScreenLongestSexTitle,
        value: allTimeLongest == null ? '–' : '${allTimeLongest}m',
        subtitle: context.l10n.dataScreenAllTime,
        color: context.colors.primary,
      ),
      _StatCard(
        icon: PhosphorIconsBold.clock,
        title: context.l10n.dataScreenLongestSexTitle,
        value: monthLongest == null ? '–' : '${monthLongest}m',
        subtitle: context.l10n.dataScreenThisMonthSubtitle,
        color: context.colors.warning,
      ),
      _StatCard(
        icon: PhosphorIconsBold.fire,
        title: context.l10n.dataScreenHeartsStreakTitle,
        value: streak.toString(),
        subtitle: context.l10n.dataScreenStreakDaySubtitle(streak),
        color: context.colors.love,
      ),
    ];
```

- [ ] **Step 9: `_CurrentMonthStats` — replace heading and card labels**

Change:

```dart
              Text(
                'This Month',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
```

to:

```dart
              Text(
                context.l10n.dataScreenCurrentMonthHeading,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
```

Change the three `_StatCard`s' `title`/`subtitle` (keep the swipeable-carousel structure from the earlier "Swipeable This Month Stats" plan if it has already been applied — only the string literals change):

```dart
                  title: 'Total',
                  value: stats.count.toString(),
                  subtitle: 'This month',
```

to:

```dart
                  title: context.l10n.dataScreenTotalTitle,
                  value: stats.count.toString(),
                  subtitle: context.l10n.dataScreenThisMonthSubtitle,
```

```dart
                  title: 'Avg Duration',
                  value: stats.avgDurationMinutes == null
                      ? '–'
                      : '${stats.avgDurationMinutes!.toStringAsFixed(1)}m',
                  subtitle: 'This month',
```

to:

```dart
                  title: context.l10n.dataScreenAvgDurationTitle,
                  value: stats.avgDurationMinutes == null
                      ? '–'
                      : '${stats.avgDurationMinutes!.toStringAsFixed(1)}m',
                  subtitle: context.l10n.dataScreenThisMonthSubtitle,
```

```dart
                  title: 'Avg Orgasms',
                  value: stats.avgOrgasms.toStringAsFixed(1),
                  subtitle: 'This month',
```

to:

```dart
                  title: context.l10n.dataScreenAvgOrgasmsTitle,
                  value: stats.avgOrgasms.toStringAsFixed(1),
                  subtitle: context.l10n.dataScreenThisMonthSubtitle,
```

- [ ] **Step 10: `_FrequencyChart` — replace heading and the month-abbreviation array**

Change:

```dart
    final monthLabels = months.map((m) {
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return months[m.month - 1];
    }).toList();
```

to:

```dart
    final localeName = Localizations.localeOf(context).toString();
    final monthLabels = months.map((m) => DateFormat.MMM(localeName).format(m)).toList();
```

(This also fixes a latent bug: the original code shadowed the outer `months` list with an inner `months` array of the same name.)

Change:

```dart
              Text(
                'Frequency Chart',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
```

to:

```dart
              Text(
                context.l10n.dataScreenFrequencyChartHeading,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
```

- [ ] **Step 11: `_InitiatorChart` — replace heading and legend labels**

Change:

```dart
              Text(
                'Initiator Chart',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
```

to:

```dart
              Text(
                context.l10n.dataScreenInitiatorChartHeading,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
```

Change:

```dart
                    _LegendItem(
                      color: context.colors.primary,
                      label: 'You',
                      count: currentUserCount,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _LegendItem(
                      color: context.colors.love,
                      label: 'Partner',
                      count: partnerCount,
                    ),
```

to:

```dart
                    _LegendItem(
                      color: context.colors.primary,
                      label: context.l10n.dataScreenYouLabel,
                      count: currentUserCount,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _LegendItem(
                      color: context.colors.love,
                      label: context.l10n.dataScreenPartnerLabel,
                      count: partnerCount,
                    ),
```

- [ ] **Step 12: `_OrgasmComparisonChart` — replace heading (both branches), empty state, and legend labels**

Both the `total == 0` branch and the normal branch have:

```dart
                Text(
                  'Orgasm Comparison',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
```

Change both occurrences to:

```dart
                Text(
                  context.l10n.dataScreenOrgasmComparisonHeading,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
```

Change:

```dart
            Center(
              child: Text(
                'No data yet',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
```

to:

```dart
            Center(
              child: Text(
                context.l10n.dataScreenNoDataYet,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
```

Change:

```dart
                    _LegendItem(
                      color: context.colors.primary,
                      label: 'You',
                      count: totals.user,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _LegendItem(
                      color: context.colors.love,
                      label: 'Partner',
                      count: totals.partner,
                    ),
```

to:

```dart
                    _LegendItem(
                      color: context.colors.primary,
                      label: context.l10n.dataScreenYouLabel,
                      count: totals.user,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _LegendItem(
                      color: context.colors.love,
                      label: context.l10n.dataScreenPartnerLabel,
                      count: totals.partner,
                    ),
```

- [ ] **Step 13: `_TagsRadarChart` — replace heading (both branches) and empty state**

Both the `topTags.isEmpty` branch and the normal branch have:

```dart
                Text(
                  'Tags Radar',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
```

Change both occurrences to:

```dart
                Text(
                  context.l10n.dataScreenTagsRadarHeading,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
```

Change:

```dart
            Center(
              child: Text(
                'No tags yet',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
```

to:

```dart
            Center(
              child: Text(
                context.l10n.dataScreenNoTagsYet,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
```

- [ ] **Step 14: Run static analysis**

Run: `flutter analyze lib/features/tracker/presentation/data_screen.dart`
Expected: no new errors (the unrelated pre-existing `_LegendItem`/`$label ($count)` interpolation is intentionally left as-is — it's structural formatting, not natural-language content).

- [ ] **Step 15: Manual verification**

Run: `flutter run`, open Data screen with Language = English, confirm it looks identical to before. Switch Language = Čeština in Settings, return to Data screen, confirm every heading/card label/empty-state string is now Czech, the favorite-day and frequency-chart month labels show Czech abbreviations (e.g. "po", "led"), and the Hearts Streak subtitle pluralizes correctly for a streak of 1 vs. more than 1 (you can temporarily force a couple of different streak values while testing, e.g. via `heartsStreak`'s inputs, then revert).

- [ ] **Step 16: Commit**

```bash
git add lib/features/tracker/presentation/data_screen.dart lib/l10n/app_en.arb lib/l10n/app_cs.arb lib/l10n/generated/
git commit -m "feat(l10n): localize Data screen (reference migration)"
```

---

### Task 6: Localize remaining Tracker files

**Files:**
- Modify: `lib/features/tracker/presentation/widgets/add_intimacy_sheet.dart`
- Modify: `lib/features/tracker/presentation/screens/intimacy_history_screen.dart`
- Modify: `lib/features/tracker/presentation/widgets/intimacy_history_list.dart`
- Modify: `lib/features/tracker/presentation/widgets/intimacy_log_detail_sheet.dart`
- Modify: `lib/l10n/app_en.arb`, `lib/l10n/app_cs.arb`

**Interfaces:**
- Consumes: `context.l10n` (Task 1), same pattern as Task 5.
- Produces: nothing consumed elsewhere.

- [ ] **Step 1: Apply the Task 5 procedure to every file in this task**

For each file listed above:

1. Search it for every user-facing string literal using these patterns (run against the file, e.g. `grep -nE "Text\('|Text\(\"|title: ?'|title: ?\"|labelText: ?'|hintText: ?'|content: Text|SnackBar\(|AlertDialog\(|tooltip: ?'" <file>`), plus manually scan for `AppBar(title: ...)`, button `child: Text(...)`, and validator/error message strings.
2. For each string found:
   - If it is exactly "Cancel", "Delete", "Edit", "Confirm", or "Save", replace it with the matching `context.l10n.common<Word>` key (already defined in Task 1) instead of creating a new key.
   - Otherwise, add a new key to both `lib/l10n/app_en.arb` and `lib/l10n/app_cs.arb`, prefixed `addIntimacySheet`, `intimacyHistoryScreen`, `intimacyHistoryList`, or `intimacyLogDetailSheet` respectively (matching the file), followed by a `PascalCase` description, e.g. `addIntimacySheetSaveButton`.
   - For strings with interpolated values (e.g. `'Deleted $count logs'`), use an ICU placeholder exactly as shown in Task 5 Step 1 (the `dataScreenError` example) — parameter type `String`/`int`/`num` to match the interpolated value's type.
   - Replace the literal in the Dart source with `context.l10n.<key>` (add `import '../../../core/l10n/build_context_l10n_extension.dart';` — adjust the relative path per the file's actual location — if not already present).
3. Known anchor strings already confirmed present in this folder (from a preliminary scan) that must be covered: `'Data & Analytics'` (already done in Task 5 — skip), `'Delete'`, `'Delete intimacy log?'`, `'Edit'`, `'Cancel'`. Treat these as a lower bound, not the full list — read each file fully; there are more strings than this anchor sample.

- [ ] **Step 2: Regenerate**

Run: `flutter gen-l10n`
Expected: no errors.

- [ ] **Step 3: Run static analysis**

Run: `flutter analyze lib/features/tracker/`
Expected: no new errors.

- [ ] **Step 4: Manual verification**

Run: `flutter run`, switch Language = Čeština, open the Tracker tab, add a log, view history, open a log detail, delete a log. Confirm every screen/dialog in this flow shows Czech text with no leftover English strings and no layout breakage from longer Czech text.

- [ ] **Step 5: Commit**

```bash
git add lib/features/tracker/ lib/l10n/app_en.arb lib/l10n/app_cs.arb lib/l10n/generated/
git commit -m "feat(l10n): localize remaining Tracker screens"
```

---

### Task 7: Localize Dashboard feature (27 files)

**Files:**
- Modify: all files under `lib/features/dashboard/` containing user-facing text (discover via the search patterns in Task 6 Step 1; expect the majority of the 27 files to need changes — dashboard is the app's main screen)
- Modify: `lib/l10n/app_en.arb`, `lib/l10n/app_cs.arb`

**Interfaces:**
- Consumes: `context.l10n` (Task 1), same pattern as Task 5/6.

- [ ] **Step 1: Apply the Task 5 procedure (as detailed in Task 6 Step 1) to every file under `lib/features/dashboard/`**

Known anchor strings already confirmed present in this folder (lower bound, not exhaustive): `'Cancel'`, `'Could not send message: $e'`, `'Could not send touch: $e'`, `'Error: $e'`, `'Error sending: $error'`. Prefix new keys `dashboard<FileContext><Description>`, e.g. `dashboardTouchSendError`. Error-interpolation strings like `'Could not send message: $e'` use an ICU `{error}` placeholder exactly like `dataScreenError` in Task 5.

- [ ] **Step 2: Regenerate**

Run: `flutter gen-l10n`
Expected: no errors.

- [ ] **Step 3: Run static analysis**

Run: `flutter analyze lib/features/dashboard/`
Expected: no new errors.

- [ ] **Step 4: Manual verification**

Run: `flutter run`, switch Language = Čeština, walk through the Dashboard tab and every widget/sheet reachable from it (touch/haptic signals, quick messages, any dashboard cards). Confirm no leftover English strings and no layout breakage.

- [ ] **Step 5: Commit**

```bash
git add lib/features/dashboard/ lib/l10n/app_en.arb lib/l10n/app_cs.arb lib/l10n/generated/
git commit -m "feat(l10n): localize Dashboard feature"
```

---

### Task 8: Localize Auth feature (11 files)

**Files:**
- Modify: all files under `lib/features/auth/` containing user-facing text (login/signup/pairing screens and dialogs)
- Modify: `lib/l10n/app_en.arb`, `lib/l10n/app_cs.arb`

**Interfaces:**
- Consumes: `context.l10n` (Task 1).

- [ ] **Step 1: Apply the Task 5 procedure (as detailed in Task 6 Step 1) to every file under `lib/features/auth/`**

Known anchors (lower bound): `'Account not found'`, `'Are you sure you want to sign out?'`, `'Cancel'`, `'Choose Image'`, `'Connect with Partner'`. Prefix new keys `auth<FileContext><Description>`.

- [ ] **Step 2: Regenerate**

Run: `flutter gen-l10n`

- [ ] **Step 3: Run static analysis**

Run: `flutter analyze lib/features/auth/`

- [ ] **Step 4: Manual verification**

Run: `flutter run`, switch Language = Čeština, sign out and back in, walk through partner-pairing flow and any account dialogs. Confirm no leftover English strings.

- [ ] **Step 5: Commit**

```bash
git add lib/features/auth/ lib/l10n/app_en.arb lib/l10n/app_cs.arb lib/l10n/generated/
git commit -m "feat(l10n): localize Auth feature"
```

---

### Task 9: Localize Timeline feature (9 files)

**Files:**
- Modify: all files under `lib/features/timeline/` containing user-facing text (memories, map/place details)
- Modify: `lib/l10n/app_en.arb`, `lib/l10n/app_cs.arb`

**Interfaces:**
- Consumes: `context.l10n` (Task 1).

- [ ] **Step 1: Apply the Task 5 procedure (as detailed in Task 6 Step 1) to every file under `lib/features/timeline/`**

Known anchors (lower bound): `'Cancel'`, `'Confirm'`, `'Could not load place details'`, `'Delete memory?'`, `'Edit'`. Prefix new keys `timeline<FileContext><Description>`.

- [ ] **Step 2: Regenerate**

Run: `flutter gen-l10n`

- [ ] **Step 3: Run static analysis**

Run: `flutter analyze lib/features/timeline/`

- [ ] **Step 4: Manual verification**

Run: `flutter run`, switch Language = Čeština, walk through adding/editing/deleting a memory including any map/place picker screens. Confirm no leftover English strings.

- [ ] **Step 5: Commit**

```bash
git add lib/features/timeline/ lib/l10n/app_en.arb lib/l10n/app_cs.arb lib/l10n/generated/
git commit -m "feat(l10n): localize Timeline feature"
```

---

### Task 10: Localize Cycle feature (7 files)

**Files:**
- Modify: all files under `lib/features/cycle/` containing user-facing text
- Modify: `lib/l10n/app_en.arb`, `lib/l10n/app_cs.arb`

**Interfaces:**
- Consumes: `context.l10n` (Task 1).

- [ ] **Step 1: Apply the Task 5 procedure (as detailed in Task 6 Step 1) to every file under `lib/features/cycle/`**

Known anchors (lower bound): `'Add Event'`, `'Add Intimacy'`, `'Add Memory'`, `'Add Period Log'`, `'Error: ${e.toString()}'`. Prefix new keys `cycle<FileContext><Description>`.

- [ ] **Step 2: Regenerate**

Run: `flutter gen-l10n`

- [ ] **Step 3: Run static analysis**

Run: `flutter analyze lib/features/cycle/`

- [ ] **Step 4: Manual verification**

Run: `flutter run`, switch Language = Čeština, open the Cycle screen, log a period, and use any quick-add menu it exposes. Confirm no leftover English strings.

- [ ] **Step 5: Commit**

```bash
git add lib/features/cycle/ lib/l10n/app_en.arb lib/l10n/app_cs.arb lib/l10n/generated/
git commit -m "feat(l10n): localize Cycle feature"
```

---

### Task 11: Localize Blueprints feature (8 files)

**Files:**
- Modify: all files under `lib/features/blueprints/` containing user-facing text
- Modify: `lib/l10n/app_en.arb`, `lib/l10n/app_cs.arb`

**Interfaces:**
- Consumes: `context.l10n` (Task 1).

- [ ] **Step 1: Apply the Task 5 procedure (as detailed in Task 6 Step 1) to every file under `lib/features/blueprints/`**

Known anchor (lower bound): `'Section complete!'`. Prefix new keys `blueprints<FileContext><Description>`. Note: `lib/features/blueprints/data/blueprint_mock_data.dart` was flagged earlier as containing the word "monthly" — check whether it holds actual Blueprint *content* (user-generated-style long-form text) rather than UI chrome; if so, treat it like `premium_copy.dart` and leave it out of scope, matching the design's "only static UI chrome" boundary. If it's short UI labels, localize normally.

- [ ] **Step 2: Regenerate**

Run: `flutter gen-l10n`

- [ ] **Step 3: Run static analysis**

Run: `flutter analyze lib/features/blueprints/`

- [ ] **Step 4: Manual verification**

Run: `flutter run`, switch Language = Čeština, open Blueprints, complete a section. Confirm no leftover English strings in UI chrome (buttons, headers, progress indicators).

- [ ] **Step 5: Commit**

```bash
git add lib/features/blueprints/ lib/l10n/app_en.arb lib/l10n/app_cs.arb lib/l10n/generated/
git commit -m "feat(l10n): localize Blueprints feature UI chrome"
```

---

### Task 12: Localize Gamification feature (8 files)

**Files:**
- Modify: all files under `lib/features/gamification/` containing user-facing text
- Modify: `lib/l10n/app_en.arb`, `lib/l10n/app_cs.arb`

**Interfaces:**
- Consumes: `context.l10n` (Task 1).

- [ ] **Step 1: Apply the Task 5 procedure (as detailed in Task 6 Step 1) to every file under `lib/features/gamification/`**

Known anchors (lower bound): `'Get DYOS+'`, `'System Status (Preview)'`, `'View roadmap'`, `'Watch'`. Prefix new keys `gamification<FileContext><Description>`. `'Get DYOS+'` is a paywall entry-point label (short UI chrome, in scope) — distinct from the excluded long-form marketing copy in `premium_copy.dart`.

- [ ] **Step 2: Regenerate**

Run: `flutter gen-l10n`

- [ ] **Step 3: Run static analysis**

Run: `flutter analyze lib/features/gamification/`

- [ ] **Step 4: Manual verification**

Run: `flutter run`, switch Language = Čeština, view gamification/streak UI and the roadmap preview. Confirm no leftover English strings.

- [ ] **Step 5: Commit**

```bash
git add lib/features/gamification/ lib/l10n/app_en.arb lib/l10n/app_cs.arb lib/l10n/generated/
git commit -m "feat(l10n): localize Gamification feature"
```

---

### Task 13: Localize Events feature (5 files)

**Files:**
- Modify: all files under `lib/features/events/` containing user-facing text
- Modify: `lib/l10n/app_en.arb`, `lib/l10n/app_cs.arb`

**Interfaces:**
- Consumes: `context.l10n` (Task 1).

- [ ] **Step 1: Apply the Task 5 procedure (as detailed in Task 6 Step 1) to every file under `lib/features/events/`**

Known anchors (lower bound): `'Add event'`, `'Are you sure you want to delete "${event.title}"?'`, `'Cancel'`, `'Delete'`, `'Delete Event'`. The delete-confirmation string interpolates `event.title` — use an ICU `{title}` placeholder exactly like `dataScreenError` in Task 5. Prefix new keys `events<FileContext><Description>`.

- [ ] **Step 2: Regenerate**

Run: `flutter gen-l10n`

- [ ] **Step 3: Run static analysis**

Run: `flutter analyze lib/features/events/`

- [ ] **Step 4: Manual verification**

Run: `flutter run`, switch Language = Čeština, add and delete an event. Confirm no leftover English strings, including in the delete-confirmation dialog with the interpolated event title.

- [ ] **Step 5: Commit**

```bash
git add lib/features/events/ lib/l10n/app_en.arb lib/l10n/app_cs.arb lib/l10n/generated/
git commit -m "feat(l10n): localize Events feature"
```

---

### Task 14: Localize Notes feature (5 files)

**Files:**
- Modify: all files under `lib/features/notes/` containing user-facing text
- Modify: `lib/l10n/app_en.arb`, `lib/l10n/app_cs.arb`

**Interfaces:**
- Consumes: `context.l10n` (Task 1).

- [ ] **Step 1: Apply the Task 5 procedure (as detailed in Task 6 Step 1) to every file under `lib/features/notes/`**

Known anchors (lower bound): `'Add Note'`, `'Content cannot be empty'`, `'Error saving note: ${e.toString()}'`, `'Note saved successfully!'`, `'Secret Notes'`. Prefix new keys `notes<FileContext><Description>`.

- [ ] **Step 2: Regenerate**

Run: `flutter gen-l10n`

- [ ] **Step 3: Run static analysis**

Run: `flutter analyze lib/features/notes/`

- [ ] **Step 4: Manual verification**

Run: `flutter run`, switch Language = Čeština, add a secret note (including the empty-content validation error and the save-success message). Confirm no leftover English strings.

- [ ] **Step 5: Commit**

```bash
git add lib/features/notes/ lib/l10n/app_en.arb lib/l10n/app_cs.arb lib/l10n/generated/
git commit -m "feat(l10n): localize Notes feature"
```

---

### Task 15: Localize Premium feature — UI chrome only (5 files)

**Files:**
- Modify: files under `lib/features/premium/presentation/` and `lib/features/premium/` containing short UI chrome (buttons, labels, headers)
- Do NOT modify: `lib/features/premium/domain/premium_copy.dart` (out of scope per the design — long-form marketing copy)
- Modify: `lib/l10n/app_en.arb`, `lib/l10n/app_cs.arb`

**Interfaces:**
- Consumes: `context.l10n` (Task 1).

- [ ] **Step 1: Apply the Task 5 procedure (as detailed in Task 6 Step 1) to files under `lib/features/premium/`, EXCLUDING `premium_copy.dart`**

Known anchor (lower bound): `'DYOS+'` — this is a brand/product name, not translatable content; leave it as a literal, not an ARB key (same treatment as `'OurOS'` in `app.dart`, per the design's "brand name" precedent). Scan the remaining premium files (paywall modal chrome, landing screen chrome — buttons like "Continue", "Restore Purchases", "Maybe Later", loading/error states) for genuine UI-chrome strings and localize those. If a string is clearly persuasive marketing copy (a paragraph or multi-sentence pitch) rather than a UI control label, leave it as-is and note it in the commit message — do not silently expand scope into `premium_copy.dart`-style content. Prefix new keys `premium<FileContext><Description>`.

- [ ] **Step 2: Regenerate**

Run: `flutter gen-l10n`

- [ ] **Step 3: Run static analysis**

Run: `flutter analyze lib/features/premium/`

- [ ] **Step 4: Manual verification**

Run: `flutter run`, switch Language = Čeština, open the paywall modal and premium landing screen. Confirm button/control chrome is Czech while marketing paragraphs remain English (expected, per scope) and nothing looks broken/mixed in a jarring way (e.g. a Czech button next to an English button).

- [ ] **Step 5: Commit**

```bash
git add lib/features/premium/ lib/l10n/app_en.arb lib/l10n/app_cs.arb lib/l10n/generated/
git commit -m "feat(l10n): localize Premium UI chrome (marketing copy excluded)"
```

---

### Task 16: Localize remaining Lists feature file

**Files:**
- Modify: `lib/features/lists/lists_screen.dart`
- Modify: `lib/features/lists/settings_screen.dart` (remaining strings not yet covered by Task 3's Language card, e.g. "Delete Account" dialog, "Appearance"/"Language" card headers themselves, sign-out confirmation, error messages)
- Modify: `lib/l10n/app_en.arb`, `lib/l10n/app_cs.arb`

**Interfaces:**
- Consumes: `context.l10n` (Task 1).

- [ ] **Step 1: Apply the Task 5 procedure (as detailed in Task 6 Step 1) to `lib/features/lists/lists_screen.dart` and the remainder of `lib/features/lists/settings_screen.dart`**

Known anchors (lower bound): `'Anniversary date updated'`, `'Are you sure you want to log out?'`, `'Dark'` / `'Light'` / `'System'` (the Appearance `SegmentedButton` labels — localize these too, plus the "Appearance" and "Language" card headers, and the "System"/"Čeština"/"English" labels added in Task 3), `'Deleting account...'`, `'Error deleting account: ${e.toString()}'`. Prefix new keys `settingsScreen<Description>` / `listsScreen<Description>`.

- [ ] **Step 2: Regenerate**

Run: `flutter gen-l10n`

- [ ] **Step 3: Run static analysis**

Run: `flutter analyze lib/features/lists/`

- [ ] **Step 4: Manual verification**

Run: `flutter run`, switch Language = Čeština, open Settings and the Lists screen, exercise sign-out and account-deletion confirmation dialogs (cancel out, don't actually delete). Confirm no leftover English strings, including the Appearance/Language card headers and segment labels themselves.

- [ ] **Step 5: Commit**

```bash
git add lib/features/lists/ lib/l10n/app_en.arb lib/l10n/app_cs.arb lib/l10n/generated/
git commit -m "feat(l10n): localize Lists/Settings screens"
```

---

### Task 17: Localize shared `lib/core` widgets

**Files:**
- Modify: any file under `lib/core` containing user-facing text — expect meaningful hits primarily in `lib/core/widgets/dyos_universal_calendar.dart` and `lib/core/services/pairing_exceptions.dart` (if its exception messages are shown directly to users via a SnackBar/dialog elsewhere); most of `lib/core` is services/config/routing with no UI text and should be left untouched
- Modify: `lib/l10n/app_en.arb`, `lib/l10n/app_cs.arb`

**Interfaces:**
- Consumes: `context.l10n` (Task 1).

- [ ] **Step 1: Identify files with real UI text**

Run: `grep -rlE "Text\('|Text\(\"|title: ?'|labelText: ?'|hintText: ?'|SnackBar\(" lib/core --include="*.dart" | grep -v -E "\.g\.dart|\.freezed\.dart"`
Expected output: a short list (most of `lib/core`'s 21 files are services/config with no matches — that's expected and correct, not a gap).

- [ ] **Step 2: Apply the Task 5 procedure (as detailed in Task 6 Step 1) to each file found**

Prefix new keys `core<FileContext><Description>`. For `pairing_exceptions.dart`: only localize a message if it's surfaced verbatim to the user in the UI (trace its usage with `grep -rn "<ExceptionClassName>" lib/features/`); if it's only used for internal logging/debugging, leave it as a plain English string.

- [ ] **Step 3: Regenerate**

Run: `flutter gen-l10n`

- [ ] **Step 4: Run static analysis**

Run: `flutter analyze lib/core/`

- [ ] **Step 5: Manual verification**

Run: `flutter run`, switch Language = Čeština, open any calendar view (`dyos_universal_calendar.dart` is used from multiple features — check `grep -rn "DyosUniversalCalendar" lib/features/` for a concrete screen to test) and trigger a pairing-related error path if one is reachable in dev (e.g. invalid pairing code). Confirm no leftover English strings in the parts that were changed.

- [ ] **Step 6: Commit**

```bash
git add lib/core/ lib/l10n/app_en.arb lib/l10n/app_cs.arb lib/l10n/generated/
git commit -m "feat(l10n): localize shared core widgets"
```

---

### Task 18: Full-app regression pass

**Files:**
- None expected (verification-only task); fix any stragglers found using the Task 5/6 procedure, touching whichever files have leftover strings.

**Interfaces:**
- Consumes: everything from Tasks 1–17.

- [ ] **Step 1: Whole-project static analysis**

Run: `flutter analyze`
Expected: no errors. Pay particular attention to any `unused_translation` / missing-ARB-key warnings from `flutter gen-l10n` output during the build — resolve any key present in `app_en.arb` but missing from `app_cs.arb` (or vice versa) by adding the missing translation.

- [ ] **Step 2: Whole-project test suite**

Run: `flutter test`
Expected: all tests pass, including `test/l10n/locale_provider_test.dart` (Task 2) and every pre-existing test untouched by this plan.

- [ ] **Step 3: Manual full walkthrough**

Run: `flutter run`. With Language = Čeština, walk through every bottom-nav tab (Dashboard, Data, Tracker/Cycle, Blueprints, Lists/Settings) and every sheet/dialog reachable with 1–2 taps from each. Note any remaining English string that should have been caught by Tasks 6–17 and fix it in place (same procedure: add ARB key to both locales, replace literal, regenerate). Repeat with Language = System (device set to Czech) to confirm automatic system-locale detection also works, then confirm Language = English still renders the original English UI unchanged.

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "fix(l10n): address stragglers from full-app regression pass"
```

(If Step 3 found nothing to fix, skip this commit — there's nothing to commit.)

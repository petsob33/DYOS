# Czech/English localization — design

## Context

All UI text in the app is currently hardcoded in English across ~120 Dart
files (dashboard, tracker/Data screen, blueprints, premium/paywall,
settings, chat, gamification, etc.). There is no `flutter_localizations` /
`intl` setup, no ARB files, and no locale switching.

## Goal

Add Czech and English localization for all everyday UI text (buttons,
screen titles, labels, statuses, error messages, stat labels, etc.), with
English as the default and a manual override in Settings. Longer legal and
marketing copy (Terms of Service, Privacy Policy, premium/paywall marketing
copy in `premium_copy.dart`) is out of scope and stays English-only.

## Approach

Use Flutter's official localization tooling: `flutter_localizations` +
`intl` + `flutter gen-l10n`, generating a type-safe `AppLocalizations`
class. Rejected alternative: `easy_localization` (JSON-based) — adds a
runtime dependency and loses compile-time key checking for no benefit here,
since the app already ships `intl`-compatible tooling via Flutter SDK.

## Design

### ARB files and key naming

- `lib/l10n/app_en.arb` — template/source of truth, English (default).
- `lib/l10n/app_cs.arb` — Czech translations.
- `l10n.yaml` at repo root configures `flutter gen-l10n` (arb-dir
  `lib/l10n`, output class `AppLocalizations`).
- Flat namespace, keys prefixed by feature + purpose, e.g.
  `dataScreenTotalCount`, `settingsAppearanceTitle`,
  `addIntimacyTagsLabel`. No nested JSON/maps.
- Parametrized strings use ICU placeholders (`{count}`) and plurals where
  natural (e.g. "day/days in a row" in the Hearts Streak card).

### Locale switching

- New `LocaleController` in `lib/core/l10n/locale_provider.dart`, mirroring
  the existing `ThemeModeController` pattern
  (`lib/core/theme/theme_mode_provider.dart`): a `@riverpod` class that
  persists the chosen locale to `shared_preferences` under key `locale`
  (`'cs'` / `'en'` / absent = follow system).
- Settings screen (`lib/features/lists/settings_screen.dart`) gets a new
  "Language" card placed next to the existing "Appearance" card, same
  visual pattern: a `SegmentedButton` with System / Čeština / English
  options.
- `lib/app.dart`: `MaterialApp.router` gets `locale`,
  `localizationsDelegates: AppLocalizations.localizationsDelegates`, and
  `supportedLocales: AppLocalizations.supportedLocales`.

### String migration

- Every hardcoded UI string across the ~120 Dart files is replaced with a
  call into `AppLocalizations.of(context)!` (via a `context.l10n`
  extension for brevity), covering dashboard, tracker/Data screen,
  blueprints, premium (UI chrome only, not marketing copy), settings, chat,
  gamification, and any other feature screens with user-facing text.
- Hardcoded weekday/month abbreviations (e.g. the `['Mon', 'Tue', ...]` and
  `['Jan', 'Feb', ...]` arrays in `data_screen.dart`) are replaced with
  `intl`'s `DateFormat` using the active locale instead of hand-rolled
  English arrays.
- Out of scope: Terms of Service, Privacy Policy, and longer
  marketing/paywall copy (`lib/features/premium/domain/premium_copy.dart`
  and similar) — these stay English-only for this project.
- Given the volume (~120 files), implementation execution is split by
  feature folder as separate work units, but this single design/spec
  covers the full scope — there is no separate "infra-only" phase.

## Out of scope

- Terms of Service / Privacy Policy pages.
- Marketing/paywall copy in `premium_copy.dart` and equivalent long-form
  marketing text.
- Any language beyond Czech and English.
- Automatic translation of user-generated content (chat messages, log
  notes, etc.) — only static UI chrome is localized.

## Testing

- Manual: switch language in Settings, walk through the main screens
  (Dashboard, Data, Tracker, Blueprints, Settings) in both languages,
  verify no leftover English strings when Czech is active and that longer
  Czech text doesn't break layouts.
- `flutter analyze` after `flutter gen-l10n` to catch missing/unused ARB
  keys at build time.

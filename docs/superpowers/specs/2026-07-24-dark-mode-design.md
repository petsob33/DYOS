# Design: Dark Mode

**Date:** 2026-07-24
**Status:** Approved

---

## Problem

`OurOSRoot` (`lib/app.dart`) hardcodes `themeMode: ThemeMode.light` and `theme: AppTheme.light`. There is no dark `ThemeData`, no way for a user to opt into dark mode, and no way to follow the OS setting.

### Why this isn't a one-line fix

`AppTheme.colors` (`lib/core/theme/app_theme.dart`) is a `static const AppPalette()` — a compile-time constant. 51 files reference it directly (889 call sites, mostly `AppTheme.colors.xxx` or `const c = AppTheme.colors;`), including inside `showDialog` builders and `StatelessWidget`s that only have a `BuildContext`, not a `WidgetRef`. A real dark mode needs every one of those call sites to resolve to a *different* palette depending on the active brightness — it cannot be solved by flipping `themeMode` alone.

---

## Scope

- **In scope:** Introduce a dark palette and a persisted theme-mode preference; migrate all 889 `AppTheme.colors` call sites across 51 files to resolve dynamically; add a Light/Dark/System selector to `SettingsScreen`.
- **Out of scope:** Per-screen custom dark treatments beyond swapping the palette (e.g., no bespoke dark-only illustrations); Localization and Time Capsule (separate specs).

---

## Design

### 1. Palette becomes a `ThemeExtension`

`AppPalette` in `lib/core/theme/app_theme.dart` changes from a plain class with a `static const colors` instance to:

```dart
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({required this.background, required this.card, ...});

  final Color background, card, primary, text, textSecondary, love, success, warning, shadow;

  static const light = AppPalette(background: Color(0xFFF2F2F7), card: Colors.white, ...); // current values, unchanged
  static const dark = AppPalette(background: Color(0xFF000000), card: Color(0xFF1C1C1E), ...); // new

  @override
  AppPalette copyWith({...}) => ...;

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) => ...; // trivial: return this (no animated transition needed) or Color.lerp per field
}
```

`AppTheme.light`/`AppTheme.dark` (existing `ThemeData` getter, new counterpart) each register their palette: `base.copyWith(extensions: [AppPalette.light])` / `[AppPalette.dark]`, plus dark-appropriate `scaffoldBackgroundColor`, `colorScheme(brightness: Brightness.dark)`, `appBarTheme`, `cardTheme` mirroring the existing light setup.

### 2. Access pattern: `context.colors`

New extension in `app_theme.dart`:

```dart
extension AppPaletteContext on BuildContext {
  AppPalette get colors => Theme.of(this).extension<AppPalette>()!;
}
```

Because `Theme.of(context)` resolves against whatever `ThemeData` `MaterialApp` currently has active (light or dark, already handling `ThemeMode.system`), this works in every `BuildContext` — dialogs, `StatelessWidget`s, callbacks — with no `WidgetRef` needed.

**Migration:** mechanical replace across all 51 files: `AppTheme.colors` → `context.colors`. Every call site already has a `context` in scope (they're inside `build(context, ...)`, dialog `builder: (context) => ...`, or similar). No call site needs to change *how* it reads a color, only *where it reads it from*.

### 3. Theme mode selection (persisted)

Reuses the existing `sharedPreferencesProvider` (`@riverpod Future<SharedPreferences>`, defined in `lib/features/auth/presentation/auth_providers.dart:103`, same pattern as `hasSeenTutorialProvider` right below it). Since that provider is async, `ThemeModeController` is an `AsyncNotifier` (`FutureOr<ThemeMode> build()`), not a plain synchronous one:

New `lib/core/theme/theme_mode_provider.dart`:

```dart
@riverpod
class ThemeModeController extends _$ThemeModeController {
  @override
  Future<ThemeMode> build() async {
    final prefs = await ref.watch(sharedPreferencesProvider.future);
    final saved = prefs.getString('themeMode');
    return switch (saved) { 'light' => ThemeMode.light, 'dark' => ThemeMode.dark, _ => ThemeMode.system };
  }

  Future<void> setMode(ThemeMode mode) async {
    state = AsyncData(mode);
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setString('themeMode', mode.name);
  }
}
```

`app.dart`: `themeMode: ref.watch(themeModeControllerProvider).valueOrNull ?? ThemeMode.system`, `theme: AppTheme.light`, `darkTheme: AppTheme.dark`. The `valueOrNull ?? system` fallback covers the brief loading window while `SharedPreferences.getInstance()` resolves on cold start.

### 4. Settings UI

`SettingsScreen` gets a new card (same `Material` + `InkWell` + `BentoCard`-adjacent style as existing Pairing/Delete Account rows) with a 3-way segmented control (Light/Dark/System) calling `ref.read(themeModeControllerProvider.notifier).setMode(...)`.

---

## Error handling

| Scenario | Behaviour |
|---|---|
| No saved preference (first launch) | Defaults to `ThemeMode.system` |
| `SharedPreferences` read/write fails | `themeModeControllerProvider` falls back to `ThemeMode.system` for that session; UI still functions, just doesn't persist |
| A screen still reads `AppTheme.colors` after migration (missed call site) | Compile error, since `AppTheme.colors` static getter is removed as part of this change — migration cannot be silently incomplete |

---

## Testing / verification

- `grep -rn "AppTheme.colors" lib/` must return nothing after migration (the static getter is deleted, so this is enforced by the compiler, not just convention).
- `flutter analyze` / `flutter test`: 0 errors, existing 120 tests still passing.
- Manual: toggle Light/Dark/System in Settings, confirm persisted across app restart, confirm no light-on-dark or dark-on-light visual artifacts on Home/Timeline/Tracker/Cycle/Blueprints/Premium/Settings screens.

---

## Files changed

| File | Change |
|---|---|
| `lib/core/theme/app_theme.dart` | `AppPalette` becomes `ThemeExtension`; add `AppPalette.dark`; add `AppTheme.dark` `ThemeData`; add `context.colors` extension; remove `static const colors` |
| `lib/core/theme/theme_mode_provider.dart` | New: persisted `ThemeModeController` |
| `lib/app.dart` | Wire `darkTheme` + `themeMode` from provider |
| `lib/features/lists/settings_screen.dart` | Add Light/Dark/System selector |
| 51 files, 889 call sites | Mechanical `AppTheme.colors` → `context.colors` |

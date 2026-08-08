# Cleanup & Optimization Log — DYOS

Branch: `chore/cleanup-optimization`
Base commit: `13a47d2` (main)
Started: 2026-08-08

## Fáze 0 — Baseline

### Poznámka k pracovnímu stromu
Při vytváření branch už existovaly necommitnuté změny na `main`, které nesouvisí s tímto cleanupem:
- modified: `lib/features/tracker/presentation/widgets/add_intimacy_sheet.dart`
- untracked: `docs/compliance/` (play-data-safety.md, health-apps-declaration.md, apple-app-privacy.md)

Tyto změny se přenesly na novou branch (git checkout -b nic nemaže). Nejsou součástí cleanupu — nechávám je netknuté, dokud neřekneš jinak.

### `flutter analyze`
- **389 issues**: 0 errors, **1 warning**, 388 info (lint suggestions, hlavně `avoid_redundant_argument_values`, `prefer_const_*`, `deprecated_member_use`, `avoid_dynamic_calls`).
- Jediný warning: `lib/core/router/app_router.dart:550` — nepoužitá lokální proměnná `isPremium` v `RootShell.build()`. Reálný mrtvý kód, kandidát na Fázi 1 (priority 1).

### `flutter test`
- **148/148 testů prošlo**, 0 failures. 23 test souborů.
- Pokrytí kritických cest:
  - **Auth**: `test/auth/user_data_source_test.dart` ✅
  - **Pairing (invite kód)**: 5 souborů (`pairing_service_test`, `pairing_service_enhanced_test`, `pairing_screen_test`, `pairing_screen_enhanced_test`, `pairing_integration_test`) — velmi dobré pokrytí edge cases (self-pairing, already-paired, not-found, invalid format, unauthenticated). ✅
  - **Firestore zápisy**: repository testy pro intimacy logs, memories, cycle, events, haptic signals — všechny přes `fake_cloud_firestore`. ✅
  - **Soul Points / gamifikace**: `test/gamification/subscription_service_xp_test.dart` pokrývá `SubscriptionService.grantQuestXpIfEligible` (XP granting + idempotence). ⚠️ **MEZERA**: žádný test pro `LevelManager` / `ProgressionPlan` (výpočet levelu a odemykání funkcí ze Soul Points) — `lib/features/gamification/domain/level_manager.dart`, `lib/features/gamification/domain/progression_plan.dart`.
  - **Premium gating**: `test/security/purchase_sync_security_test.dart` pokrývá `PurchaseService.syncPremiumEntitlementToFirestore` (kdy se sync provede/neprovede). ⚠️ **MEZERA**: žádný test pro `ProgressionPlan.isFeatureUnlocked` — rozhodovací logiku gatingu použitou přímo v `app_router.dart` (řádky 519, 537, 719) k odemykání Memories tabu podle Soul Points/premia.

  **→ Před jakýmkoliv refaktorem `level_manager.dart`, `progression_plan.dart` nebo gating logiky v `app_router.dart` napíšu nejdřív characterization testy pro `ProgressionPlan.isFeatureUnlocked` a `LevelManager`, jak žádá zadání.**

### `dart format --output=none --set-exit-if-changed .`
- **FAIL**: 120 z 191 souborů by se změnilo formátováním.
- Příčina: repo bylo pravděpodobně formátováno starším Dart SDK; Dart 3.7+ zavedl nový "tall style" formatter, který přeformátovává velké množství existujícího kódu (ne skutečný drift, ale rozdílná verze formatteru).
- **Rozhoduji NEspouštět plošné `dart format .` přes celý strom** — 120 změněných souborů by vytvořilo obří, těžko review-ovatelný diff a riskovalo by to konflikty s tvou rozdělanou prací na `add_intimacy_sheet.dart`. Formátování aplikuji jen bodově na soubory, které stejně upravuji v rámci konkrétních atomických změn (ať je diff srozumitelný per-commit).
- **TODO rozhodnutí pro tebe**: chceš samostatný commit `chore: dart format .` na celý strom na začátku, nebo mám formátovat jen dotčené soubory průběžně?

### Struktura / velikost
- `lib/`: 167 Dart souborů, 42 357 řádků.
- **28 souborů > 400 řádků** (mimo generované `.freezed.dart`), největší:
  - `cycle_tracking_screen.dart` — 1398
  - `add_intimacy_sheet.dart` — 1246
  - `data_screen.dart` — 1026
  - `add_memory_screen.dart` — 889
  - `app_router.dart` — 853
  - `timeline_screen.dart` — 834
  - (celý seznam viz git historie tohoto commitu / lze doplnit)
- `add_intimacy_sheet.dart` má navíc necommitnuté změny z tvé rozdělané práce — dokud nebude commitnuté/vyřešené, nebudu ho strukturálně dělit (Fáze 5).

### Závislosti (pubspec.yaml)
- 32 runtime dependencies, 9 dev dependencies + 1 vendored local override (`google_places_autocomplete`).
- `dependency_validator` není v projektu nainstalovaný a nebudu ho přidávat bez souhlasu (pravidlo "nepřidávat balíčky"). Místo toho ověřím nepoužité závislosti grepem (`package:X/` výskyty v `lib/`).
- Rychlý grep-check: všech 32 dependencies má ≥1 import v `lib/` — žádná zjevně mrtvá závislost na první pohled. Detailnější ověření (transitivní re-exporty, pouze v `android/`/`ios/` konfiguraci) proběhne v Prioritě 1.

### `print()` / logging
- 0 výskytů `print()` v `lib/` — projekt už používá `AppLogger` (`lib/core/services/app_logger.dart`). Bod 6 checklistu (odstranit print) je tedy už splněný, nic k opravě.

### Assets
- V `pubspec.yaml` není deklarovaný žádný `assets:` blok (je zakomentovaný) — není co kontrolovat na nepoužité assety.

### Build size (`flutter build apk --analyze-size`, arm64, release/debug-signed)
- **app-release.apk: 38.1 MB** (36 MB komprimovaně).
- Breakdown: `lib/arm64-v8a` (nativní knihovny) 20 MB, `classes.dex`+`classes2.dex` 13 MB, `resources.arsc` 2 MB, `flutter_assets` 946 KB.
- Dart AOT (dekomprimováno) 9 MB: `package:flutter` 4 MB, `package:ouros_app` (vlastní kód) 924 KB, `package:flutter_localizations` 334 KB, zbytek jsou balíčky (fl_chart 203 KB, google_maps_flutter_android 124 KB, atd.) — nic nápadně předimenzovaného.
- Font tree-shaking funguje (Phosphor/MaterialIcons zredukovány o 96–99.8 %).
- Vedlejší zjištění (ne pro Fázi 1, jen na vědomí): varování "Expected to find fonts for ... CupertinoIcons ... but found ..." — chybí `cupertino_icons` v assets, což je ale jen warning při buildu, appka běží. Zapisuji jako TODO, nesouvisí s cleanup prioritami.
- Build nemá nastavený release keystore (`android/key.properties` chybí) — build proběhl přes fallback signing config v `build.gradle`.

### Rozhodnutí (potvrzeno uživatelem)
- **dart format**: neformátovat plošně. Formátuji jen soubory, které stejně upravuji v rámci konkrétní atomické změny.
- **Rozpracovaná práce na main** (`add_intimacy_sheet.dart`, `docs/compliance/`): zůstává na cleanup branch beze změny, drženo odděleně od cleanup commitů (staging po jednotlivých souborech, ne `git add -A`).

## Fáze 1+ log (atomické změny)

| # | Změna | Soubor | analyze | test | Výsledek |
|---|---|---|---|---|---|
| 1 | Odstranění nepoužité lokální `isPremium` v `RootShell.build()` (mrtvý kód + zbytečný rebuild trigger na `isPremiumProvider`) | `lib/core/router/app_router.dart:550` | 389→388 issues (warning zmizel) | 148/148 ✅ | commit `547990f` |

### Priorita 1 (mrtvý kód) — uzavřeno
Po change #1 byly provedeny další kontroly, žádný další nález:
- **Nepoužité soubory**: cross-check importů přes celý `lib/` (167 souborů) — každý soubor má ≥1 odkaz odjinud. Žádný orphan.
- **Nepoužité importy/elementy**: `flutter analyze` po opravě #1 nehlásí žádný `unused_import`/`unused_element`/`unused_field`/`unused_local_variable`.
- **Nepoužité assety**: žádný `assets:` blok v pubspec.yaml.
- **Nepoužité závislosti**: ověřeno grepem i u balíčků s jen 1 výskytem (`firebase_crashlytics`, `fl_chart`, `flutter_local_notifications`, `flutter_staggered_grid_view`, `geocoding`, `google_sign_in`, `http`, `permission_handler`, `shared_preferences`, `url_launcher`) — všechny mají reálné, aktivní použití (Crashlytics init, chart na Data screen, lokální notifikace, staggered grid na home, reverse geocoding, Google sign-in, notification permissions, lokální persistence, externí odkazy na premium landing). Žádná se nemaže.

**Závěr**: mechanicky ověřitelný mrtvý kód je vyčerpaný. Přecházím na Prioritu 2 (Firestore náklady).

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
| 2 | `HapticSignalRepository.watchSignals` bounded na posledních 90 dní (`where(timestamp > cutoff)`) místo neomezené historie. Přidán test na hranici okna. | `lib/features/dashboard/data/haptic_signal_repository.dart`, `test/dashboard/haptic_signal_repository_test.dart` | 388 issues (beze změny) | 149/149 ✅ | commit `134d8e6` |
| 3 | `NotesRepository.getLatestSharedNote` přepnuto z "načti vše + seřaď v paměti" na `orderBy+limit(1)`; přidán composite index do `firestore.indexes.json`; `NotesRepository` dostal injectable `firestore` konstruktor (konzistence s ostatními repozitáři) + nový test soubor (dosud netestováno). | `lib/features/notes/data/notes_repository.dart`, `firestore.indexes.json`, `test/notes/notes_repository_test.dart` | 388 issues (beze změny) | 153/153 ✅ | commit `89300dc` — **⚠️ vyžaduje `firebase deploy --only firestore:indexes` před/spolu s vydáním, jinak dotaz v produkci spadne** |

### Priorita 1 (mrtvý kód) — uzavřeno
Po change #1 byly provedeny další kontroly, žádný další nález:
- **Nepoužité soubory**: cross-check importů přes celý `lib/` (167 souborů) — každý soubor má ≥1 odkaz odjinud. Žádný orphan.
- **Nepoužité importy/elementy**: `flutter analyze` po opravě #1 nehlásí žádný `unused_import`/`unused_element`/`unused_field`/`unused_local_variable`.
- **Nepoužité assety**: žádný `assets:` blok v pubspec.yaml.
- **Nepoužité závislosti**: ověřeno grepem i u balíčků s jen 1 výskytem (`firebase_crashlytics`, `fl_chart`, `flutter_local_notifications`, `flutter_staggered_grid_view`, `geocoding`, `google_sign_in`, `http`, `permission_handler`, `shared_preferences`, `url_launcher`) — všechny mají reálné, aktivní použití (Crashlytics init, chart na Data screen, lokální notifikace, staggered grid na home, reverse geocoding, Google sign-in, notification permissions, lokální persistence, externí odkazy na premium landing). Žádná se nemaže.

**Závěr**: mechanicky ověřitelný mrtvý kód je vyčerpaný. Přecházím na Prioritu 2 (Firestore náklady).

## Priorita 2 — Firestore náklady (audit)

Prošel jsem všech 30 souborů dotýkajících se Firestore (`repositories`, `services`, `providers`). Většina streamů je už dobře navržená a **záměrně** dokumentovaná (viz `intimacy_repository.dart`, `memory_repository.dart` — mají zvlášť neomezený `watchLogs`/`watchLogs`-ekvivalent pro statistiky *a* zvlášť `getRecentLogsFeed`/`getOlderLogs` s `limit()` a stránkováním pro feed UI, s komentářem vysvětlujícím proč). Totéž `cycle_repository.dart` (predikce cyklu potřebuje plnou historii — legitimní). Listenery se všude správně `cancel()`-ují na `dispose()`; `NotificationService`'s `_authSubscription` je `keepAlive: true` singleton, běží po celou dobu appky záměrně — není to leak. Žádný N+1 pattern ve smyčce (jediný nález s `for` + Firestore voláním je dávkové mazání účtu v `profile_service.dart:111-127`, což je správně stránkované po 500 a jednorázové, ne hot-path).

**Skutečné nálezy (2):**

### Nález 1: `HapticSignalRepository.watchSignals` čte celou historii jen pro výpočet streaku
- `lib/features/dashboard/data/haptic_signal_repository.dart:24` — `watchSignals()` streamuje **všechny** haptic signály párů bez `limit()`/`orderBy` odjakživa.
- Jediný odběratel: `hapticSignalsHistoryProvider` → `heartsStreak()` (`lib/features/dashboard/domain/haptic_signal_stats.dart`), který počítá po sobě jdoucí dny se signálem od obou partnerů — algoritmus přirozeně potřebuje jen posledních N dnů, ne celou historii.
- Srovnání: stejná kolekce (`haptic_signals`) je jinde (`chat_history_repository.dart:52-54`) čtena s `orderBy('timestamp', descending: true).limit(200)` — takže bounded přístup už je v projektu zavedený vzor, jen tady chybí.
- **Odhad nákladu**: pár aktivní 1 rok s ~2 signály/den = ~730 dokumentů. Každé otevření Data & Analytics obrazovky = initial listen čte celou historii (730+ reads), a live listener zůstává aktivní, dokud je obrazovka připojená — každá další akce (kdekoliv v appce, co zapisuje nový signál) přidá 1 read navíc do tohoto listeneru. Bounded na posledních ~90 dní (dost i pro nerealisticky dlouhý perfektní streak) = ~180 reads na otevření místo 730+ a dál to neroste s věkem vztahu. Pro starší páry (3+ roky) škáluje ještě hůř — dnes O(celková historie), mělo by být O(bounded okno).
- **Proč to nefixnu automaticky**: `heartsStreak` nemá žádný horní strop na délku streaku — ořezáním na posledních N dní bych teoreticky (i když extrémně nepravděpodobně — pár by musel poslat srdíčko KAŽDÝ den bez výjimky) změnil výsledek pro streak delší než N dní. To je změna chování, byť pro edge case, a tvoje zadání explicitně zakazuje měnit chování bez domluvy.

### Nález 2: `NotesRepository.getLatestSharedNote` čte celou kolekci pro 1 výsledek
- `lib/features/notes/data/notes_repository.dart:135-168` — načte *všechny* sdílené poznámky (`where('type', isEqualTo: shared)`), pak v paměti seřadí a vezme jen nejnovější. Používá se pro `QuickNoteCard` — pravděpodobně na home dashboardu (nejvyšší traffic obrazovka).
- Komentář v kódu (řádek 140) říká, že se `orderBy` schválně vynechalo, "aby se předešlo composite indexu" — tj. autor si problém uvědomoval a zvolil tento kompromis vědomě.
- **Odhad nákladu**: pár s 50 nasdílenými poznámkami = 50 reads při každém otevření/změně místo 1. Na home screenu, který se otevírá nejčastěji ze všech, to při typickém používání (několik otevření denně) znamená řádově stovky zbytečných reads/den u aktivnějších párů, a roste to lineárně s počtem poznámek navždy.
- **Proč to nefixnu automaticky**: správná oprava (`.where('type', isEqualTo: ...).orderBy('createdAt', descending: true).limit(1)`) potřebuje složený (composite) index ve Firestore, který není součástí tohoto repa (zřejmě `firestore.indexes.json`, mimo dohled tohoto cleanupu) a musel by se nasadit do Firebase projektu *před* vydáním kódu, jinak dotaz v produkci spadne na `failed-precondition`. To je nasazení infrastruktury, ne jen úprava kódu — mimo bezpečný rámec tohoto cleanupu bez tvého souhlasu/koordinace.

**TODO rozhodnutí pro tebe** (obě čekají na tvůj pokyn, nic jsem zatím neměnil):
1. Haptic streak — mám omezit `watchSignals` na posledních X dní (a jaké X je pro tebe přijatelné jako "streak cap")? Nebo najít jiný přístup (např. bounded live window + separátní `getOlderSignals` pro edge-case dlouhé streaky, stejný vzor jako u intimacy/memory)?
2. Latest shared note — mám připravit `.orderBy + limit(1)` verzi a ty/já nasadíte composite index do Firebase konzole/`firestore.indexes.json`? Nebo preferuješ levnější bezindexovou opravu (např. cache poslední známé poznámky v `couples/{id}` dokumentu při zápisu, aktualizovanou při každém vytvoření sdílené poznámky)?

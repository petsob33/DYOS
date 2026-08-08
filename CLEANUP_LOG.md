# Cleanup & Optimization Log — DYOS

Branch: `chore/cleanup-optimization`
Base commit: `13a47d2` (main)
Started: 2026-08-08

## ⚡ Jak pokračovat (přečti toto jako první v nové konverzaci)

Tento soubor je jediný zdroj pravdy pro tento cleanup projekt — pravidla níže **nejsou** v `CLAUDE.md`, žila jen v původní konverzaci. Nová session musí nejdřív přečíst celý tento soubor, pak pokračovat.

**Stav k poslední aktualizaci**: Fáze 0 (baseline) hotová, Priorita 1 (mrtvý kód) uzavřena, Priorita 2 (Firestore náklady) uzavřena, Priorita 3 (rebuild performance) rozpracovaná — 6 atomických změn commitnutých celkem (3 z nich v Prioritě 3: #4, #5, #6), viz tabulka níže. **Další krok: pokračovat v Prioritě 3** — audit nálezů a pořadí viz sekce "Priorita 3 — Rebuild performance" níže. Zbývají nálezy #1 (`cycle_tracking_screen.dart`, velký/rizikový), #3 (`memories_map_screen.dart`), #4 (`intimacy_history_list.dart`), #5 (`data_screen.dart`), #6 (`timeline_screen.dart` regroup), #8 (`timeline_screen.dart` MemoryCard setState). Nález #2 (`home_screen.dart`) je odložený/rizikový, viz poznámka u něj — nedělat bez výslovné domluvy.

**⚠️ Akce, které čekají na tebe (mimo Claude):**
1. **Nasadit Firestore composite index** před/spolu s vydáním této branch: `firebase deploy --only firestore:indexes`. Nový index (`notes` kolekce, `type` + `createdAt`) je potřeba pro commit `89300dc` (`NotesRepository.getLatestSharedNote`) — bez něj dotaz v produkci spadne na `failed-precondition`.
2. Branch `chore/cleanup-optimization` ještě nebyl mergnutý do `main` ani pushnutý — až budeš chtít, řekni.

### Protokol (pravidla, podle kterých se pracuje — platí do odvolání)

Zadání: senior Flutter engineer dělá cleanup + optimalizaci DYOS (Flutter + Firebase/Firestore couples app). **Nepřidávat featury, neměnit chování.**

**Smyčka (bezvýjimečně)**: jedna atomická změna → popsat v 1 větě → provést → `flutter analyze` + `flutter test` → zelená = `git commit` (`refactor:`/`perf:`/`chore:`), červená = max 2 pokusy opravit, pak revert + zapsat "skipped + důvod" do tohoto logu → vždy zapsat řádek do tabulky níže. Nikdy víc změn najednou, nikdy commit bez zelených testů.

**Priority v tomto pořadí:**
1. Mrtvý kód (nepoužité soubory/třídy/metody/importy/assety/závislosti) — **✅ uzavřeno**
2. Firestore náklady (chybějící `limit()`, N+1, nedisposed streamy, duplicitní subscriptions, chybějící cache; u nálezu vždy odhadnout ušetřené reads/uživatel/den) — **✅ uzavřeno**
3. Rebuild performance (chybějící `const`, `setState` moc vysoko, `Selector`/`select`, těžké výpočty v `build()`, `ListView.builder`) — **← next**
4. Duplicita (sdílet jen když ≥3 výskyty)
5. Struktura (soubory >400 řádků, mechanický extract, ne přepis logiky)
6. Konzistence (error handling, logging, naming; `print()` → logger — **už splněno, viz níže**)

**Co nedělat**: neměnit architekturu/state management/DI, neupgradovat major verze závislostí, neměnit Firestore rules ani schéma, nepřepisovat UI, nepřidávat balíčky bez souhlasu, žádné drive-by opravy nesouvisejících věcí (zapsat jako TODO místo toho).

**Výstup**: po ~5 commitech krátký status (hotovo/další/riziko). Na konci: shrnutí před/po (issues, testy, počet souborů, odhad ušetřených Firestore readů) + seznam věcí, které měl uživatel rozhodnout.

**Rozpracovaná práce uživatele** (nesouvisí s cleanupem, nesahat): `lib/features/tracker/presentation/widgets/add_intimacy_sheet.dart` (necommitnuté změny) a `docs/compliance/` (untracked) — byly na `main` už před začátkem cleanupu, přenesly se na tuto branch, zůstávají netknuté a odděleně stage-ované od cleanup commitů.

---

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
| 4 | `IntimacySparkCard.build()` — nahrazen `List.from(logs)..sort()` (kopie + O(n log n) třídění celé historie) za `logs.reduce()` (O(n), bez kopie) pro nalezení jen nejnovějšího logu. Vedlejší úklid: odstraněn nyní nepoužitý import `intimacy_log_model.dart`. | `lib/features/dashboard/presentation/widgets/intimacy_spark_card.dart` | 388 issues (beze změny) | 153/153 ✅ | commit `f6a6158` |
| 5 | `_MemoryCardSkeleton` (bez polí) dostal `const` konstruktor; volání v `_LoadingState.build()`'s `ListView.builder` přepnuto na `const _MemoryCardSkeleton()` uvnitř `const Padding(...)` — 5 skeleton položek se teď kanonizují na stejnou instanci, Flutter přeskočí jejich rebuild. | `lib/features/timeline/presentation/screens/timeline_screen.dart` | 388 issues (beze změny) | 153/153 ✅ | commit `7d67417` |
| 6 | `TapticTouchCard` watchoval celý `currentCoupleProvider`/`currentUserDataProvider` jen kvůli `.id`/`.uid` — přepnuto na `.select()` na tato pole. Loading/error/no-couple větve `.when()` renderovaly identický fallback widget, takže sloučení do jednoho null-checku je mechanický důsledek přechodu z `AsyncValue<Couple?>.when()` na prostý nullable id (ne samostatná refaktorová změna). | `lib/features/dashboard/presentation/widgets/taptic_touch_card.dart` | 388→387 issues (o 1 méně) | 153/153 ✅ | commit `07e0b48` |

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

**Rozhodnuto uživatelem (implementováno, viz change #2 a #3 v tabulce výše):**
1. Haptic streak → **bound na posledních 90 dní** (`where(timestamp > cutoff)`). Hotovo v commitu `134d8e6`.
2. Latest shared note → **`orderBy + limit(1)` + composite index** v `firestore.indexes.json`. Hotovo v commitu `89300dc`. **Čeká na `firebase deploy --only firestore:indexes` od tebe** (viz akce na začátku souboru).

## Priorita 3 — Rebuild performance (audit)

Projekt používá **Riverpod** (ne Provider) — ekvivalent `Selector`/`select` je `ref.watch(provider.select(...))` / `provider.select(...)`. Grep potvrdil **0 výskytů** `.select(` v `lib/` před touto prioritou — každý nález níže je reálná, dosud neošetřená mezera.

Nálezy seřazené podle odhadovaného dopadu (frekvence rebuildu × šíře/cena zbytečné práce). Zaškrtnuté = hotovo.

1. `lib/features/cycle/presentation/cycle_tracking_screen.dart:63-613` — `build()` má ~550 řádků; přebuduje 3× `Map<DateTime,List<...>>` z `events`/`intimacyLogs`/`memories` na každý build, kalendářní `eventLoader` dělá lineární `firstWhere`/`.any()` scany na buňku (~35-42 buněk/měsíc). `setState` na řádcích 158 a 525 (tap na den) re-triggeruje celé přepočítání + rebuild celé obrazovky. **Největší nález, ale i nejrizikovější refaktor** (velký soubor, komplexní kalendářní logika) — promyslet rozsah než se do toho jde.
2. `lib/features/dashboard/presentation/screens/home_screen.dart:386-387` — `ref.watch(hapticSignalsStreamProvider)`/`ref.watch(quickMessagesStreamProvider)` vypadají redundantní vedle `ref.listenManual` v `_setupListeners()`. **⚠️ Po bližším zkoumání odloženo, NEdělat jako "snadný" next step**: oba providery jsou `AutoDisposeStreamProvider` (viz `.g.dart`) a `_setupListeners()` se volá až v `postFrameCallback` z `initState()` — odstranění `ref.watch` mění, kdy/jestli se stream provider vůbec vytvoří (timing kolem prvního frame + autoDispose lifecycle), a týká se jádra couples-app UX (haptic buzz / quick message notifikace), bez pokrytí testy. Reálný přínos je navíc malý — tyhle streamy emitují vzácně (partner pošle buzz/zprávu občas), takže to není hot rebuild path. Risk/reward špatný pro jednu atomickou změnu — přeskočeno, nálezy č. 3+ mají lepší poměr.
3. `lib/features/timeline/presentation/screens/memories_map_screen.dart:284-304,345` — `_buildMarkers()` rekonstruuje celou `Set<Marker>` (nové closures) na každý build `_MemoriesMapContentState`, který má ~15 nesouvisejících `setState` (psaní do search boxu, autocomplete). Psaní do vyhledávání překresluje všechny mapové markery.
4. `lib/features/tracker/presentation/widgets/intimacy_history_list.dart:50-75` — watchuje `userProvider`/`currentUserDataProvider`/`partnerProvider` celé jen kvůli `.uid`/`.photoUrl`, plus group-by-month + sort inline v `build()`.
5. `lib/features/tracker/presentation/data_screen.dart:26,86,829-847` — `ref.watch(userProvider)` celý jen kvůli `.uid`; `_TagsRadarChart.build()` počítá výskyty tagů přes všechny logy + `.sort()` na každý build.
6. `lib/features/timeline/presentation/screens/timeline_screen.dart:26,39-40,152-156` — watchuje `currentXpProvider`/`isPremiumProvider` (jen pro FAB/limit-bar gate) vedle feedu memories; `_TimelineList.build()` přeskupuje memories podle měsíce na každý rebuild.
7. ✅ `lib/features/dashboard/presentation/widgets/intimacy_spark_card.dart:47-48` — `List.from(logs)..sort()` na celou historii jen pro `sortedLogs.first`. **Hotovo, viz change #4 v tabulce výše (commit `f6a6158`)**: nahrazeno `logs.reduce()`.
8. `lib/features/timeline/presentation/screens/timeline_screen.dart:418-552` — `MemoryCard`'s `onPageChanged` `setState` (řádek 549) rebuilduje celou ~150řádkovou kartu jen kvůli page-dot indikátoru.
9. ✅ `lib/features/timeline/presentation/screens/timeline_screen.dart:281-292` — `_LoadingState` vytvářel `_MemoryCardSkeleton()` (non-const) uvnitř `ListView.builder(itemCount: 5)`. **Hotovo, viz change #5 v tabulce výše (commit `7d67417`)**: přidán const konstruktor.
10. ✅ `lib/features/dashboard/presentation/widgets/taptic_touch_card.dart:31-40` — watchoval `currentCoupleProvider`/`currentUserDataProvider` celé jen kvůli `.id`/`.uid` (`currentXpProvider`/`isPremiumProvider` už byly úzké, nechány beze změny). **Hotovo, viz change #6 v tabulce výše (commit `07e0b48`)**: přepnuto na `.select()`.

**Pozitivní zjištění**: `home_screen.dart:552-562` — `_cards` je top-level `final` seznam `const` widgetů, sdílený stejnou referencí napříč `MasonryGridView.itemBuilder` → Flutterův `identical()` fast-path už tyto rebuildy přeskakuje. Dobrý vzor, hodný rozšíření jinam.

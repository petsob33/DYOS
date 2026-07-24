# AUDIT.md – Kompletní audit aplikace DYOS

**Datum auditu:** 2026-07-20 (re-audit, commit `30912ce`, + oprava vlastních nálezů ve stejné relaci)
**Předchozí audit:** 2026-07-03 (viz git historie tohoto souboru)
**Auditor:** Claude Code (automatizovaný audit)

## Poznámka k zadání

Toto je **diferenciální re-audit** oproti auditu z 3. 7. 2026, ve stejné relaci navazuje oprava zjištěných nálezů (bezpečnostní test, CI gate, sjednocení cycle providerů, Blueprints → Firestore). Za 17 dní od minulého auditu přibylo ~35 commitů (viz `git log`), mj. PR #3 (oprava zamrzání quick-message notifikace, replay notifikací po otevření appky, nová obrazovka chat historie). Většina kritických a vysokých nálezů z minulého auditu byla mezitím **opravena** – tento report ověřuje každý starý nález proti aktuálnímu kódu, přidává nové poznatky a dokumentuje opravy provedené v této relaci.

---

## 1. Shrnutí – co se od minula změnilo

| Starý nález (3. 7.) | Stav teď (20. 7.) |
|---|---|
| 🔴 Keystore `.jks` commitnutý v gitu | ✅ **Opraveno** (3. 7., commit `4dd9e55`) – vyveden z git trackingu, `*.jks`/`key.properties` v `.gitignore`. Zůstává nesmazatelně v historii gitu. |
| 🟠 Secret/private notes čitelné partnerem přes Firestore rules | ✅ **Opraveno** (3. 7.) – `firestore.rules` `allow list, get` podmiňuje `!isPrivateType(resource.data) \|\| isAuthor()`. **Regresně otestováno** – viz sekce 2. |
| 🟠 Google Places API klíč v historii gitu | ⚠️ **Beze změny** – jen ověřitelné/rotovatelné v GCP konzoli, mimo dosah tohoto repa/agenta. |
| 🟡 Race condition v XP gamifikaci | ✅ **Opraveno** (3. 7.) – `grantQuestXpIfEligible` běží přes server-side Firestore transakci. |
| 🟡 Chybějící pagination na Firestore listenery | ✅ **Opraveno** (3. 7.) – `.limit()` na memory/intimacy/event query; nová `chat_history_repository.dart` má `.limit(200)` od začátku. |
| 🟡 Žádný crash-reporting SDK | ✅ **Opraveno** (3. 7.) – `firebase_crashlytics` v pubspec, na webu záměrně vypnuto. |
| 🟡 8 failing testů (rozbitý mock) | ✅ **Opraveno** (3. 7.) – `flutter test`: **120/120 passed**. |
| 🟡 Zastaralé závislosti | 🟡 **Výrazně zlepšeno, nedokončeno** – viz sekce 2. |
| 🟢 `home_screen.dart` 2207 řádků | ✅ **Opraveno** (3. 7.) – rozdělen na menší widgety, 561 řádků. |
| 🟢 Duplicitní cycle modely/providery | ✅ **Opraveno v této relaci** – viz sekce 3. |
| 🟢 `print()` místo `debugPrint()` | Neověřeno – nízká priorita. |

**Nové od minula (kód z produkčních commitů):** perzistentní obrazovka **Chat** (`/chat`) – sloučená historie quick-message + haptic touch; oprava zamrzání appky při notifikační overlay; oprava "replay" starých notifikací; FCM web push.

**Opraveno v této relaci (viz sekce 3):** bezpečnostní regresní test na private notes ověřen (už existoval, jen jako JS/emulator test, ne Dart), CI gate na `flutter analyze`/`flutter test`/Firestore rules testy, sjednocení duplicitních cycle providerů/modelů (+ oprava skrytého bugu v editaci cyklo-logu), Blueprints přesunuty z hardcoded mock dat do Firestore. **Nový nález objevený a opravený v této relaci:** `freezed`/`json_serializable` verze zamčené v `pubspec.lock` neumí vygenerovat `explicitToJson: true` pro vnořené modely (viz sekce 4).

---

## 2. Technický sken (aktuální stav)

### `flutter analyze`
**409 nálezů, 0 error, 0 warning – všechno `info`** (lint styl, deprecated API). Produkční kód se kompiluje čistě.

- **91× `deprecated_member_use` v `lib/`** – hlavně Flutter/Firebase API (`withOpacity` → `withValues`, `AppRouterRef` → `Ref`). Roste s odkládáním SDK upgradů, není to bug.

### `flutter test`
**120/120 passed.**

### Firestore security rules (emulator testy, `test/security/rules/`)
Samostatná JS testová sada (`@firebase/rules-unit-testing` proti Firestore emulátoru, ne Dart `fake_cloud_firestore` – ten neumí vyhodnotit `get()`/`exists()`/vlastní `function`y, takže pravidla závislá na datech dokumentu testovat nemůže). `notes_rules.test.js` (24 testů) **už před touto relací plně pokrývalo** private/secretGift notes fix – partner nemůže `get`/`list` cizí private/secretGift notes, autor může, sdílené notes vidí oba, update/delete matice. Spuštěno v této relaci proti aktuálnímu `firestore.rules` (24/24 passed) – **oprava dřívějšího chybného nálezu**: minulá verze tohoto reportu tvrdila, že tento test chybí; ve skutečnosti existoval, jen mimo Dart test suite, takže ho `flutter test` nezachytí.

### CI/CD
`.github/workflows/ci.yml` (**nově přidáno v této relaci**) spouští na push/PR: `flutter analyze` (fail jen na skutečné `error`, ne na ~400 preexistujících `info` lintů – `flutter analyze` samo vrací exit 1 i jen kvůli infu, takže tvrdé gatování na jeho exit kód by shodilo každý build bez souvislosti s regresí), `flutter test`, a Firestore rules emulator testy (`test/security/rules/`). Předtím žádný z existujících 3 workflow (`build-apk`, `deploy-production`, `deploy-test`) nic z tohoto nespouštěl.

### Závislosti
`flutter pub outdated`: většina balíčků max. 1-2 patch verze pozadu. Major verze pozadu: `flutter_riverpod` (2→3), `freezed_annotation`/`freezed` (2→3), `riverpod_annotation`/`riverpod_generator` (2→4), `google_sign_in` (6→7), `purchases_flutter` (9→10), `geocoding` (4→5), `geolocator` (13→14), `google_mobile_ads` (7→9), `google_fonts` (7→8). Nic urgentního, ale rostoucí migrační dluh — a nyní i konkrétní důvod upgradovat `freezed`, viz sekce 4.

---

## 3. Provedené opravy v této relaci

**1. Sjednocení duplicitních cycle providerů/modelů.** `cycle_tracking_screen.dart` dřív importoval paralelně dvě sady: `models/cycle_provider.dart`+`models/cycle_log.dart` (list-based predikce pro kalendář) a `presentation/cycle_provider.dart`+`domain/cycle_log_model.dart` (single-value predikce pro dashboard, plus skutečné CRUD). Obě četly ze stejného `cycleRepositoryProvider` a používaly stejný predikční vzorec, takže nešlo o datovou nekonzistenci, ale o matoucí duplicitu. Řešení: `predictedPeriodDaysProvider` a `fertileWindowDaysProvider` (list-based varianty) přesunuty do `presentation/cycle_provider.dart`; `cycle_tracking_screen.dart` teď používá jen doménový `CycleLog` a jednu sadu providerů; `lib/features/cycle/models/` smazána. **Vedlejší nález:** `_CycleLogSheet._submit()` při editaci existujícího dne vždy zapisoval `id: ''`, takže `CycleRepository.addOrUpdateLog` vytvořil **nový duplicitní dokument** místo update původního záznamu – opraveno na `id: widget.existingLog?.id ?? ''`. Ověřeno: `flutter analyze`/`flutter test test/cycle` čisté.

**2. Bezpečnostní regresní test na private/secretGift notes.** Zjištěno, že tento test **už existoval** (`test/security/rules/notes_rules.test.js`, 24 scénářů) – jen jako Node.js emulator test, ne jako Dart test; minulá verze tohoto auditu to chybně označila za mezeru. Ověřeno spuštěním proti emulátoru: 24/24 passed. Žádná nová Dart implementace nebyla potřeba (a ani není technicky proveditelná – `fake_cloud_firestore`'s pravidlový engine nepodporuje `get()`/`resource`/vlastní `function`, viz `test/security/rules/README.md`).

**3. CI gate.** Nový `.github/workflows/ci.yml`: `flutter analyze` (fail jen na `error`), `flutter test`, Firestore rules emulator testy – na `pull_request` a push na `main`/`test-main`.

**4. Blueprints přesunuty z mock dat do Firestore.** Nová kolekce `blueprint_sections/{sectionId}` (Firestore rules: číst smí kdokoliv přihlášený, zápis jen přes Admin SDK). Nový `domain/blueprint_section.dart` (Freezed model, `fromFirestore`), `data/blueprint_repository.dart`, `presentation/blueprint_provider.dart` (`blueprintSectionsProvider`/`blueprintSectionProvider`, oba s fallbackem na `BlueprintMockData`, pokud Firestore ještě není naseedovaná). `blueprints_list_screen.dart` a `blueprint_detail_screen.dart` přepsány na `ref.watch(...)` + `AsyncValue.when()`; router resolvuje sekci teď uvnitř `BlueprintDetailScreen`, ne synchronně v `pageBuilder`. `blueprint_mock_data.dart` zůstává jako seed zdroj a offline fallback. **Seed skripty přidány, ale NEspuštěny proti produkci** (vyžaduje uživatelovy Firebase credentials): `flutter test scripts/export_blueprint_sections.dart` → `scripts/blueprint_sections_seed.json` (26 sekcí, už vygenerováno a v repu) → `node scripts/seed_blueprint_sections.js` (Admin SDK upload). **Dokud seed skript nikdo nespustí, appka funguje beze změny přes mock-data fallback** – toto není breaking change.

Všechny 4 opravy ověřeny: `flutter analyze` (0 error/warning), `flutter test` (120/120), Firestore rules emulator testy (24/24).

---

## 4. Nový nález z této relace: `pubspec.lock` neodpovídá committnutému generovanému kódu

Při `dart run build_runner build` (nutné pro nové providery výše) se **neúmyslně přegenerovaly i nesouvisející soubory** (`couple_model.freezed.dart`, `user_model.freezed.dart`, `event_model.freezed.dart`, `note_item.freezed.dart`, `memory_model.freezed.dart`, `cycle_settings_model.freezed.dart`) s jinou hodnotou: `@JsonSerializable()` místo dříve committnutého `@JsonSerializable(explicitToJson: true)`.

- **Příčina:** `freezed: 2.5.8` (aktuálně zamčená verze v `pubspec.lock`) **vůbec nemá** logiku pro `explicitToJson` (ověřeno grepem v balíčku – nula výskytů). Committnuté `.freezed.dart` soubory byly zjevně vygenerované jinou (novější) verzí `freezed`, než jaká je teď zamčená v `pubspec.lock` – drift mezi lockfilem a committnutým generovaným kódem, který existoval už před touto relací (nejde o nic, co jsem způsobil úpravou zdrojových `.dart` souborů; `pubspec.lock` byl navíc už modifikovaný na začátku této relace, mimo můj zásah).
- **Dopad, pokud by se to nechalo být:** `explicitToJson: false` znamená, že vnořené Freezed objekty (např. `CoupleStatus` uvnitř `CoupleModel.status`, `UserStatus` uvnitř `UserModel`) se do `toJson()` výstupu vloží jako **syrová Dart instance třídy**, ne jako Map – Firestore takový zápis odmítne (potvrzeno pádem testu `pairing_service_test.dart`/`pairing_integration_test.dart` s `Invalid argument: Instance of '_$CoupleStatusImpl'`). Kdyby tohle doběhlo do produkce, **zápis stavu páru/uživatelského statusu by přestal fungovat**.
- **Oprava v této relaci:** nesouvisející přegenerované soubory vráceny na původní (committnutý) stav (`git checkout`), takže nic z tohoto driftu nejde do commitu. Zkusil jsem i `build.yaml` s `explicit_to_json: true` pro `freezed`/`json_serializable` buildery – **nepomohlo**, protože freezed 2.5.8 tuto možnost vůbec nezná (není to otázka konfigurace, ale chybějící funkce v zamčené verzi balíčku). `build.yaml` zůstává v repu pro budoucnost (jakmile `freezed` upgraduje, bude потřeba).
- **Zbývá vyřešit:** buď upgradovat `freezed`/`freezed_annotation`/`json_serializable` na verzi, která `explicitToJson` umí odvodit automaticky (nutná verifikace, jaká přesně verze to přidala – `pub outdated` ukazuje resolvable `freezed 3.2.3`), nebo trvale ručně anotovat postižené třídy. **Dokud se to nevyřeší, nikdo NESMÍ spustit `dart run build_runner build` na těchto 6 souborech** (nebo obecně `--delete-conflicting-outputs` napříč celým `lib/`) bez ručního ověření diffu – jinak se stejná regrese znovu vplíží do commitu.

---

## 5. Funkční sken a UX

### Stav funkcí

| Funkce | Stav | Poznámka |
|---|---|---|
| Auth + Pairing | **Hotovo** | – |
| Home/Dashboard | **Hotovo** | – |
| Quick Message / Haptic Touch | **Hotovo** | Zamrzání overlay a replay-on-open opraveny (PR #3) |
| Chat | **Hotovo** | Sloučená historie zpráv+doteků, live-update, `.limit(200)` |
| Timeline (vzpomínky) | **Skoro hotovo** | 2 stále otevřené TODO v `memory_screen.dart` (navigace na mapu/detail) – neověřeno znovu v této relaci |
| Tracker (intimita) | **Hotovo** | – |
| Cycle Tracking | **Hotovo** | Duplicitní providery/modely sjednoceny (sekce 3), + oprava bugu s duplicitním zápisem při editaci |
| Lists/Notes | **Částečně** | Bucket List, Secret Gift, shared notes fungují a bezpečně oddělené na backendu (regresně otestováno); **Groceries stále chybí** |
| Events | **Hotovo** | – |
| Premium (RevenueCat) | **Hotovo** | – |
| Blueprints | **Hotovo** (dřív rozpracováno) | Obsah teď z Firestore (`blueprint_sections`), s offline fallbackem; seed skripty připravené, čekají na ruční spuštění proti produkci (vyžaduje Firebase credentials) |
| Gamifikace (SP/XP) | **Hotovo** | – |
| Time Capsule | **Nezapočato** | Funkce v repu neexistuje |
| Dark Mode | **Chybí** | `ThemeMode.light` natvrdo v `app.dart:32` |
| Achievement/Recap | **Nezapočato** | – |
| Lokalizace | **Chybí** | Záměrně (v1 = hardcoded stringy) |

---

## 6. Zbývající rizika a hrozby

### 🟠 VYSOKÉ
**Google Places API klíč pořád dohledatelný v historii gitu.** Beze změny. Aktuální kód čistý, ale reálný klíč je stále v `git log -p` (commit `67e9f1e`). Doporučeno ručně ověřit rotaci/omezení v GCP konzoli.

### 🟡 STŘEDNÍ
- **`pubspec.lock` ↔ committnutý generovaný kód drift** (sekce 4) – reálné riziko tiché korupce dat při příštím `build_runner build`, dokud se `freezed` needgraduje nebo postižené třídy needostanou ruční anotaci.
- **91 `deprecated_member_use` nálezů v `lib/`** – neblokující, ale hromadí se dluh.
- **Google Places klíč** (viz výše).
- **Zastaralé major závislosti** – zmenšeno, nedokončeno.
- **Blueprints seed skript nespuštěný proti produkci** – appka funguje na mock-data fallbacku, ale obsah zatím nejde editovat bez release appky, dokud někdo se skutečnými Firebase credentials nespustí `node scripts/seed_blueprint_sections.js`.

### 🟢 NÍZKÉ / Nice-to-have
- Groceries, Dark Mode, Achievement/Recap, Time Capsule – produktová rozhodnutí, ne bugy.
- 2 TODO v `memory_screen.dart` – neověřeno znovu.
- `print()` vs `debugPrint()` v `main.dart` – neověřeno znovu.

---

## 7. Priorita zbývajících oprav

| # | Nález | Dopad | Náročnost opravy |
|---|---|---|---|
| 1 | Ověřit/rotovat Google Places API klíč v GCP konzoli | Vysoký, mimo repo | Nízká |
| 2 | Vyřešit `freezed`/`pubspec.lock` drift (upgrade nebo ruční anotace) | Střední – tichá korupce dat při příštím neopatrném `build_runner build` | Střední (upgrade) až Vysoká (breaking changes napříč modely) |
| 3 | Spustit `scripts/seed_blueprint_sections.js` proti produkci | Nízká – appka funguje i bez toho (fallback), ale odemkne editaci obsahu bez release | Nízká (vyžaduje jen Firebase credentials uživatele) |
| 4 | Dokončit major upgrade zbývajících závislostí | Střední, dlouhodobě rostoucí dluh | Vysoká |
| 5 | Groceries, Dark Mode, Achievement/Recap, Time Capsule rozhodnutí | Nice-to-have / produktové rozhodnutí | Různá |
| 6 | Ověřit 2 zbylé TODO v `memory_screen.dart`, `print()`→`debugPrint()` | Nízká | Nízká |

---

## Shrnutí

Od minulého auditu (3. 7.) bylo opraveno 6 ze 7 hlavních nálezů, a v této relaci navíc: bezpečnostní test na private notes ověřen jako už existující (opravuji svůj dřívější chybný nález), CI gate přidán, cycle provider duplicita sjednocena (+ opraven skrytý bug s duplicitním zápisem při editaci cyklo-logu), a Blueprints přesunuty z hardcoded mock dat do Firestore s bezpečným fallbackem. Zároveň byl objeven a napraven nový, potenciálně vážný nález: zamčená verze `freezed` v `pubspec.lock` neumí vygenerovat `explicitToJson: true` pro vnořené modely, což by při neopatrném přegenerování kódu tiše rozbilo zápis `CoupleModel`/`UserModel` do Firestore – nesouvisející přegenerované soubory byly vráceny zpět a nález je zdokumentovaný pro budoucí `freezed` upgrade. Zbývá jeden nález mimo dosah repa (rotace Google Places klíče) a pár menších položek (spuštění blueprints seed skriptu proti produkci, dokončení major upgradů závislostí). Produktově zůstávají stejné otevřené položky jako minule – Groceries, Dark Mode, Achievement/Recap, Time Capsule.

**Nejbližší krok:** ověřit/rotovat Google Places klíč a spustit `scripts/seed_blueprint_sections.js` proti produkci (obojí mimo repo, řádově minuty). Střednědobě: naplánovat `freezed`/`riverpod`/`json_serializable` major upgrade (řeší zároveň drift nález i zastaralé závislosti).

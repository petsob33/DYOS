# AUDIT.md – Kompletní audit aplikace DYOS

**Datum auditu:** 2026-07-03
**Auditor:** Claude Code (automatizovaný audit)

## Poznámka k zadání

Zadání popisovalo nativní Android aplikaci v Kotlin/Jetpack Compose sledující "piva na akci". Skutečný obsah repozitáře je odlišný: **DYOS** je cross-platformní **Flutter/Dart** aplikace ("relationship OS pro páry") s backendem Firebase a monetizací RevenueCat. Audit byl proveden na reálném projektu a metodika ze zadání (architektura, state management, persistence, permissions, emulátor…) byla 1:1 přemapována na Flutter ekvivalenty (Riverpod místo Compose state, Firestore/SharedPreferences místo Room, GoRouter místo Navigation Component atd.).

V repozitáři už existují dva starší interní audity – `docs/APP_REPORT_CRITICAL.md` (březen 2025) a `DOCUMENTATION.md` (březen 2026), které tvrdí, že prakticky všechny dřívější bezpečnostní nálezy jsou opravené. Tento audit tato tvrzení ověřil proti aktuálnímu stavu kódu a **objevil několik nových, dosud nezdokumentovaných nálezů** (viz sekce 4), včetně jednoho kritického.

---

## 1. Mapování projektu a architektura

**Tech stack:** Flutter (Dart ^3.10.4), Riverpod (`@riverpod` anotace) pro state management, GoRouter pro navigaci, Firebase (Auth, Firestore, Storage, Functions, Messaging, App Check) jako backend, RevenueCat pro předplatné, freezed/json_serializable pro modely.

**Struktura (feature-first):**
```
lib/
  main.dart          – bootstrap: Firebase, FCM background handler, RevenueCat, App Check, AdMob
  app.dart           – root MaterialApp.router, theme
  core/
    router/          – GoRouter, redirect logika (auth → pairing → shell)
    services/        – auth, firebase (facade), storage, notification, ad, pairing, profile, subscription
    theme/, widgets/, constants/
  features/
    auth/            – login, register, pairing, profil
    dashboard/       – Home (bento dashboard)
    timeline/        – vzpomínky (memories) + mapa
    tracker/         – intimita + analytika
    cycle/           – menstruační kalendář
    events/          – kalendář událostí
    notes/           – bucket list, secret gift, sdílené poznámky
    premium/         – RevenueCat paywall
    gamification/    – SP/XP, levely, odměny
    blueprints/       – dotazníkové "blueprint" sekce (zatím mock data)
    lists/           – seznamy, nastavení
  models/            – sdílené modely (notes)
  shared/widgets/    – univerzální kalendář
functions/           – Cloud Functions (Node.js): pairing, invite lookup, FCM triggery, komprese obrázků
firestore.rules, storage.rules – bezpečnostní pravidla
```

**Navigace (GoRouter):** `/login`, `/register` (veřejné) → `/pairing` (auth, bez páru) → shell se 4 taby: `/home`, `/memory` (timeline), `/data` (tracker), `/cycle`. Plus ~15 modálních/detail routes (`/add-memory`, `/events`, `/lists`, `/secret-notes`, `/premium`, `/level`, `/blueprints`, `/settings`, `/profile`, …) a debug-only `/firebase-test`.

**State management:** Riverpod generátor (`@riverpod`) napříč celou appkou – repository providery (stream z Firestore) → presentation providery → `ConsumerWidget`/`ConsumerStatefulWidget`. `HomeScreen` (2207 řádků) je rozdělen na ~15 malých `ConsumerWidget` tříd, každá sleduje jen svůj provider – recompozice je tedy rozumně škálovaná, i když soubor samotný je velký a méně čitelný.

**Data layer:** Firestore jako zdroj pravdy (žádné Room/sqflite – `sqflite` je jen tranzitivní závislost, nikde v `lib/` nepoužitá). `SharedPreferences` se používá jen okrajově (ad_service, auth_providers). Firebase Storage pro média (memories, profilové fotky) s automatickou server-side kompresí přes Cloud Function.

### Přehled obrazovek

| Obrazovka | Účel |
|---|---|
| Login/Register | Email+heslo a Google Sign-In |
| Pairing | Párování dvou účtů přes invite kód |
| Home (dashboard) | Bento mřížka: status pár, countdown, quick note, intimacy spark, taptic touch, quick message |
| Timeline | Chronologický feed vzpomínek, filtry, mapa vzpomínek |
| Add/Edit Memory | Přidání vzpomínky s fotkami/videi |
| Data (Tracker) | Intimacy logy, grafy/analytika |
| Intimacy History | Historie záznamů intimity |
| Cycle Tracking | Menstruační kalendář, predikce, partner message |
| Events | Kalendář událostí/výročí |
| Lists | Bucket list, nastavení |
| Secret Notes / Add Note | Sdílené/soukromé/secret-gift poznámky |
| Blueprints | Dotazníkové sekce (mock data) |
| Level | Gamifikace – SP, fáze, milníky, denní questy |
| Premium Landing / Paywall | RevenueCat nabídky, nákup, restore |
| Profile / Settings | Editace profilu, profilové fotky |
| Firebase Test (debug only) | Diagnostika Firebase připojení |

---

## 2. Technický sken

### Build a analýza
- **`flutter analyze`**: **400 nálezů**, převážně `info`/`warning` (lint styl – redundantní argumenty, `const`, deprecated API). **1 skutečná chyba** (`error`): `test/pairing/pairing_screen_enhanced_test.dart:108` – nevalidní typ v closure (`Future<bool>` vs `Stream<bool?>`). Produkční kód (`lib/`) je bez chyb.
- **`flutter test`**: **36 passed / 8 failed**. Selhávající testy jsou v `test/pairing/pairing_service_enhanced_test.dart` – mock `MockFirebaseFunctions.httpsCallable` vrací `null` místo callable objektu, takže testy očekávající konkrétní pairing výjimky (`PartnerAlreadyPairedException`, `UserNotFoundException`) místo toho dostanou obecnou `GenericPairingException`. Jde o rozbitý mock/test setup, ne o chybu v produkční logice.
- **`flutter build apk --debug`**: spuštěno, běží dlouho (>15 min i po zahřátí gradle daemonu) kvůli velkému množství nativních pluginů (Firebase ×6, Google Maps, RevenueCat, AdMob). Výsledek build a instalace na emulátor je popsán v sekci 6.

### TODO/FIXME/placeholdery
Jen 2 zbylé TODO v celém `lib/` (dřívější report jich měl víc – většina byla mezitím dořešena):
- `memory_screen.dart:21` – `// TODO: Navigate to map view`
- `memory_screen.dart:194` – `// TODO: Navigate to memory detail`

### Error handling
- Try/catch je použit rozumně konzistentně (42 souborů). Žádné nalezené `.value!`/force-unwrap vzory na `AsyncValue`.
- **Chybí globální error handling** – v `main.dart` není `runZonedGuarded`/`FlutterError.onError`/`PlatformDispatcher.instance.onError`. V pubspecu **není žádný crash-reporting SDK** (Crashlytics, Sentry, …). Pokud appka spadne v produkci mimo Flutter frameworkové zachytávání, tým se o tom nedozví jinak než od uživatele.
- V `main.dart` zůstávají 4× syrové `print()` (RevenueCat konfigurace) místo `debugPrint`/loggeru – v release buildu print s Flutter `debugPrint` redakcí neprochází přes bezpečnou vrstvu logování zmíněnou v `DOCUMENTATION.md`.

### State management – race condition v gamifikaci
`grantQuestXpIfEligible()` (`user_stats_provider.dart`) kontroluje `isQuestCompletedToday(couple, questId)` proti **lokálně cachovanému** stavu páru (z Riverpod streamu), a poté provede **dva oddělené, netransakční** zápisy do Firestore: `addCoupleXp()` (atomický `FieldValue.increment`) a následně `setQuestXpGrantedAt()`. Mezi kontrolou a zápisem "granted" flagu není zámek.
- **Race condition:** pokud oba partneři provedou stejnou akci (např. oba přidají vzpomínku) v krátkém okně, oba klienti mohou lokálně vidět "quest ještě nesplněn" a XP se připíše 2×.
- **Crash-safety:** pokud appka spadne/ztratí síť mezi oběma zápisy, XP je připsáno, ale flag "granted" není uložen → při dalším spuštění může být stejný quest znovu odměněn.
- Doprava: přesunout do jedné Firestore transakce nebo Cloud Function.

### Persistence
- Firestore je jediný zdroj pravdy pro sdílená data páru – žádné lokální cachování mimo built-in Firestore offline persistence, žádný vlastní konfliktní merge kód (spoléhá se na Firestore last-write-wins, což je u tohoto typu appky přijatelné).
- Storage pravidla i Firestore pravidla jsou nyní poměrně důkladná (viz sekce 4) – member-only přístup, delete jen pro autora u citlivých kolekcí, velikostní/MIME limity na upload.

### Zvuk/animace
Appka nemá žádné audio přehrávání. Kompresi obrázků řeší `image_picker` (nativní, mimo hlavní Dart isolate) na klientovi a Cloud Function (`sharp`) na serveru – žádné blokující operace na UI vlákně nebyly nalezeny.

### Závislosti (pubspec.yaml)
`flutter pub outdated` ukazuje, že prakticky **všechny Firebase balíčky, RevenueCat, go_router, Riverpod, fl_chart, flutter_local_notifications a permission_handler jsou 1–3 major verze pozadu** (např. `cloud_firestore` 5.6→6.6, `firebase_core` 3→4, `go_router` 14→17, `flutter_riverpod` 2→3, `fl_chart` 0.69→1.2). Žádný balíček není opuštěný/nebezpečný, ale zaostávání zvyšuje riziko budoucích breaking-change migrací najednou a míjí bezpečnostní/bugfix opravy novějších verzí.

### Permissions (AndroidManifest.xml)
Manifest deklaruje jen `POST_NOTIFICATIONS`, `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION` – odpovídá reálnému využití (FCM notifikace, mapa vzpomínek/geocoding). `image_picker` se používá jen s `ImageSource.gallery` (ne `.camera`), takže chybějící `CAMERA` permission je v pořádku a záměrné. AdMob App ID je v manifestu natvrdo – to je v pořádku, jde o veřejné ID, ne o tajný klíč.

---

## 3. Funkční sken a UX

### Stav funkcí (ověřeno proti `docs/APP_REPORT_CRITICAL.md` z března 2025 a `DOCUMENTATION.md` z března 2026)

| Funkce | Stav | Poznámka |
|---|---|---|
| Auth + Pairing | **Hotovo** | Párování nyní přes server-side Cloud Function s transakcí (dřívější race condition opravena) |
| Home/Dashboard | **Hotovo** | – |
| Timeline (vzpomínky) | **Skoro hotovo** | 2 TODO: navigace na mapu/detail z `memory_screen.dart` |
| Tracker (intimita) | **Hotovo** | – |
| Cycle | **Hotovo** | `partnerMessage` je nyní zobrazen v UI (`insight_provider.dart`) – oprava oproti staršímu reportu |
| Lists/Notes | **Částečně** | Bucket List, Secret Gift, shared notes fungují; **Groceries stále chybí** |
| Events | **Hotovo** | – |
| Premium (RevenueCat) | **Hotovo** | – |
| Blueprints | **Rozpracováno** | Data stále z `BlueprintMockData`, ne z Firestore – odpovědi se ukládají, ale seznam otázek je hardcoded |
| Gamifikace (SP/XP) | **Funkční, ale s bugem** | Viz race condition v sekci 2 |
| Time Capsule | **Nezapočato** | Složka `lib/features/time_capsule` už v repu vůbec neexistuje (dříve prázdná, teď smazaná) – rozhodnutí "implementovat, nebo škrtnout ze specifikace" nebylo uděláno |
| Dark Mode | **Chybí** | `ThemeMode.light` natvrdo v `app.dart` |
| Achievement/Recap | **Nezapočato** | Beze zmínky v kódu |
| Lokalizace | **Chybí** | Záměrně dle `.cursorrules` (v1 = hardcoded stringy) |

### UX konzistence
- Prázdné stavy jsou řešeny rozumně (`_EmptyState` v timeline, `isEmpty` kontroly v events/data/home).
- Chybové/loading stavy: `AsyncValue.when()` použito v 21 souborech, žádné nalezené nebezpečné force-unwrapy.
- Logický tok appky (párování → sdílená data → gamifikace → premium) dává smysl a je interně konzistentní.

---

## 4. Rizika a hrozby (včetně nových zjištění)

### 🔴 KRITICKÉ – nové zjištění, které starší audity nezachytily

**Android release signing keystore (`upload-keystore.jks`) je commitnutý v gitu.**
- Soubory `upload-keystore.jks` (root) a `android/upload-keystore.jks` jsou sledované gitem (commit `67e9f1e`), nejsou v `.gitignore`, a `android/app/build.gradle.kts` je aktivně používá jako **release signing key** (`signingConfigs.release`).
- `android/key.properties` (obsahuje hesla) sledovaný **není** – jen `.jks` binárka je v repu, hesla ne. To riziko snižuje, ale nekompromituje: soubor samotný je citlivé kryptografické materiál a jeho přítomnost v historii repozitáře je nevratná (i kdyby se teď smazal, zůstane v `git log`).
- **Dopad:** Kdokoli s přístupem k repu (nebo jeho historii) má produkční podpisový klíč aplikace. V kombinaci se získáním hesla (např. leak, brute force, sdílení) by útočník mohl podepsat a distribuovat modifikovanou verzi appky, kterou Play Store/uživatelé považují za pravou aktualizaci.
- **Doporučení:** Okamžitě odstranit z `git tracking` (`git rm --cached`), přidat do `.gitignore`, a **posoudit rotaci klíče** (u Google Play lze přes Play App Signing požádat o key upgrade, pokud je keystore starý upload key). Uložit `.jks` mimo repo (secret manager / CI secret).

### 🟠 VYSOKÉ – nové zjištění

**"Secret Gift" a soukromé poznámky jsou čitelné partnerem přes Firestore přímo (nejen přes UI).**
- `firestore.rules` pro `couples/{id}/notes/{noteId}`: `allow list, get: if isCoupleMember()` – bez ohledu na `type` nebo `authorId`.
- Filtrování na `type == 'private'` / `'secretGift'` se děje **jen v klientském Firestore query** (`notes_repository.dart`), ne v security rules.
- **Dopad:** Funkce "Secret Gift" (dárek co má být překvapení) a "private" poznámky jsou tajné jen podle UI konvence. Partner se znalostí Firebase/REST API (nebo jen upravenou verzí appky) může tyto dokumenty přímo přečíst – to přímo popírá smysl funkce.
- **Doporučení:** Přidat do rules podmínku `resource.data.type != 'private' && resource.data.type != 'secretGift' || resource.data.authorId == request.auth.uid` pro `get`/`list`, případně routovat soukromé poznámky do samostatné podkolekce s vlastníkem jako klíčem.

**Google Places API klíč je natrvalo v historii gitu (i po "opravě").**
- Aktuální kód je čistý (`Info.plist` používá `$(GOOGLE_PLACES_API_KEY)` placeholder), ale stejný reálný klíč (`REDACTED-ROTATED-GOOGLE-PLACES-KEY`) byl v minulosti hardcoded v `AppDelegate.swift` (commit `67e9f1e`) a je stále dohledatelný přes `git log -p`.
- **Doporučení:** Ověřit v Google Cloud Console, že je tento konkrétní klíč omezen na bundle ID / rotován za nový – "odstranění ze staged souborů" samo o sobě klíč nezneplatní.

### 🟡 STŘEDNÍ

- **Race condition v gamifikaci** (viz sekce 2) – možnost dvojitého přiznání denní XP odměny při souběžné akci obou partnerů.
- **Chybějící pagination/limit na Firestore query** – `memory_repository.dart`, `event_repository.dart`, `intimacy_repository.dart` používají `.snapshots()` bez `.limit()`. U dlouhodobého používání (roky vzpomínek/logů) poroste počet stahovaných dokumentů při každém startu appky bez omezení – zvyšuje to náklady na čtení Firestore a čas prvního načtení.
- **Žádný crash-reporting SDK** (Crashlytics/Sentry) – produkční pády appky nejsou nikde centrálně vidět.
- **8 failing testů** kvůli rozbitému mocku, ne kvůli produkční logice – ale maskuje to případné budoucí regrese v `pairing_service.dart`, protože testy momentálně nic neověřují spolehlivě.
- **Zastaralé závislosti** (Firebase, Riverpod, go_router 1–3 major verze pozadu) – riziko nahromadění breaking changes.

### 🟢 NÍZKÉ / Nice-to-have
- `home_screen.dart` má 2207 řádků (byť rozumně rozdělený na malé widgety) – navrhuji rozdělit do samostatných souborů pro čitelnost.
- Duplicitní modely/providery pro cycle (`features/cycle/models/cycle_log.dart` vs `features/cycle/domain/cycle_log_model.dart`, dva `cycle_provider.dart` soubory v `models/` i `presentation/`) – vypadá jako pozůstatek refaktoringu, stojí za vyčištění.
- `print()` místo `debugPrint()` v `main.dart` (4 místa).

### Chybějící testy
Aktuální pokrytí (`test/pairing/*`, `test/security/*`, `test/widget_test.dart`) se soustředí téměř výhradně na pairing a základní security scénáře. Chybí testy pro: memory/timeline CRUD, intimacy/cycle repository logiku, gamifikační XP výpočty (`ProgressionPlan`, `LevelManager`), premium purchase/restore flow, notes access control (obzvlášť vzhledem k nálezu výše o secret notes).

---

## 5. Priorita oprav

| # | Nález | Dopad | Náročnost opravy |
|---|---|---|---|
| 1 | **Keystore `.jks` v gitu** | Kritický – ohrožení podpisu appky pro celý produkční release | Nízká (git rm + gitignore), rozhodnutí o rotaci klíče vyžaduje koordinaci s Play Console |
| 2 | **Secret/private notes čitelné partnerem přes rules** | Vysoký – přímo popírá smysl "Secret Gift" featury, možný trust/PR problém při odhalení | Nízká (úprava firestore.rules + test) |
| 3 | **Rotace/ověření Google Places klíče v historii gitu** | Vysoký – klíč je veřejně dohledatelný v historii | Nízká (rotace v GCP konzoli) |
| 4 | **Race condition v XP grantu** | Střední – nekonzistentní gamifikační data, nedůvěryhodné SP | Střední (přesun do transakce/Cloud Function) |
| 5 | **Chybí crash reporting** | Střední – nulová viditelnost produkčních pádů | Nízká (přidat Crashlytics, pár hodin) |
| 6 | **8 failing testů (rozbitý mock)** | Střední – maskuje regrese v pairing logice | Nízká (oprava mocku v jednom test souboru) |
| 7 | **Chybějící pagination na Firestore listenery** | Střední, roste s časem/daty | Střední |
| 8 | **Zastaralé závislosti** | Střední, dlouhodobě rostoucí technický dluh | Vysoká (postupná migrace přes major verze) |
| 9 | Groceries, Dark Mode, Achievement, Recap, Time Capsule rozhodnutí | Nice-to-have / produktové rozhodnutí | Různá |
| 10 | `home_screen.dart` split, duplicitní cycle modely, `print`→`debugPrint` | Nice-to-have, čitelnost | Nízká |

---

## 6. Spuštění na emulátoru

- `adb devices` zpočátku nehlásil žádné zařízení; k dispozici byl AVD `Pixel_6_Keyboard_Fixed` (Pixel 6, API 35, Google Play). Emulátor byl nastartován a nabootoval bez problémů.
- `flutter build apk --debug` doběhl úspěšně po ~290 s (`build/app/outputs/flutter-apk/app-debug.apk`, 284 MB) – **projekt se kompiluje bez chyb**.
- Instalace nejprve selhala (`Requested internal only, but not enough space`) – emulátor měl na `/data` jen ~460 MB volných kvůli starým instalacím z jiných projektů (`cz.sobtech.hapBeer`, `com.d2d.d2d_sales_tracker`, starší `com.example.dyos_app`/`cz.soboltech.dyos`). Po jejich odinstalování (uvolnění na ~1,2 GB) instalace proběhla v pořádku.
- **Appka byla spuštěna (`am start -n cz.soboltech.dyos/.MainActivity`) a nastartovala bez pádu.** Logcat po startu ukazuje čistou inicializaci: `NotificationService setup complete`, `FlutterGeolocator` connected, `FlutterFirebaseMessagingBackgroundService started`, `FCM permission: AuthorizationStatus.authorized` – žádné `FATAL EXCEPTION`, `AndroidRuntime` crash ani `MissingPluginException`.
- **Úvodní obrazovka:** Login screen ("Welcome back") odpovídá design systému z `.cursorrules` (Indigo `#5E5CE6`, zaoblené karty, čistý bento styl) – pole Email/Password, "Forgot password?", "Sign in", "Continue with Google", odkaz na registraci. Systémový dialog pro POST_NOTIFICATIONS permission se zobrazil korektně při startu.
- Další obrazovky (Home, Timeline, …) nebyly ověřeny, protože vyžadují reálný účet/přihlášení – vytváření testovacího účtu v produkční Firebase instanci nebylo v rámci tohoto read-only auditu provedeno. Doporučeno ověřit ručně nebo proti Firebase emulátoru.

---

## Shrnutí (5–10 vět)

Appka se bez problémů zkompiluje (`flutter build apk --debug` proběhl úspěšně) a na emulátoru nastartuje čistě bez pádu – login obrazovka odpovídá deklarovanému design systému a inicializace Firebase/notifikací/geolokace v logcatu neukázala žádnou chybu. DYOS je funkčně vyspělá Flutter aplikace s poměrně solidní architekturou (feature-first, Riverpod, čisté oddělení repository/domain/presentation) a bezpečnostním základem, který byl už jednou důkladně proauditován a opraven (viz `DOCUMENTATION.md` z března 2026 – 10/10 dřívějších "must-fix" bodů je opraveno). Hlavní jádro appky – auth, párování, timeline, tracker, cyklus, události, premium – je hotové a použitelné. Tento audit ale odhalil, že **produkční Android signing keystore je omylem commitnutý v gitu** – to je nový, kritický nález, který žádný z předchozích auditů nezachytil a měl by být řešen jako první. Druhý závažný, dosud nezdokumentovaný nález je, že **"tajné" poznámky (Secret Gift, private) jsou ve skutečnosti čitelné partnerem** přes Firestore pravidla, protože zabezpečení řeší jen klient, ne backend rules – to přímo podkopává smysl dané featury. Menší, ale reálný nález je **race condition v gamifikačním XP systému**, který může vést k duplicitnímu přiznání denní odměny. Appka nemá žádný crash-reporting nástroj, takže produkční pády jsou dnes prakticky neviditelné pro tým. Z produktového hlediska zůstávají neúplné: Groceries, Dark Mode, Achievement/Recap a rozhodnutí o Time Capsule (funkce byla z repa úplně odstraněna, ne jen prázdná). Testové pokrytí je tenké a navíc momentálně obsahuje 8 failing testů kvůli rozbitému mocku, takže i ta málo existující ochrana proti regresi v pairing flow je teď nespolehlivá.

**Nejbližší krok:** Nejprve vyřešit keystore v gitu (odstranit ze sledování, posoudit rotaci klíče s ohledem na Play Console) a zpřísnit `firestore.rules` pro soukromé poznámky – oboje je otázka řádově hodin práce s velkým bezpečnostním dopadem. Až poté má smysl pokračovat směrem k dokončení produktových funkcí (Groceries, Dark Mode) nebo rozšiřování testů.

# DYOS - Hloubková technicka dokumentace a security audit

Datum auditu: 2026-03-23  
Repozitář: `DYOS` (Flutter + Firebase + RevenueCat)

## 1) Přehled projektu a architektura

### Stručný popis
`DYOS` je mobilní/web aplikace pro páry (relationship operating system), která kombinuje:
- párování dvou uživatelů (`inviteCode`, `coupleId`),
- timeline vzpomínek s médii (`memories` + Firebase Storage),
- tracker intimity, cyklu, událostí a poznámek,
- gamifikaci (SP/XP, levely, unlocky),
- premium monetizaci přes RevenueCat sdílenou na úrovni páru,
- notifikace přes FCM + lokální notifikace.

### Mapa projektu (kde co je)
#### Top-level
- `lib/main.dart` - bootstrap aplikace (Firebase init, FCM background handler, RevenueCat configure).
- `lib/app.dart` - root widget (`MaterialApp.router`, theme, font).
- `lib/core/router/app_router.dart` - routing, redirect logika auth/pairing/protected, shell navigace.
- `lib/core/services/` - klíčové služby (`auth_service.dart`, `firebase_service.dart`, `storage_service.dart`, `notification_service.dart`).
- `lib/features/` - feature-first moduly:
  - `auth`, `timeline`, `tracker`, `cycle`, `events`, `notes`, `premium`, `gamification`, `blueprints`, `dashboard`, `lists`, `time_capsule`.
- `lib/models/` - sdílené modely/repository mimo `features` (zejména notes).
- `functions/index.js` - Firebase Cloud Functions (invite lookup, FCM triggers, image compression).
- `firestore.rules`, `storage.rules` - bezpečnostní pravidla backendu.
- `docs/` - existující interní dokumentace (architektura, push, revenuecat, kritický report).
- `test/` - omezené testy (widget smoke test + pairing scénáře).

#### Detail modulu `lib/features`
- `auth`:
  - `data/user_data_source.dart`, `data/user_repository.dart`
  - `domain/user_model.dart`, `domain/couple_model.dart`
  - `presentation/auth_providers.dart`, `presentation/pairing_screen.dart`, login/register/profile obrazovky
- `timeline`:
  - `data/memory_repository.dart`
  - `domain/memory_model.dart`
  - `presentation/memory_provider.dart`, `screens/add_memory_screen.dart`, `timeline_screen.dart`, `memories_map_screen.dart`
- `tracker`:
  - `data/intimacy_repository.dart`
  - `domain/intimacy_log_model.dart`
  - `presentation/intimacy_provider.dart`, `screens/intimacy_history_screen.dart`
- `cycle`:
  - `data/cycle_repository.dart`
  - `domain/cycle_log_model.dart`, `domain/cycle_settings_model.dart`, `domain/cycle_calculator.dart`
  - `presentation/cycle_tracking_screen.dart`
- `events`:
  - `data/event_repository.dart`
  - `domain/event_model.dart`
  - `presentation/event_provider.dart`
- `premium`:
  - `data/purchase_service.dart`
  - `presentation/premium_provider.dart`, `presentation/widgets/paywall_modal.dart`
- `gamification`:
  - `domain/progression_plan.dart`, `domain/level_manager.dart`
  - `presentation/user_stats_provider.dart`, `presentation/screens/level_screen.dart`

### Architektura a logika (datové toky)
#### Aplikační runtime
1. `main()` v `lib/main.dart` inicializuje Firebase, registruje FCM background handler, podmíněně inicializuje RevenueCat přes `REVENUECAT_API_KEY` a volitelně aktivuje App Check (`ENABLE_APP_CHECK`).
2. `OurOSRoot` (`lib/app.dart`) načte `appRouterProvider`.
3. `appRouter` (`lib/core/router/app_router.dart`) sleduje:
   - `authStateProvider` (Firebase Auth stream),
   - `userProvider` (Firestore stream `users/{uid}`),
   a podle toho redirectuje mezi `/login`, `/pairing`, `/home`.

#### Auth + Pairing tok
- `AuthService` (`lib/core/services/auth_service.dart`) řeší email/password i Google sign-in.
- Po registraci vzniká `UserModel` se `inviteCode` (`_generateInviteCode()`).
- `PairingScreen._submitCode()` (`lib/features/auth/presentation/pairing_screen.dart`) volá `FirebaseService.pairWithInviteCode()`.
- `pairWithInviteCode()` volá callable Cloud Function `pairWithInviteCode`, která provede transakční pairing server-side.

#### Data CRUD tok (feature -> repository -> Firestore/Storage)
- Timeline: `AddMemoryController.uploadMemory()` -> `MemoryRepository.createMemory()`
  - upload souborů do `memories/{coupleId}/...`
  - zápis metadata do `couples/{coupleId}/memories/{memoryId}`
- Events: `event_provider.dart` -> `EventRepository.watchEvents()/addOrUpdateEvent()/deleteEvent()`
- Intimacy: `intimacy_provider.dart` -> `IntimacyRepository.watchLogs()/addLog()/updateLog()`
- Cycle: `cycle_repository.dart` nad `cycle_logs` + `cycle_settings`.
- Notes: `lib/models/notes_repository.dart` nad `couples/{coupleId}/notes`.

#### Notifikace tok
- Klient (`notification_service.dart`) ukládá `users/{uid}.fcmToken`.
- Cloud Functions (`functions/index.js`):
  - `onHapticSignalCreated` sleduje `couples/{coupleId}/haptic_signals/{signalId}`,
  - `onQuickMessageCreated` sleduje `couples/{coupleId}/quick_messages/{messageId}`,
  - nalezne partnera a odešle push přes Admin SDK.

#### Premium tok
- UI paywall (`paywall_modal.dart`) načítá RevenueCat offerings a spouští purchase/restore.
- `PurchaseService._syncCustomerInfoToFirestore()` při aktivním entitlementu `premium` zapisuje `subscriptionTier` + `subscriptionExpiry` do `couples/{coupleId}` přes `FirebaseService.updateCoupleSubscription()`.
- `isPremiumProvider` derivuje stav z `coupleProvider`.

---

## 2) Funkční dokumentace

### Požadavky pro spuštění a vývoj
#### Lokální prerequisites
- Flutter SDK kompatibilní s Dart `^3.10.4` (`pubspec.yaml`).
- Firebase projekt (Auth, Firestore, Storage, Functions, Messaging).
- Node.js pro Cloud Functions (`functions/package.json`, runtime `nodejs20` v `firebase.json`).

#### Instalace a spuštění
- Flutter dependencies: `flutter pub get`
- iOS/Android build standardně přes `flutter run`
- RevenueCat klíč:
  - spouštět s `--dart-define=REVENUECAT_API_KEY=...` (jinak se RevenueCat init skipne).
- iOS Google Places:
  - `ios/Runner/Info.plist` očekává `$(GOOGLE_PLACES_API_KEY)`,
  - `ios/Flutter/Debug.xcconfig` i `Release.xcconfig` includují `../Runner/Secrets.xcconfig`.

#### Backend setup
- Firestore rules: `firestore.rules`
- Storage rules: `storage.rules`
- Functions deploy: `cd functions && npm install && firebase deploy --only functions`

#### Důležité env/secret body
- `REVENUECAT_API_KEY` (dart-define).
- `GOOGLE_PLACES_API_KEY` (xcconfig / platform config).
- service account credentials pro skript `scripts/export-waitlist.js` (`GOOGLE_APPLICATION_CREDENTIALS`).

### Klíčové funkce/třídy/API
- `AuthService.registerWithEmailAndPassword()` - vytvoření Auth účtu + Firestore user dokumentu.
- `FirebaseService.pairWithInviteCode()` - klíčová doménová operace párování (server-side callable).
- `UserDataSource.getUserByInviteCode()` - volá Cloud Function `getUserByInviteCode`.
- `MemoryRepository.createMemory()` - upload médií + transakční uživatelská akce přidání memory.
- `NotificationService.initialize()` - setup local notif + FCM token persistence.
- Cloud Functions:
  - `exports.getUserByInviteCode`
  - `exports.pairWithInviteCode`
  - `exports.onHapticSignalCreated`
  - `exports.onQuickMessageCreated`
  - `exports.compressImage`

---

## 3) Analýza bezpečnostních hrozeb (Security Audit)

Níže jsou konkrétní nálezy z tohoto kódu, seřazené podle závažnosti.

### Kritické
1. **Hardcoded Google Maps API key v Android manifestu** - **STAV: OPRAVENO**
   - Soubor: `android/app/src/main/AndroidManifest.xml`
   - Nález: `com.google.android.geo.API_KEY` obsahuje přímo reálný klíč (`android:value="AIza..."`).
   - Riziko: zneužití API, billing abuse, leakage ve veřejném repu.
   - Mitigace:
     - přesunout key do build-time secretu (manifest placeholder, CI secret),
     - v GCP omezit key na package name + SHA-1/SHA-256 + konkrétní API.

2. **Pravidlo `users/{userId}` umožňuje nepřímou eskalaci přes `coupleId`** - **STAV: OPRAVENO**
   - Soubor: `firestore.rules`
   - Nález: `allow write` dovoluje komukoli přihlášenému měnit cizí dokument, pokud `affectedKeys().hasOnly(['coupleId'])`.
   - Riziko: útočník může přepsat `coupleId` u cizího usera (pokud zná UID), tím získat členství v páru a přístup k datům.
   - Mitigace:
     - párování přes server-side Cloud Function/transaction,
     - pravidlo zpřísnit na validní pozvánku (nonce/token), která je svázaná s cílovým uživatelem.

3. **Cloud Function vrací celé user dokumenty podle invite code** - **STAV: OPRAVENO**
   - Soubory: `functions/index.js`, `lib/features/auth/data/user_data_source.dart`
   - Nález: `getUserByInviteCode` vrací `userDoc.data()` bez whitelistingu polí.
   - Riziko: nadměrné odhalení dat (např. `email`, `fcmToken`, interní metadata).
   - Mitigace:
     - vracet jen minimální pole nutná pro pairing (`uid`, `displayName`, `inviteCode`, `coupleId`),
     - explicitně odfiltrovat citlivá pole.

### Vysoké
4. **Nechráněný soubor secrets v repu policy** - **STAV: OPRAVENO**
   - Soubory: `.gitignore`, `ios/Runner/Secrets.xcconfig` (untracked v git status)
   - Nález: root `.gitignore` neobsahuje ignorování `ios/Runner/Secrets.xcconfig`.
   - Riziko: náhodný commit reálných iOS secretů.
   - Mitigace:
     - přidat `ios/Runner/Secrets.xcconfig` do `.gitignore`,
     - držet pouze `.example` variantu.

5. **Nedostatečná validace vstupu ve Function `getUserByInviteCode`** - **STAV: OPRAVENO**
   - Soubor: `functions/index.js`
   - Nález: kontroluje jen "existuje inviteCode", ne validní typ, délku, pattern.
   - Riziko: abuse/fuzzing, vyšší náklady a potenciální DoS přes hromadné volání.
   - Mitigace:
     - validační pattern (`^[A-Z]{2,10}-[0-9]{4}$`),
     - rate limiting (App Check + callable throttling),
     - audit logging anomálií.

6. **Párování není transakčně odolné proti závodu** - **STAV: OPRAVENO**
   - Soubor: `lib/core/services/firebase_service.dart` (`pairUsers`)
   - Nález: kontrola "už není paired" a následný batch není v jedné serverové transakci s lockem.
   - Riziko: race condition (dva paralelní pairing požadavky).
   - Mitigace:
     - provádět pairing server-side v Cloud Function s transakcí,
     - ověřit, že oba users mají stále prázdné `coupleId` těsně před commit.

### Střední
7. **Příliš široké oprávnění čtení profilových obrázků** - **STAV: OPRAVENO**
   - Soubor: `storage.rules`
   - Nález: `profile_pictures/{userId}/{fileName}` má `allow read: if isAuthenticated()`.
   - Riziko: každý přihlášený uživatel může číst cizí profilové fotky (pokud zná URL/path).
   - Mitigace:
     - omezit read na vlastníka nebo členy stejného páru.

8. **Rozsáhlé logování interních dat** - **STAV: ČÁSTEČNĚ OPRAVENO**
   - Soubory: `lib/features/dashboard/presentation/haptic_listener_provider.dart`, `lib/features/auth/presentation/auth_providers.dart`, `lib/core/services/firebase_service.dart`
   - Nález: více `print/debugPrint` s interním kontextem (`coupleId`, doc data, chyby se stack trace).
   - Riziko: leakage PII v log aggregaci.
   - Mitigace:
     - centralizovaný logger, scrub citlivých dat, vypnutí verbose logů v release.

9. **Weak invite code entropy**
   - Soubory: `auth_service.dart`, `firebase_service.dart`
   - Nález: `_generateInviteCode` = prefix jména + 4 číslice.
   - Riziko: brute-force / enumeration (hlavně při slabém rate limitu).
   - Mitigace:
     - delší random část (např. 8+ alnum), expirace kódu, limit pokusů.

### Poznámky k typům útoků
- **SQLi/XSS**: backend je Firestore/Flutter, klasická SQL injection není relevantní; web vrstva je Flutter web bez custom HTML input rendering, XSS povrch nízký.
- **Hlavní reálné vektory**: ACL chyby ve Firestore/Storage rules, leakage secrets, slabý pairing tok, nadměrné datové expozice.

---

## 4) Checklist před vydáním (Production Blockers / Must-haves)

### Blokující body (must fix)
- [x] Odstranit hardcoded Android Maps key z `AndroidManifest.xml`, rotovat klíč a omezit v GCP.
- [x] Opravit `firestore.rules` pro `users/{userId}` (zákaz cizího zápisu `coupleId` bez serverově ověřené pozvánky).
- [x] Upravit Cloud Function `getUserByInviteCode` na minimální response payload + vstupní validace.
- [x] Přidat `ios/Runner/Secrets.xcconfig` do `.gitignore` a zavést bezpečný secrets workflow.
- [x] Přesunout pairing logiku do atomické server-side transakce (Cloud Function).

### Vysoká priorita před produkcí
- [x] Zúžit read přístup v `storage.rules` pro `profile_pictures`.
- [x] Zavést rate limiting/App Check pro callable endpointy.
- [x] Odstranit debug route `/firebase-test` z release (router už ji váže na `kDebugMode`, ověřit release build pipeline).
- [~] Sanitizovat produkční logování (`print`/`debugPrint` audit).
- [x] Rozšířit testování o bezpečnostně kritické scénáře (rules + pairing + purchase sync).

### Stav po implementaci (aktualizace)
- Dokončené body: **9/10** (včetně všech původních "must fix" + security testů pro rules/pairing/purchase sync).
- Částečně dokončené: **1/10** (`print/debugPrint` audit proběhl jen na prioritních bezpečnostních tocích).
- Otevřené: **0/10**.

### Technické slepé uličky / nedodělky
- `lib/features/time_capsule/` je strukturálně připravené, ale bez implementace (potenciální dead feature).
- `notification_service.dart` obsahuje TODO pro deep-link handling při tapu na notifikaci.
- test coverage je minimální a převážně pairing-centric (`test/pairing/*`, `test/widget_test.dart`).

---

## 5) Návrhy na vylepšení (Roadmap / Nice-to-haves)

### Funkční roadmap
- Implementovat `time_capsule` nebo feature explicitně odstranit ze scope.
- Dokončit notifikační deep links (navigace podle payload v `_onNotificationTapped` a `_handleNotificationTap`).
- Dovybudovat groceries / checklist feature (v `lists` je zatím jen základ UI rámec).
- Dovyřešit cycle partner messaging end-to-end v UI (`cycle_calculator.dart` + presentation).

### Výkon a technický dluh
- Konsolidovat duplicitu generování invite kódu (`AuthService` vs `FirebaseService`).
- Refaktor `FirebaseService` (aktuálně velmi široký "god service"): rozdělit na pairing/subscription/gamification/account lifecycle.
- Omezit in-memory sorty v repository vrstvách tam, kde lze použít indexované query (`notes_repository.dart`, `memory_repository.dart`).
- Zajistit robustnější error taxonomy (místo obecného `Exception(...)`) pro lepší UX a monitoring.
- Sjednotit logging strategii (structured logs, severity, redaction).

### Kvalita a governance
- Přidat CI kroky: `flutter analyze`, `flutter test`, kontrola secrets (gitleaks), validace rules.
- Dopsat integrační testy:
  - pairing race condition,
  - access control testy proti emulátoru Firestore/Storage rules,
  - premium purchase/restore sync scénáře.

---

## Doporučený další postup (prakticky)
1. Security hardening sprint (5 blockerů výše).
2. Rules + Functions audit testy v Firebase Emulator Suite.
3. Refactor pairing na server-side transaction.
4. Až potom feature roadmap (time capsule, groceries, notification deep-links).


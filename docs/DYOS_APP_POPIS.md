# DYOS — kompletní popis aplikace

**Datum:** 2026-07-20
**Co je DYOS:** cross-platformní Flutter aplikace "relationship OS pro páry" — sdílený prostor pro pár, kde oba partneři společně sledují vzpomínky, intimitu, menstruační cyklus, události, poznámky a "gamifikovaně" sbírají body za používání appky. Backend je celý na Firebase, platby přes RevenueCat, reklamy přes AdMob.

---

## 1. Tech stack a architektura

- **Frontend:** Flutter (Dart `^3.10.4`), balíček se jmenuje interně `ouros_app`.
- **State management:** Riverpod s code-genem (`@riverpod` anotace, `riverpod_generator`) — žádný ruční `Provider`/`StateNotifier` boilerplate.
- **Navigace:** `go_router` (`^17.3.0`), jeden centrální `GoRouter` provider s reaktivní redirect logikou.
- **Modely:** `freezed` + `json_serializable` — každý doménový model je immutable `@freezed` třída s `fromJson`/`toJson`, u Firestore modelů navíc `fromFirestore(DocumentSnapshot)` factory a `TimestampConverter` pro `Timestamp ↔ DateTime`.
- **Backend:** Firebase — Auth, Firestore, Storage, Cloud Functions (Node.js), Cloud Messaging (FCM), App Check, Crashlytics.
- **Monetizace:** RevenueCat (`purchases_flutter`) pro předplatné, Google AdMob (`google_mobile_ads`) pro banner/interstitial/rewarded reklamy.
- **Ostatní klíčové balíčky:** `table_calendar`, `fl_chart` (grafy), `flutter_local_notifications`, `google_maps_flutter` + `geolocator`/`geocoding` (mapa vzpomínek), vendorovaný fork `google_places_autocomplete` (jen Android — iOS nemá nativní implementaci kvůli konfliktu deployment targetu), `cached_network_image`, `google_fonts` (Inter), `shared_preferences`.

**Vstupní bod (`lib/main.dart`):** `runZonedGuarded` obaluje `main()`; inicializuje Firebase, bezpečné/redigované logování (`_configureSafeDebugLogging` — regexem maskuje e-maily/uid/coupleId/tokeny v logu), Crashlytics (vypnutý v debug módu, napojený na `FlutterError.onError`/`PlatformDispatcher.instance.onError`), App Check (web reCAPTCHA v3 / Android Play Integrity / Apple DeviceCheck, s debug-provider fallbackem a detekcí emulátoru), RevenueCat (jen pokud je nastaven `--dart-define=REVENUECAT_API_KEY`), FCM background handler, a nakonec `runApp(ProviderScope(...))`.

**Struktura kódu (feature-first):**
```
lib/
  main.dart, app.dart          — bootstrap, root MaterialApp.router
  core/
    router/                    — GoRouter + redirect logika
    services/                  — auth, firebase (facade), pairing, profile,
                                  subscription, notification, ad, storage
    theme/, widgets/, constants/
  features/<name>/
    domain/    — Freezed modely, čisté kalkulátory (bez závislosti na Firestore)
    data/      — XxxRepository (obaluje Firestore/Storage/Functions), @riverpod
    presentation/ — @riverpod stream/future providery + screens/widgets
functions/                     — Cloud Functions (Node.js)
firestore.rules, storage.rules — bezpečnostní pravidla
```
Každá feature (`auth`, `blueprints`, `cycle`, `dashboard`, `events`, `gamification`, `lists`, `notes`, `premium`, `timeline`, `tracker`) drží tento 3-vrstvý vzor: `domain` (čistá data/logika) → `data` (Firestore I/O) → `presentation` (providery + UI).

---

## 2. Navigace (`lib/core/router/app_router.dart`)

**Redirect logika** (reaktivně sleduje auth stav, uživatelský dokument a dočasný `pairingConfirmedCoupleIdProvider`, který přemostí krátké okno mezi dokončením párování na serveru a promítnutím `coupleId` do Firestore streamu):

**auth → pairing → shell**
1. Nepřihlášený → jen `/login`/`/register`.
2. Přihlášený, ale nespárovaný → vynuceno `/pairing`.
3. Přihlášený a spárovaný → shell appky (`/home`).

**Bottom-tab shell** (`StatefulShellRoute.indexedStack`, 4 taby): `/home` (Dashboard), `/memory` (Timeline, SP-gated), `/data` (Tracker), `/cycle` (Cycle). Podporuje swipe mezi taby, swipe-up na Quick Add sheet, centrální "+" FAB, a banner reklamu pro nepremiové uživatele.

**Ostatní routes:** `/login`, `/register`, `/pairing`, `/settings`, `/profile`, `/chat`, `/premium`, `/level`, `/blueprints`, `/blueprint/:sectionId`, `/blueprint/travel-config`, `/edit-profile-picture`, `/intimacy-history`, `/secret-notes`, `/add-memory`, `/memory/edit`, `/memory/map`, `/memory/detail`, `/add-note`, `/events`, `/lists`, `/system-status-demo`, plus debug-only `/firebase-test`.

---

## 3. Přehled funkcí (feature by feature)

### Auth + Pairing (`features/auth/`)
Email/heslo i Google Sign-In. `UserModel` (uid, email, displayName, inviteCode, coupleId, ...), `CoupleModel` (members, subscriptionTier/Expiry, xp, blueprintAnswers, completedBlueprintSections, questXpLastGrantedAt). Párování dvou účtů běží **server-side přes Cloud Function** (`pairWithInviteCode`/`pairWithEmail`) v jedné transakci — vytvoří `couples/{id}`, zapíše `coupleId` oběma uživatelům a nastaví **custom Auth claim `coupleId`** (používá ho Storage rules). Invite kódy mají formát `NAME-1234`.

### Dashboard / Home (`features/dashboard/`)
Bento-grid domovská obrazovka: countdown do výročí, quick note, intimacy spark, taptic touch (posílání vibrace partnerovi), quick message, insights (horizontální scroll s "co se blíží" — cyklus, dny od poslední vzpomínky, "před rokem dnes" apod., agregováno z ostatních features bez vlastního Firestore čtení).

**Chat (`/chat`)** — perzistentní obrazovka se sloučenou historií quick-message zpráv a haptic-touch doteků (`ChatHistoryRepository.watchHistory`, dva nezávislé Firestore listenery s `.limit(200)` sloučené do jednoho řazeného streamu), s composerem pro psaní nových zpráv a rychlými předpřipravenými frázemi.

### Timeline / Memories (`features/timeline/`)
Chronologický feed vzpomínek s fotkami/videi, kategoriemi a mapou (`/memory/map`, odemčeno až při 5000 SP nebo premiu). Média se nahrávají do Firebase Storage (`memories/{coupleId}/...`), server-side komprimovaná Cloud Function (`sharp`, max 2048×2048, JPEG kvalita 85). Odemčeno od 25 SP nebo premium. Přidání vzpomínky dává +25 SP (jednou denně) a může zobrazit interstitial reklamu neplatícím uživatelům.

### Tracker / Intimacy (`features/tracker/`)
Log intimity (rating 1-5, tagy, pozice, orgasmus count, protection used) + grafy (`fl_chart`) na `/data`. Přidání logu dává +20 SP, interstitial reklama každý 3. záznam u neplatících.

### Cycle (`features/cycle/`)
Menstruační kalendář s predikcí (fáze menstruace/folikulární/ovulace/luteální), fertilním oknem a "co dnes očekávat" zprávou pro partnera (`CycleCalculator`, čistá doménová logika bez Firestore závislosti). Nastavení (průměrná délka cyklu, poslední perioda, "hideMenstruation" toggle) v `cycle_settings/settings` dokumentu. *(V rámci tohoto sezení sjednoceno — dřív existovaly dvě paralelní sady modelů/providerů pro totéž, teď jen jedna, viz AUDIT.md.)*

### Events (`features/events/`)
Kalendář událostí/výročí, neomezený dopředu (jen historie je časově omezená, `limit=2000`). Přidání události dává +15 SP.

### Notes / Lists (`features/notes/`, `features/lists/`)
Jedna Firestore kolekce `notes` se 4 typy: `shared`, `private`, `bucketList`, `secretGift`. "Bucket List" obrazovka (`/lists`) je jen filtrovaný pohled na `notes` typu `bucketList` — nemá vlastní kolekci. `private`/`secretGift` poznámky smí číst jen autor — vynuceno jak na klientovi, tak (od opravy popsané v `AUDIT.md`) i v `firestore.rules`.

### Blueprints (`features/blueprints/`)
Dlouhý dotazník preferencí páru (~24 sekcí: cestování, dárky, jídlo, rande, hudba, filmy, domácnost, peníze, komunikace, intimita, ...). **Obsah sekcí/otázek je od tohoto sezení načítán z Firestore kolekce `blueprint_sections/{sectionId}`** (dřív byl natvrdo v Dart souboru `blueprint_mock_data.dart`); ten soubor teď slouží jako seed zdroj (`scripts/seed_blueprint_sections.js`) a offline fallback, pokud Firestore ještě není naseedovaná. Odpovědi se ukládají přímo na couple dokument (`couples/{id}.blueprintAnswers.{sectionId}.{userId}`), dokončení sekce dává +100 SP (jednou denně na sekci).

### Gamifikace (`features/gamification/`)
Viz sekce 4 níže.

### Premium (`features/premium/`)
Viz sekce 5 níže.

---

## 4. Gamifikační systém (Soul Points / SP)

Centrální měna appky — `couples/{id}.xp`, sdílená oběma partnery (ne per-user).

- **5 fází** (`boot` 0–1000 → `local` 1000–5000 → `cloud` 5000–20000 → `mainframe` 20000–100000 → `singularity` 100000+), každá s vlastním "OS verze" labelem v UI.
- **~22 milníků** na konkrétních SP prazích, odemykajících odměny (badge, blueprint pack, taptic, map view, premium trial, lifetime license...).
- **Feature gates:** Memories (25 SP), Blueprints (50 SP), Quick Messages (200 SP), Map View (5000 SP) — nebo okamžitě při premiu.
- **Denní questy** (max 1× denně na quest): Blueprint sekce +100 SP, vzpomínka +25 SP, událost +15 SP, intimita +20 SP. Watch rewarded ad +30 SP (bez denního limitu).
- **Atomický grant:** `SubscriptionService.grantQuestXpIfEligible` běží v jedné Firestore transakci (čte `questXpLastGrantedAt` čerstvě ze serveru, kontroluje a zapisuje v jednom kroku) — chrání proti dvojímu přiznání XP, když oba partneři spustí stejný quest současně.

---

## 5. Monetizace

**RevenueCat:** `PurchaseService.purchaseProduct`/`restorePurchases` → po úspěchu `syncCustomerInfoToFirestore` zapíše `subscriptionTier: 'premium'` + `subscriptionExpiry` přímo na **couple** dokument → **oba partneři dostanou premium současně**, i když nákup provedl jen jeden z nich. `isPremiumProvider` je čistě odvozený z `coupleProvider` (žádné vlastní Firestore čtení).

**AdMob:** banner v bottom shellu pro nepremiové uživatele, interstitial po přidání vzpomínky / každém 3. logu intimity/události, rewarded ad pro +30 SP na `/level`. Produkční Android ID natvrdo v kódu (veřejné, ne tajné), test ID automaticky v debug buildu, iOS reklamy zapnuté přes hardcoded flag.

---

## 6. Backend (Firebase)

### Cloud Functions (`functions/index.js`, Node.js, `sharp` pro obrázky)
- `getUserByInviteCode`, `pairWithInviteCode`, `pairWithEmail` — auth + App Check + rate limiting (transakční sliding window přes `security_rate_limits/{uid}_{action}`).
- `onHapticSignalCreated`, `onQuickMessageCreated` — Firestore triggery, posílají FCM push partnerovi.
- `compressImage` — Storage trigger na `profile_pictures/`/`memories/`, resize + reencode, zachovává `firebaseStorageDownloadTokens` aby stávající URL zůstaly platné.

### Firestore struktura
```
users/{userId}
couples/{coupleId}                 — members[2], subscriptionTier/Expiry, xp,
                                      blueprintAnswers, questXpLastGrantedAt, ...
  /memories/{id}  /intimacy_logs/{id}  /notes/{id}  /events/{id}
  /cycle_logs/{id}  /cycle_settings/settings
  /haptic_signals/{id}  /quick_messages/{id}
blueprint_sections/{sectionId}      — sdílený obsah dotazníku (od tohoto sezení)
waitlist/{email}                    — public landing page signup
security_rate_limits/{uid}_{action} — jen server-side, Cloud Functions rate limit
```

### Bezpečnostní pravidla (`firestore.rules`, `storage.rules`)
- `couples/{id}`: číst/psát jen členové; update musí zachovat přesně 2 členy; delete vždy zakázáno.
- Všechny couple subkolekce gatují přístup přes `isCoupleMember()` helper (`get()`/`exists()` na rodičovský couple dokument).
- `notes`: `private`/`secretGift` typy smí číst/listovat jen `authorId`.
- `blueprint_sections`: číst může kdokoliv přihlášený, zápis jen přes Admin SDK (seed script), klienti nemůžou psát.
- Storage `memories/`: gatováno přes **custom Auth claim** `coupleId` (ne cross-service Firestore lookup — v kódu je komentář, že to v projektu spolehlivě selhávalo). Storage `profile_pictures/`: gatováno přes `firestore.get()`/`exists()`.

---

## 7. Typický state-management vzor (příklad)

```dart
// data/xxx_repository.dart
class XxxRepository {
  Stream<List<Xxx>> watchXxx(String coupleId) =>
      _firestore.collection('couples').doc(coupleId).collection('xxx')
        .snapshots().map((s) => s.docs.map(Xxx.fromFirestore).toList());
}

@riverpod
XxxRepository xxxRepository(XxxRepositoryRef ref) => XxxRepository(...);

// presentation/xxx_provider.dart
@riverpod
Stream<List<Xxx>> xxxStream(XxxStreamRef ref) {
  final coupleId = ref.watch(userProvider).valueOrNull?.coupleId;
  if (coupleId == null) return Stream.value([]);
  return ref.watch(xxxRepositoryProvider).watchXxx(coupleId);
}

// screen
final xxxAsync = ref.watch(xxxStreamProvider);
xxxAsync.when(data: (items) => ..., loading: () => ..., error: (e, st) => ...);
```
Čtení jde vždy přes `@riverpod` stream providery; zápisy typicky přes jednorázové imperativní helper funkce (např. `grantQuestXpIfEligible(ref, questId, amount)`) volané z UI event handlerů, ne přes reaktivní graf.

---

## 8. Známé mezery / rozpracované věci

Viz `AUDIT.md` pro plný, průběžně aktualizovaný seznam. Stručně: Groceries, Dark Mode, Achievement/Recap a Time Capsule nejsou implementované (produktové rozhodnutí, ne bug); Google Places API klíč čeká na ruční ověření/rotaci v GCP konzoli.

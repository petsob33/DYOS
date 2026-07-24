# DYOS — Codebase Guide

**Last updated:** 2026-07-21

This is an orientation guide for the DYOS codebase, written for someone who is new to it. It explains the architecture, walks through each feature, and includes a file-by-file map so you can find what you're looking for quickly.

For a deeper narrative description (in Czech) see `docs/DYOS_APP_POPIS.md` — this guide is the English counterpart, reorganized to be easier to navigate while reading code.

---

## 1. What DYOS is

A cross-platform Flutter app: a shared "relationship OS" for couples. Both partners use one shared space to track memories (photos/videos), intimacy logs, menstrual cycle, calendar events, notes, and a shared "gamification" point system (Soul Points / SP) that rewards using the app together. Backend is entirely Firebase; payments via RevenueCat; ads via AdMob.

---

## 2. Tech stack

| Concern | Choice |
|---|---|
| Frontend | Flutter (Dart `^3.10.4`), internal package name `ouros_app` |
| State management | Riverpod with code generation (`@riverpod` annotations, `riverpod_generator`) — no hand-written `Provider`/`StateNotifier` |
| Navigation | `go_router` — one central `GoRouter` provider with reactive redirect logic |
| Models | `freezed` + `json_serializable` — every domain model is an immutable `@freezed` class with `fromJson`/`toJson`; Firestore-backed models add a `fromFirestore(DocumentSnapshot)` factory and a `TimestampConverter` (`Timestamp ↔ DateTime`) |
| Backend | Firebase: Auth, Firestore, Storage, Cloud Functions (Node.js, in `functions/`), Cloud Messaging (FCM), App Check, Crashlytics |
| Payments | RevenueCat (`purchases_flutter`) |
| Ads | Google AdMob (`google_mobile_ads`) — banner / interstitial / rewarded |
| Other notable packages | `table_calendar`, `fl_chart` (charts), `flutter_local_notifications`, `google_maps_flutter` + `geolocator`/`geocoding` (memories map), vendored fork `google_places_autocomplete` (Android only — no iOS implementation because of a deployment-target conflict), `cached_network_image`, `google_fonts` (Inter), `shared_preferences` |

Every generated file (`*.freezed.dart`, `*.g.dart`) is committed — if you change a `@freezed` or `@riverpod` class, you need to re-run the build_runner (see any CI/build script in the repo) to regenerate them.

---

## 3. Architecture: feature-first, 3-layer

```
lib/
  main.dart, app.dart        — bootstrap, root MaterialApp.router
  core/
    router/                  — GoRouter + redirect logic
    services/                — auth, firebase facade, pairing, profile,
                                subscription, notification, ad, storage
    theme/, widgets/, constants/, config/, firebase/
  features/<name>/
    domain/         — Freezed models + pure logic/calculators (no Firestore dependency)
    data/            — XxxRepository (wraps Firestore/Storage/Functions), exposed via @riverpod
    presentation/    — @riverpod stream/future providers + screens/widgets
functions/                    — Cloud Functions (Node.js)
firestore.rules, storage.rules — security rules
```

Every feature (`auth`, `blueprints`, `cycle`, `dashboard`, `events`, `gamification`, `lists`, `notes`, `premium`, `timeline`, `tracker`) follows the same three-layer shape:

- **`domain`** — pure data classes and logic. No Firestore, no I/O. Safe to unit-test without mocks.
- **`data`** — a `XxxRepository` class that talks to Firestore/Storage/Cloud Functions, exposed as a Riverpod provider (`@riverpod XxxRepository xxxRepository(...)`).
- **`presentation`** — `@riverpod` providers that expose streams/futures built on top of the repository, plus the actual screens and widgets that consume them.

**Rule of thumb when reading a feature:** start in `domain` to understand the shape of the data, then `data` to see how it's persisted, then `presentation` to see how it reaches the screen.

---

## 4. Navigation (`lib/core/router/app_router.dart`)

Single `GoRouter` provider (`@riverpod`) with reactive redirect logic driven by auth state, the user's Firestore document, and a short-lived `pairingConfirmedCoupleIdProvider` that bridges the gap between "pairing succeeded server-side" and "the Firestore stream has caught up with the new `coupleId`".

**Redirect flow — auth → pairing → shell:**
1. Not signed in → only `/login` / `/register` are reachable.
2. Signed in but not paired with a partner → forced to `/pairing`.
3. Signed in and paired → the app shell (`/home`).

**Bottom-tab shell** — `RootShell` (`StatefulShellRoute.indexedStack`), 4 tabs: `/home` (Dashboard), `/memory` (Timeline, gated by SP or premium), `/data` (Tracker), `/cycle` (Cycle). Supports swiping between tabs, swipe-up to open the Quick Add sheet, a central "+" FAB, and a banner ad for non-premium users.

**Other routes:** `/login`, `/register`, `/pairing`, `/settings`, `/profile`, `/chat`, `/premium`, `/level`, `/blueprints`, `/blueprint/:sectionId`, `/blueprint/travel-config`, `/edit-profile-picture`, `/intimacy-history`, `/secret-notes`, `/add-memory`, `/memory/edit`, `/memory/map`, `/memory/detail`, `/add-note`, `/events`, `/lists`, `/system-status-demo`, plus a debug-only `/firebase-test`.

---

## 5. Feature-by-feature walkthrough

### Auth + Pairing — `features/auth/`

Email/password and Google Sign-In. Two core models: `UserModel` (uid, email, displayName, inviteCode, coupleId, ...) and `CoupleModel` (members, subscriptionTier/Expiry, xp, blueprintAnswers, completedBlueprintSections, questXpLastGrantedAt). Pairing two accounts runs **server-side, inside a Cloud Function** (`pairWithInviteCode` / `pairWithEmail`) as a single transaction: it creates `couples/{id}`, writes `coupleId` onto both user docs, and sets a **custom Auth claim `coupleId`** (used by Storage rules). Invite codes look like `NAME-1234`.

| File | Role |
|---|---|
| `data/user_data_source.dart` | Raw Firestore reads/writes for `users/{uid}` |
| `data/user_repository.dart` | Riverpod-exposed repository wrapping the data source |
| `domain/user_model.dart` | `UserModel`, `UserStatus` |
| `domain/couple_model.dart` | `CoupleModel`, `CoupleStatus` |
| `presentation/auth_providers.dart` | Auth state, current-user, current-couple providers |
| `presentation/login_screen.dart`, `register_screen.dart` | Sign-in / sign-up UI |
| `presentation/pairing_screen.dart` | Invite-code pairing UI |
| `presentation/profile_screen.dart`, `edit_profile_picture_screen.dart` | Profile management |
| `presentation/firebase_test_screen.dart` | Debug-only diagnostics screen |

Related but not under `features/auth/`: `core/services/pairing_service.dart` (calls the Cloud Functions), `core/services/pairing_exceptions.dart` (typed exceptions), `core/services/auth_service.dart` (Firebase Auth wrapper), `core/services/profile_service.dart`.

### Dashboard / Home — `features/dashboard/`

Bento-grid home screen: anniversary countdown, quick note, intimacy spark, "taptic touch" (send a vibration to your partner), quick message, and an insights horizontal scroll ("what's coming up" — cycle status, days since last memory, "one year ago today", etc. — aggregated from other features without its own Firestore reads).

**Chat (`/chat`)** is a persistent screen merging quick-message history and haptic-touch history (`ChatHistoryRepository.watchHistory` combines two independent Firestore listeners, each `.limit(200)`, into one sorted stream), with a composer for new messages and quick canned phrases.

| File | Role |
|---|---|
| `data/chat_history_repository.dart` | Merges quick-message + haptic-touch streams |
| `domain/chat_event.dart` | `ChatEvent`, `ChatEventType` (discriminates the merged stream) |
| `domain/insight_item.dart` | Shape of one insight card |
| `presentation/haptic_listener_provider.dart` | Listens for incoming haptic touches, triggers device vibration + notification overlay |
| `presentation/insight_provider.dart` | Builds the insights list from other features' data |
| `presentation/chat_history_provider.dart` | Riverpod provider over the chat repository |
| `presentation/screens/home_screen.dart` | The Dashboard tab itself |
| `presentation/screens/chat_screen.dart` | Chat/history screen |
| `presentation/widgets/*` | Individual dashboard cards (countdown, quick note, events, lists, intimacy spark, quick message, taptic touch, days-together, level strip) and the two notification overlays (haptic + quick message) |

### Timeline / Memories — `features/timeline/`

Chronological feed of memories with photos/videos, categories, and a map view (`/memory/map`, unlocked at 5000 SP or with premium). Media uploads to Firebase Storage (`memories/{coupleId}/...`); a server-side Cloud Function compresses them (`sharp`, max 2048×2048, JPEG quality 85). The feed itself unlocks at 25 SP or premium. Adding a memory grants +25 SP (once per day) and may show an interstitial ad to non-paying users.

| File | Role |
|---|---|
| `data/memory_repository.dart` | Firestore CRUD + pagination (`getRecentMemoriesFeed`/`getOlderMemories`) |
| `domain/memory_model.dart` | `Memory`, `MemoryCategory` |
| `presentation/memory_provider.dart` | `TimelineFeedController`/`TimelineFeedState` — paginated feed state |
| `presentation/screens/timeline_screen.dart` | Main feed screen |
| `presentation/screens/add_memory_screen.dart` | Create/edit a memory (photo picker, place picker) |
| `presentation/screens/memory_detail_screen.dart`, `widgets/memory_detail_dialog.dart` | Full-screen memory viewer |
| `presentation/screens/memories_map_screen.dart` | Map view of memories |
| `presentation/widgets/pick_place_screen.dart` | Google Places location picker |

### Tracker / Intimacy — `features/tracker/`

Intimacy logging (rating 1–5, tags, position, orgasm count, protection used) plus charts (`fl_chart`) on `/data`. Adding a log grants +20 SP; an interstitial ad shows every 3rd log for non-paying users.

| File | Role |
|---|---|
| `data/intimacy_repository.dart` | Firestore CRUD + pagination |
| `domain/intimacy_log_model.dart` | `IntimacyLog` |
| `presentation/intimacy_provider.dart` | `IntimacyFeedController`/`IntimacyFeedState` |
| `presentation/data_screen.dart` | The `/data` tab — stats + `fl_chart` frequency chart |
| `presentation/screens/intimacy_history_screen.dart` | Full log history |
| `presentation/widgets/add_intimacy_sheet.dart` | Log-entry bottom sheet |
| `presentation/widgets/intimacy_history_list.dart`, `intimacy_log_detail_sheet.dart` | History list + detail view |

### Cycle — `features/cycle/`

Menstrual calendar with phase prediction (menstruation / follicular / ovulation / luteal), fertile window, and a "what to expect today" message shown to the partner. `CycleCalculator` is pure domain logic with no Firestore dependency — easy to unit test in isolation. Settings (average cycle length, last period start, "hide menstruation" toggle) live in the `cycle_settings/settings` document.

> Note: this feature was recently consolidated — there used to be two parallel sets of models/providers for the same thing (`features/cycle/models/*` vs `features/cycle/presentation/*`); the old `models/` versions are being removed in favor of the `presentation/` ones. See `AUDIT.md` for the history if you see stray deleted files in `git status`.

| File | Role |
|---|---|
| `data/cycle_repository.dart` | Firestore CRUD for logs + settings |
| `domain/cycle_calculator.dart` | `CycleCalculator`, `CyclePhase`, `DailyCycleStatus` — pure prediction logic |
| `domain/cycle_log_model.dart` | `FlowIntensity`, `Mood`, log model |
| `domain/cycle_settings_model.dart` | `CycleSettings` |
| `presentation/cycle_provider.dart` | `CycleProviderNotifier`, `FertileWindow` — the live provider layer |
| `presentation/cycle_tracking_screen.dart` | The `/cycle` tab |
| `presentation/cycle_settings_sheet.dart` | Settings bottom sheet |

### Events — `features/events/`

Calendar of events/anniversaries, unbounded going forward (only history is capped, `limit=2000`). Adding an event grants +15 SP.

| File | Role |
|---|---|
| `data/event_repository.dart` | Firestore CRUD |
| `domain/event_model.dart` | `Event` |
| `presentation/event_provider.dart` | Stream provider |
| `presentation/events_screen.dart` | `/events` screen |
| `presentation/add_event_sheet.dart` | Add/edit bottom sheet |

### Notes / Lists — `features/notes/`, `features/lists/`

One Firestore collection, `notes`, with 4 types: `shared`, `private`, `bucketList`, `secretGift`. The "Bucket List" screen (`/lists`) is just a filtered view over `notes` of type `bucketList` — it has no collection of its own. `private`/`secretGift` notes are readable only by their author — enforced both client-side and (as of a fix documented in `AUDIT.md`) in `firestore.rules`.

| File | Role |
|---|---|
| `notes/data/notes_repository.dart` | Firestore CRUD, filtered by type |
| `notes/domain/note_item.dart` | `NoteItem`, `NoteType` |
| `notes/presentation/notes_provider.dart` | Stream providers per note type |
| `notes/presentation/screens/secret_notes_screen.dart` | `private`/`secretGift` notes UI |
| `notes/presentation/screens/add_note_screen.dart` | Create/edit a note |
| `lists/lists_screen.dart` | `/lists` — bucket-list filtered view |
| `lists/settings_screen.dart` | App settings screen (note: lives under `features/lists/`, not its own feature folder) |

### Blueprints — `features/blueprints/`

A long couple's-preferences questionnaire (~24 sections: travel, gifts, food, dates, music, movies, household, money, communication, intimacy, ...). **Section/question content is now loaded from the Firestore collection `blueprint_sections/{sectionId}`** (it used to be hardcoded in `blueprint_mock_data.dart`); that file is now the seed source (see `scripts/seed_blueprint_sections.js`) and an offline fallback if Firestore hasn't been seeded yet. Answers are written directly onto the couple document (`couples/{id}.blueprintAnswers.{sectionId}.{userId}`); completing a section grants +100 SP (once per day per section).

| File | Role |
|---|---|
| `data/blueprint_repository.dart` | Reads sections from Firestore (`@riverpod`), falls back to mock data |
| `data/blueprint_mock_data.dart` | Hardcoded fallback/seed content (`BlueprintMockData`) |
| `domain/blueprint_section.dart` | `BlueprintSection` |
| `domain/blueprint_question.dart` | `BlueprintQuestion`, `BlueprintQuestionType` |
| `presentation/blueprint_provider.dart` | Stream/future providers over the repository + answer-saving logic |
| `presentation/screens/blueprints_list_screen.dart` | `/blueprints` — list of sections with completion status |
| `presentation/screens/blueprint_detail_screen.dart` | `/blueprint/:sectionId` — question flow for one section |
| `presentation/widgets/blueprint_question_card.dart` | Renders one question (slider input, choice chips, ...) |

Related scripts: `scripts/export_blueprint_sections.dart` (dumps current mock data to JSON), `scripts/seed_blueprint_sections.js` (writes `scripts/blueprint_sections_seed.json` into Firestore via Admin SDK).

### Gamification — `features/gamification/`

See §6 below for the concept; this is the file map.

| File | Role |
|---|---|
| `domain/level_manager.dart` | `LevelManager` — maps SP totals to phases/tiers |
| `domain/level_tier.dart` | `LevelTier` |
| `domain/progression_plan.dart` | `MilestoneType`, `FeatureID`, `RewardKind` — the full milestone/unlock table |
| `presentation/user_stats_provider.dart` | Derives current SP/phase/tier from `coupleProvider` |
| `presentation/screens/level_screen.dart` | `/level` — progression screen, tier stepper, rewarded-ad button |
| `presentation/screens/system_status_demo_screen.dart` | Debug-only demo of the "system status" widget states |
| `presentation/widgets/system_status_card.dart` | Home-screen SP/level summary card |
| `presentation/widgets/level_up_unlock_sheet.dart` | Bottom sheet shown on level-up |

### Premium — `features/premium/`

See §7 below for the concept; this is the file map.

| File | Role |
|---|---|
| `data/purchase_service.dart` | RevenueCat integration — `purchaseProduct`, `restorePurchases`, syncs to Firestore |
| `domain/premium_copy.dart` | Marketing copy/strings for the paywall |
| `presentation/premium_provider.dart` | `isPremiumProvider` and related state, derived from `coupleProvider` |
| `presentation/screens/premium_landing_screen.dart` | `/premium` |
| `presentation/widgets/paywall_modal.dart` | Paywall bottom sheet used elsewhere in the app |

### Core (`lib/core/`) — shared infrastructure, not a "feature"

| File | Role |
|---|---|
| `router/app_router.dart` | `GoRouter` provider, redirect logic, `RootShell` bottom-nav |
| `services/firebase_service.dart` | Thin facade over Firestore/Storage instances |
| `services/auth_service.dart` | Firebase Auth wrapper (sign in/out, current user stream) |
| `services/pairing_service.dart`, `pairing_exceptions.dart` | Calls pairing Cloud Functions, typed exceptions |
| `services/profile_service.dart` | Profile-picture upload etc. |
| `services/subscription_service.dart` | SP/quest granting logic (`grantQuestXpIfEligible`), subscription tier checks |
| `services/notification_service.dart` | FCM setup, local notifications |
| `services/couple_notification_service.dart` | Sends haptic/quick-message signals to your partner |
| `services/ad_service.dart` | AdMob banner/interstitial/rewarded wrappers |
| `services/storage_service.dart` | Firebase Storage upload helper |
| `services/app_logger.dart` | Redacted/safe logging used throughout the app |
| `theme/app_theme.dart` | `AppTheme`, `AppPalette` — the app's design tokens |
| `widgets/bento_card.dart`, `dyos_universal_calendar.dart`, `adaptive_banner_ad.dart` | Shared UI building blocks |
| `constants/app_spacing.dart` | Spacing constants |
| `config/maps_api_config.dart` | Google Maps/Places API key wiring |
| `firebase/firebase_functions_factory.dart` | Cloud Functions client factory |

---

## 6. Gamification system (Soul Points / SP)

The app's central currency — stored on `couples/{id}.xp`, shared by both partners (not per-user).

- **5 phases**: `boot` (0–1000) → `local` (1000–5000) → `cloud` (5000–20000) → `mainframe` (20000–100000) → `singularity` (100000+), each with its own "OS version" label in the UI.
- **~22 milestones** at specific SP thresholds, unlocking rewards (badges, blueprint packs, taptic touch, map view, premium trial, lifetime license, ...).
- **Feature gates:** Memories (25 SP), Blueprints (50 SP), Quick Messages (200 SP), Map View (5000 SP) — or immediately with premium.
- **Daily quests** (max once per day per quest): Blueprint section +100 SP, memory +25 SP, event +15 SP, intimacy log +20 SP. Watching a rewarded ad gives +30 SP with no daily cap.
- **Atomic granting:** `SubscriptionService.grantQuestXpIfEligible` runs inside a single Firestore transaction (reads `questXpLastGrantedAt` fresh from the server, checks and writes in one step) — this protects against double-granting XP when both partners trigger the same quest at nearly the same time.

## 7. Monetization

**RevenueCat:** `PurchaseService.purchaseProduct`/`restorePurchases` → on success, `syncCustomerInfoToFirestore` writes `subscriptionTier: 'premium'` + `subscriptionExpiry` directly onto the **couple** document → **both partners get premium at once**, even though only one of them paid. `isPremiumProvider` is purely derived from `coupleProvider` (no Firestore read of its own).

**AdMob:** banner in the bottom shell for non-premium users, interstitial after adding a memory / every 3rd intimacy log or event, rewarded ad for +30 SP on `/level`. Production Android ad unit IDs are hardcoded in the source (they're public, not secret); test IDs are used automatically in debug builds; iOS ads are enabled via a hardcoded flag.

---

## 8. Backend (Firebase)

### Cloud Functions (`functions/index.js`, Node.js, uses `sharp` for images)

- `getUserByInviteCode`, `pairWithInviteCode`, `pairWithEmail` — auth + App Check + rate limiting (a transactional sliding window stored in `security_rate_limits/{uid}_{action}`).
- `onHapticSignalCreated`, `onQuickMessageCreated` — Firestore triggers that push an FCM notification to the partner.
- `compressImage` — a Storage trigger on `profile_pictures/` and `memories/`, resizes and re-encodes uploads, and preserves the `firebaseStorageDownloadTokens` metadata so existing download URLs stay valid.

### Firestore structure

```
users/{userId}
couples/{coupleId}                 — members[2], subscriptionTier/Expiry, xp,
                                      blueprintAnswers, questXpLastGrantedAt, ...
  /memories/{id}  /intimacy_logs/{id}  /notes/{id}  /events/{id}
  /cycle_logs/{id}  /cycle_settings/settings
  /haptic_signals/{id}  /quick_messages/{id}
blueprint_sections/{sectionId}      — shared questionnaire content
waitlist/{email}                    — public landing-page signup
security_rate_limits/{uid}_{action} — server-side only, Cloud Functions rate limiting
```

### Security rules (`firestore.rules`, `storage.rules`)

- `couples/{id}`: readable/writable only by its 2 members; an update must preserve exactly 2 members; delete is always denied.
- Every couple subcollection gates access through an `isCoupleMember()` helper (`get()`/`exists()` on the parent couple document).
- `notes`: `private`/`secretGift` types can only be read/listed by `authorId`.
- `blueprint_sections`: any signed-in user can read; writes require the Admin SDK (i.e. the seed script) — regular clients cannot write.
- Storage `memories/`: gated via a **custom Auth claim** `coupleId` (not a cross-service Firestore lookup — there's a comment in the code noting that approach was unreliable in this project). Storage `profile_pictures/`: gated via `firestore.get()`/`exists()`.

---

## 9. Typical state-management pattern

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

Reads always go through `@riverpod` stream providers. Writes are typically one-off imperative helper functions (e.g. `grantQuestXpIfEligible(ref, questId, amount)`) called from UI event handlers — not modeled as part of the reactive provider graph.

---

## 10. Quick reference — "where do I look for..."

| I want to change... | Look at |
|---|---|
| Login/pairing flow | `features/auth/presentation/`, `core/services/pairing_service.dart` |
| What happens after sign-in (routing decisions) | `core/router/app_router.dart` |
| Home screen cards | `features/dashboard/presentation/widgets/` |
| How SP/XP is awarded | `core/services/subscription_service.dart` (`grantQuestXpIfEligible`) |
| Level thresholds / unlock rewards | `features/gamification/domain/progression_plan.dart` |
| Cycle phase prediction math | `features/cycle/domain/cycle_calculator.dart` |
| Blueprint question content | Firestore `blueprint_sections/{id}`, fallback in `features/blueprints/data/blueprint_mock_data.dart` |
| Firestore security rules | `firestore.rules` |
| Storage security rules | `storage.rules` |
| Cloud Functions (server-side) | `functions/index.js` |
| Ad placement / IDs | `core/services/ad_service.dart` |
| Paywall / subscription state | `features/premium/` |
| App theme/colors/spacing | `core/theme/app_theme.dart`, `core/constants/app_spacing.dart` |
| App bootstrap (Firebase init, logging, Crashlytics, App Check) | `lib/main.dart` |

---

## 11. Known gaps / in-progress work

See `AUDIT.md` for the full, continuously updated list. In short: Groceries, Dark Mode, Achievement/Recap, and Time Capsule are not implemented (a product decision, not a bug); the Google Places API key is pending manual verification/rotation in the GCP console.

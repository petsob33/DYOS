# Google Play Console — Data Safety Form Answers

Reference answer sheet for the Play Console "App content → Data safety" questionnaire.
Based on the app's actual data flows as of 2026-08-06 (Firebase Auth/Firestore/Storage/Messaging,
RevenueCat, Firebase Crashlytics, Firebase App Check, geolocator/geocoding/Google Places).

**No ad SDK is present** — AdMob was removed from `AndroidManifest.xml` and `Info.plist`.
**No analytics SDK is present** — `firebase_analytics` is not a dependency.
Answer "No, this app doesn't collect any advertising ID" and skip every "Shared with third parties
for advertising/marketing" toggle unless that changes.

## Does your app collect or share any of the required user data types?

**Yes.**

## Security practices

- **Is all user data encrypted in transit?** Yes (Firebase/Google Cloud TLS for all network calls).
- **Do you provide a way for users to request that their data is deleted?** Yes — in-app,
  Settings → Delete Account (`lib/features/lists/settings_screen.dart`, `_handleDeleteAccount`),
  which calls `FirebaseService.deleteAccount()` and removes the account and associated data.
- **Data collected by your app is committed to Play Families Policy?** N/A — target audience is
  18+ adults, not designed for children (see Age rating below).

## Data types

### Personal info

| Data type | Collected | Shared | Purpose | Optional/Required | Ephemeral |
|---|---|---|---|---|---|
| Name | Yes | No | Account management, App functionality | Required (from Google Sign-In or manual entry) | No |
| Email address | Yes | No | Account management, App functionality | Required | No |
| User IDs (Firebase UID, coupleId, inviteCode) | Yes | With partner only (coupleId links two accounts) | App functionality, Account management | Required | No |
| Other info: relationship/pairing data, notes, timeline entries, lists, calendar events | Yes | With paired partner only | App functionality | Required (core feature) | No |

Answer "Shared" as **No** for Play's purposes — sharing is only between the two paired end-users,
which Play's definition of "third-party sharing" does not count (it's the intended service, not a
transfer to an external company). Only mark "Shared" Yes for the true third parties in the
Service providers section below.

### Health and fitness

| Data type | Collected | Shared | Purpose | Optional/Required | Ephemeral |
|---|---|---|---|---|---|
| Health info (menstrual cycle logs: date, flow intensity, mood, notes — `lib/features/cycle/`) | Yes | No (only visible to the user and their paired partner within the app) | App functionality | Optional (user opts into cycle tracking) | No |
| Other health/sexual activity data (intimacy logs: date, rating, tags, positions, duration, protection used, notes — `lib/features/tracker/domain/intimacy_log_model.dart`) | Yes | No (partner-visible only, within app) | App functionality | Optional (user opts into intimacy tracking) | No |

This is why the separate **Health apps declaration** (see
`docs/compliance/health-apps-declaration.md`) is triggered — any collection of menstrual/cycle
data requires it regardless of how the general Data Safety form is answered.

### Financial info

| Data type | Collected | Shared | Purpose | Optional/Required | Ephemeral |
|---|---|---|---|---|---|
| Purchase history (subscription tier/status via RevenueCat) | Yes | Yes — with RevenueCat (service provider) | App functionality | Required for premium features only | No |

No raw payment/card data is collected by the app — billing is handled entirely by Google
Play/App Store and RevenueCat.

### Location

| Data type | Collected | Shared | Purpose | Optional/Required | Ephemeral |
|---|---|---|---|---|---|
| Approximate location | Yes (`ACCESS_COARSE_LOCATION`) | Yes — with Google (Places/Geocoding API) as service provider | App functionality (Memories Map) | Optional (only if user tags a memory with a place) | No |
| Precise location | Yes (`ACCESS_FINE_LOCATION`) | Yes — with Google (Places/Geocoding API) as service provider | App functionality (Memories Map) | Optional | No |

### Photos and videos

| Data type | Collected | Shared | Purpose | Optional/Required | Ephemeral |
|---|---|---|---|---|---|
| Photos | Yes (image_picker → Firebase Storage) | With paired partner only | App functionality (memories, profile picture) | Optional | No |

### App activity

| Data type | Collected | Shared | Purpose | Optional/Required | Ephemeral |
|---|---|---|---|---|---|
| App interactions (gamification XP/levels/unlocks, haptic signals, quick messages/chat) | Yes | With paired partner only (chat/haptics); XP/levels not shared externally | App functionality | Required (core feature) | No |

No "Other user-generated content sent to third parties" — everything generated stays within
Firebase and is visible only to the user and their paired partner.

### App info and performance

| Data type | Collected | Shared | Purpose | Optional/Required | Ephemeral |
|---|---|---|---|---|---|
| Crash logs | Yes (Firebase Crashlytics) | Yes — with Google (service provider) | Analytics (app performance/stability) | Required | Yes (diagnostic, not user-facing) |
| Diagnostics | Yes (Firebase Crashlytics/App Check) | Yes — with Google (service provider) | Analytics, Fraud prevention/security | Required | Yes |

### Device or other IDs

| Data type | Collected | Shared | Purpose | Optional/Required | Ephemeral |
|---|---|---|---|---|---|
| Device or other IDs (FCM push token, device_info_plus, App Check device attestation) | Yes | Yes — with Google (service provider) | App functionality (push notifications), Fraud prevention/security | Required | No |

**Advertising ID: not collected.**

## Service providers disclosed as recipients of shared data

- Google / Firebase (Auth, Firestore, Storage, Cloud Messaging, Crashlytics, App Check, Cloud
  Functions, Maps/Places/Geocoding APIs)
- RevenueCat (subscription/purchase management)

## Age rating / target audience

18+ / mature, adults only — matches the existing Privacy Policy's "not for anyone under 18"
language and the intimacy-tracking content. Do not select "Designed for Families" or a children's
target age group.

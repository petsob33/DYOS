# DYOS

Relationship OS for couples — shared timeline, cycle tracking, guided relationship "blueprints", and gamified progress for two paired partners. Flutter app backed by Firebase.

## Tech stack

- Flutter · Dart · Riverpod (with code generation) · go_router
- Firebase: Firestore, Auth, Storage, Cloud Functions, Messaging, Crashlytics, App Check
- RevenueCat (in-app purchases) · Google Maps/Places · Codemagic CI

## Features

- Couple pairing with shared Firestore data, scoped by couple membership in the security rules
- Shared timeline, events, and lists between partners
- Cycle tracking, intimacy tracking, and guided relationship "blueprint" question sets
- Gamification layer (levels, progression, unlocks) and a RevenueCat paywall for premium features
- Push/local notifications and cached network images

## Technical notes

- Firestore and Storage rules gate every collection behind `isCoupleMember()` / `isPartnerInSameCouple()` checks derived from the authenticated user's paired-couple document, so one couple can never read or write another couple's data.
- The Google Places autocomplete plugin forces a newer iOS deployment target upstream than the app targets. Rather than bump the whole app's target, the plugin is vendored as a local path package (`packages/google_places_autocomplete`) with the iOS implementation stripped, so Android keeps autocomplete and iOS just degrades gracefully instead of failing to build.
- The Google Maps API key isn't hardcoded per platform: Android reads it from the merged manifest, iOS from an xcconfig file generated at CI build time from a secure Codemagic variable (`ios/ci_scripts/write_secrets.sh`), and web re-reads the same referrer-restricted key for direct Geocoding REST calls.
- 24 test files cover domain logic and repositories, using `fake_cloud_firestore` and `firebase_auth_mocks` to test Firestore-backed code without a real backend.

## Running locally

```bash
flutter pub get
cp ios/Runner/Secrets.xcconfig.example ios/Runner/Secrets.xcconfig  # fill in GOOGLE_PLACES_API_KEY
flutter run
```

Firebase is already configured via the committed `google-services.json` / `firebase_options.dart` (project `dyos-520c2`) — no separate Firebase setup needed. After changing any `@freezed`/`@riverpod` model, regenerate with `dart run build_runner build --delete-conflicting-outputs`.

<!-- TODO: screenshot -->

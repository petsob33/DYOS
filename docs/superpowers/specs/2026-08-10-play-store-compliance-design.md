# Play Store compliance punch list

## Goal

Close the gaps needed to submit DYOS to Google Play: a working account-deletion
path that actually frees storage cost, no stray UI overlay on the web build,
and a content-rating answer sheet. Privacy Policy URL and `targetSdk` are
already satisfied (see Findings below) — no action needed there.

## Findings (verification only, no changes)

- **Privacy Policy URL**: `web/privacy-policy.html` already exists and is
  linked from `web/index.html`'s nav and `web/account-deletion.html`.
- **`targetSdk`**: `android/app/build.gradle.kts:52` uses
  `flutter.targetSdkVersion`, which the installed Flutter SDK (3.38.7)
  defaults to **36** (`FlutterExtension.kt`). Already correct.

## Problem 1: account deletion doesn't free Storage

`ProfileService.deleteAccount()` (`lib/core/services/profile_service.dart`)
deletes Firestore docs (couple doc, memories, notes, cycle logs, intimacy
logs, etc.) and the Auth user, but never touches Firebase Storage. Uploaded
files live at:

- `memories/{coupleId}/{timestamp}_{index}.{ext}` (`memory_repository.dart`)
- `profile_pictures/{userId}/{timestamp}.jpg` (`storage_service.dart`)

Every account deletion leaves these orphaned in Storage — permanent,
compounding hosting cost.

### Design

Two Firestore `onDelete` triggers in `functions/index.js`, using the
project's existing `firebase-functions/v1` style (matches
`onHapticSignalCreated`, `compressImage`):

```js
exports.onCoupleDeleted = functions.firestore
  .document("couples/{coupleId}")
  .onDelete(async (snap, context) => {
    await admin.storage().bucket().deleteFiles({
      prefix: `memories/${context.params.coupleId}/`,
    });
  });

exports.onUserDeleted = functions.firestore
  .document("users/{userId}")
  .onDelete(async (snap, context) => {
    await admin.storage().bucket().deleteFiles({
      prefix: `profile_pictures/${context.params.userId}/`,
    });
  });
```

- Trailing slash on both prefixes is deliberate: a bare-string prefix match
  without it would also match `memories/{coupleId}999/...`.
- Chosen over a client-side `listAll()`+`delete()` loop in
  `profile_service.dart` because it runs server-side with admin rights —
  it still completes if the device loses network or the app is killed right
  after the Firestore deletes commit, and needs no extra client Storage
  permissions.
- No client-side change needed: `deleteAccount()` already unconditionally
  deletes both `couples/{coupleId}` and `users/{uid}` in every code path
  (paired or solo), so both triggers reliably fire on every account
  deletion.

## Problem 2: persistent nav bar overlays the running web app

`web/index.html` is the actual Flutter web app shell (has
`<base href="$FLUTTER_BASE_HREF">` and loads `flutter_bootstrap.js`), not a
separate marketing page. It also has a `position: fixed; top:0; z-index:9999`
`.site-nav` bar permanently overlaid on the running app, linking to Privacy
Policy / Terms / Delete Account. The in-app Settings screen already exposes
Delete Account, so this duplicate bar sitting on top of the live app is
unwanted chrome.

### Design

Delete the `<nav class="site-nav">` block and its `.site-nav*` CSS rules from
`web/index.html`. `privacy-policy.html`, `terms-of-service.html`, and
`account-deletion.html` are separate static pages with their own headers
(see `account-deletion.html`'s `.nav`) — those are unaffected and remain the
URLs given to Play Console / linked from in-app Settings.

## Problem 3: content rating questionnaire

No reference doc exists yet for Play Console's content-rating (IARC)
questionnaire, unlike Data Safety and the health-apps declaration.

### Design

Add `docs/compliance/play-content-rating.md`, same reference-sheet style as
`play-data-safety.md` / `health-apps-declaration.md` / `apple-app-privacy.md`:
answers derived from the app's actual content — intimacy/sexual-activity
tracking pushes this toward the "Mature 17+" / PEGI 18-equivalent bracket;
no violence, gambling, drugs, or user-generated content visible beyond the
paired partner (no public UGC surface).

## Non-goals / follow-up flagged

`docs/compliance/play-data-safety.md` and `apple-app-privacy.md` currently
describe RevenueCat as the purchase-data processor (see
`2026-08-10-remove-paywall-revenuecat-design.md`). Once that spec and the
"support the dev" Play Billing purchase ship, the Financial Info sections of
both docs go stale and need a follow-up edit. Not in scope here.

## Testing

- Deploy `functions/` to a test project (or Firebase emulator) and verify:
  deleting a `couples/{id}` doc removes all objects under
  `memories/{id}/`; deleting a `users/{id}` doc removes all objects under
  `profile_pictures/{id}/`; unrelated prefixes are untouched.
- `flutter build web` and open the built app — confirm no fixed nav bar
  renders above the app, and Settings → Delete Account still works.
- Manually re-check the three static web pages still load correctly at
  their own paths with their own headers intact.

# Play Store Compliance Punch List Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Close the three gaps identified in `docs/superpowers/specs/2026-08-10-play-store-compliance-design.md` that block promoting DYOS to Google Play production: account deletion doesn't free Storage, a stray nav bar overlays the running web app, and there's no content-rating reference doc.

**Architecture:** Two new Firestore `onDelete` Cloud Functions triggers (matching the existing `firebase-functions/v1` style used by `onHapticSignalCreated`) delete orphaned Storage objects when a couple or user document is deleted. A dead `<nav>` block and its CSS are removed from the Flutter web build shell. A new markdown reference doc answers Play Console's content-rating questionnaire, following the existing `docs/compliance/*.md` reference-sheet style.

**Tech Stack:** Node.js Cloud Functions (`firebase-functions/v1`, `firebase-admin`), Firebase Local Emulator Suite (Firestore + Storage + Functions) for integration testing, plain HTML/CSS for the web shell.

## Global Constraints

- Firestore triggers use `firebase-functions/v1` style (`functions.firestore.document(...).onDelete(...)`), matching every existing trigger in `functions/index.js` — do not introduce the v2 SDK.
- Storage prefix matches in `deleteFiles({ prefix })` must include a trailing slash so `memories/{coupleId}/` never accidentally matches `memories/{coupleId}999/...`.
- `privacy-policy.html`, `terms-of-service.html`, and `account-deletion.html` are separate static pages with their own headers — they are out of scope and must keep working unmodified.
- Content-rating doc must follow the exact reference-sheet style of `docs/compliance/play-data-safety.md` (heading + short framing paragraph + plain-language answers, no filler).

---

### Task 1: Storage-cleanup triggers on account deletion

**Files:**
- Modify: `functions/index.js` (append after the `compressImage` export, currently ending at line 509)
- Modify: `firebase.json` (add `storage` and `functions` emulator ports alongside the existing `firestore` emulator so the test in this task can run locally against real Storage/Firestore trigger wiring)
- Test: `functions/account_deletion_storage.emulator.test.js` (new)

**Interfaces:**
- Consumes: `admin` (from `firebase-admin`, already initialized via `admin.initializeApp()` at the top of `functions/index.js`), `functions` (from `firebase-functions/v1`, already imported)
- Produces: `exports.onCoupleDeleted`, `exports.onUserDeleted` — no other task depends on these names, but keep them exact since they're referenced in the Play Console Data Safety doc follow-up.

This task's test runs against the Firebase Local Emulator Suite, not `node --test` alone, because the behavior under test is the Firestore-delete-triggers-Storage-cleanup wiring itself — mocking `admin.storage()` would test nothing real. `firebase-tools` is already installed globally (verified: `firebase-tools@15.2.1`).

- [ ] **Step 1: Add emulator ports to `firebase.json`**

Open `firebase.json`. The current `emulators` block is:

```json
  "emulators": {
    "firestore": {
      "port": 8080
    }
  },
```

Replace it with:

```json
  "emulators": {
    "firestore": {
      "port": 8080
    },
    "storage": {
      "port": 9199
    },
    "functions": {
      "port": 5001
    }
  },
```

This adds no new top-level `storage`/`functions` config sections (those already exist above for rules/source) — it only opens emulator ports for the two services the test needs alongside the existing Firestore emulator.

- [ ] **Step 2: Write the failing integration test**

Create `functions/account_deletion_storage.emulator.test.js`:

```js
const test = require("node:test");
const assert = require("node:assert/strict");
const admin = require("firebase-admin");

if (!admin.apps.length) {
  admin.initializeApp({ projectId: "dyos-520c2" });
}

const db = admin.firestore();
const bucket = admin.storage().bucket();

async function listFileNames(prefix) {
  const [files] = await bucket.getFiles({ prefix });
  return files.map((f) => f.name).sort();
}

async function waitUntil(checkFn, { timeoutMs = 5000, intervalMs = 250 } = {}) {
  const deadline = Date.now() + timeoutMs;
  while (Date.now() < deadline) {
    if (await checkFn()) return;
    await new Promise((resolve) => setTimeout(resolve, intervalMs));
  }
  throw new Error("waitUntil timed out");
}

test("deleting a couple doc removes its memories files", async () => {
  const coupleId = `test-couple-${Date.now()}`;
  const filePath = `memories/${coupleId}/1_0.jpg`;

  await bucket.file(filePath).save(Buffer.from("fake-image"), {
    contentType: "image/jpeg",
  });
  assert.deepEqual(await listFileNames(`memories/${coupleId}/`), [filePath]);

  await db.collection("couples").doc(coupleId).set({ createdAt: Date.now() });
  await db.collection("couples").doc(coupleId).delete();

  await waitUntil(async () => (await listFileNames(`memories/${coupleId}/`)).length === 0);
});

test("deleting a user doc removes its profile picture files", async () => {
  const userId = `test-user-${Date.now()}`;
  const filePath = `profile_pictures/${userId}/1.jpg`;

  await bucket.file(filePath).save(Buffer.from("fake-image"), {
    contentType: "image/jpeg",
  });
  assert.deepEqual(await listFileNames(`profile_pictures/${userId}/`), [filePath]);

  await db.collection("users").doc(userId).set({ createdAt: Date.now() });
  await db.collection("users").doc(userId).delete();

  await waitUntil(async () => (await listFileNames(`profile_pictures/${userId}/`)).length === 0);
});

test("deleting a couple doc does not remove files under a similarly-prefixed couple id", async () => {
  const coupleId = `test-couple-prefix-${Date.now()}`;
  const otherCoupleId = `${coupleId}999`;
  const filePath = `memories/${otherCoupleId}/1_0.jpg`;

  await bucket.file(filePath).save(Buffer.from("fake-image"), {
    contentType: "image/jpeg",
  });

  await db.collection("couples").doc(coupleId).set({ createdAt: Date.now() });
  await db.collection("couples").doc(coupleId).delete();

  // Give the trigger a chance to run (and wrongly delete) before asserting it didn't.
  await new Promise((resolve) => setTimeout(resolve, 2000));
  assert.deepEqual(await listFileNames(`memories/${otherCoupleId}/`), [filePath]);

  await bucket.file(filePath).delete();
});
```

- [ ] **Step 3: Run the test to verify it fails**

From the repo root:

```bash
firebase emulators:exec --project dyos-520c2 --only firestore,storage,functions \
  "node --test functions/account_deletion_storage.emulator.test.js"
```

Expected: FAIL — the first two tests time out in `waitUntil` because `onCoupleDeleted`/`onUserDeleted` don't exist yet, so nothing deletes the Storage files.

- [ ] **Step 4: Implement the triggers**

Append to the end of `functions/index.js` (after the `compressImage` export, which currently ends at line 509):

```js

/** On couple deletion – free the couple's memories from Storage. */
exports.onCoupleDeleted = functions.firestore
  .document("couples/{coupleId}")
  .onDelete(async (snap, context) => {
    await admin.storage().bucket().deleteFiles({
      prefix: `memories/${context.params.coupleId}/`,
    });
  });

/** On user deletion – free the user's profile pictures from Storage. */
exports.onUserDeleted = functions.firestore
  .document("users/{userId}")
  .onDelete(async (snap, context) => {
    await admin.storage().bucket().deleteFiles({
      prefix: `profile_pictures/${context.params.userId}/`,
    });
  });
```

- [ ] **Step 5: Run the test to verify it passes**

```bash
firebase emulators:exec --project dyos-520c2 --only firestore,storage,functions \
  "node --test functions/account_deletion_storage.emulator.test.js"
```

Expected: PASS — all 3 tests green.

- [ ] **Step 6: Commit**

```bash
git add functions/index.js firebase.json functions/account_deletion_storage.emulator.test.js
git commit -m "feat(functions): free Storage files when a couple or user is deleted"
```

---

### Task 2: Remove the overlay nav bar from the web app shell

**Files:**
- Modify: `web/index.html:60-93` (CSS rules), `web/index.html:97-102` (markup)

**Interfaces:**
- Consumes: nothing from Task 1.
- Produces: nothing consumed by later tasks.

There's no existing automated test harness for `web/index.html` (it's the Flutter web build shell, not app code) — verification here is a manual visual check via `flutter build web`, matching the design doc's own testing note.

- [ ] **Step 1: Remove the `.site-nav*` CSS rules**

In `web/index.html`, delete this block (currently lines 60–92, everything between the `body { ... }` rule and the closing `</style>` tag):

```css
    .site-nav {
      position: fixed;
      top: 0;
      left: 0;
      right: 0;
      z-index: 9999;
      height: 56px;
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 0 16px;
      background: rgba(255, 255, 255, 0.9);
      backdrop-filter: blur(10px);
      border-bottom: 1px solid rgba(142, 142, 147, 0.2);
      box-sizing: border-box;
    }

    .site-nav__brand {
      font-weight: 700;
      color: var(--dyos-text);
      text-decoration: none;
    }

    .site-nav__link {
      color: var(--dyos-primary);
      text-decoration: none;
      font-weight: 600;
      font-size: 14px;
      padding: 8px 12px;
      border-radius: 999px;
      background: var(--dyos-card);
      box-shadow: 0 2px 12px rgba(0, 0, 0, 0.06);
    }
```

So the `<style>` block goes directly from the `body { ... }` rule's closing brace to `</style>`.

- [ ] **Step 2: Remove the `<nav>` markup**

In the same file, delete this block (currently lines 97–102, right after `<body>`):

```html
  <nav class="site-nav" aria-label="Main navigation">
    <a class="site-nav__brand" href="/">DYOS</a>
    <a class="site-nav__link" href="/privacy-policy.html">Privacy Policy</a>
    <a class="site-nav__link" href="/terms-of-service.html">Terms of Service</a>
    <a class="site-nav__link" href="/account-deletion.html">Delete Account</a>
  </nav>
```

So `<body>` is immediately followed by `<script src="flutter_bootstrap.js" async></script>`.

- [ ] **Step 3: Build and manually verify**

```bash
flutter build web
```

Open `build/web/index.html` in a browser (e.g. `python3 -m http.server 8000 -d build/web` then visit `http://localhost:8000`). Expected: no fixed bar at the top of the screen; the Flutter app renders full-screen. Then separately open `web/privacy-policy.html`, `web/terms-of-service.html`, and `web/account-deletion.html` directly and confirm they still render with their own headers (unaffected by this change).

- [ ] **Step 4: Commit**

```bash
git add web/index.html
git commit -m "fix(web): remove overlay nav bar from the running app shell"
```

---

### Task 3: Content-rating reference doc

**Files:**
- Create: `docs/compliance/play-content-rating.md`

**Interfaces:**
- Consumes: nothing from Tasks 1–2.
- Produces: nothing consumed by later tasks (it's a reference doc used manually when filling out Play Console's IARC questionnaire).

This is a documentation-only task — no test to run, matching the sibling docs (`play-data-safety.md`, `health-apps-declaration.md`, `apple-app-privacy.md`) which are themselves unTested reference sheets.

- [ ] **Step 1: Create the doc**

Create `docs/compliance/play-content-rating.md`:

```markdown
# Google Play Console — Content Rating (IARC) Questionnaire Answers

Reference answer sheet for the Play Console "App content → Content ratings" IARC questionnaire.
Based on the app's actual feature set as of 2026-08-29 (timeline, memories, quests, cycle
tracking, intimacy/sexual-activity tracking — see `docs/compliance/play-data-safety.md` for the
full data inventory).

## Category

**Social networking / Lifestyle** — a private, paired relationship app (one user + one partner),
not a public social network.

## Violence

No. The app contains no violent content, imagery, or themes of any kind.

## Sexual content

**Yes — the app allows users to log details of their own sexual activity** (intimacy tracking:
date, rating, tags, positions, duration, protection used, notes — see
`lib/features/tracker/domain/intimacy_log_model.dart`). This is private, user-entered data visible
only to the user and their paired partner — there is no public feed, no images of sexual activity,
and no erotica/pornographic content shipped with or displayed by the app. Answer the "references
to sex" / "sexual content" questions to reflect self-reported intimacy logging, which pushes the
rating toward **Mature 17+ (ESRB)** / **PEGI 18** / **USK 18**-equivalent brackets depending on
region.

## Profanity / crude humor

No. The app does not include profanity, and any user-entered free text (notes, chat messages) is
private between the paired partners, not moderated public content — do not answer this section as
if it were user-generated content visible to third parties.

## Controlled substances

No references to alcohol, tobacco, or illegal drugs.

## Gambling

No simulated or real-money gambling of any kind.

## User-generated content shared publicly

**No.** All user-generated content (notes, timeline entries, chat messages, memories, intimacy
logs) is visible only to the two paired partners — there is no public UGC surface, no comments
section, and no way for content to reach anyone outside the pair. Answer "No" to any "does your
app contain user-generated content" question that specifically asks about content shared with
other users or the public; the paired-partner sharing model does not meet that bar (same reasoning
as the "Shared" column note in `docs/compliance/play-data-safety.md`).

## Target age group / audience

**18+ / mature, adults only** — matches `play-data-safety.md`'s age rating and the Privacy
Policy's "not for anyone under 18" language. Do not select "Designed for Families" or any
children's target age group; do not enroll in the Play Families Policy program.

## Location sharing

Location is used only for optionally tagging a memory with a place (Memories Map); it is not
shared with other users beyond the paired partner and is not broadcast publicly. Answer location
questions consistently with the "Location" section of `play-data-safety.md`.
```

- [ ] **Step 2: Commit**

```bash
git add docs/compliance/play-content-rating.md
git commit -m "docs: add Play Console content-rating reference answers"
```

## Self-Review Notes

- **Spec coverage:** Problem 1 (Storage cleanup) → Task 1. Problem 2 (nav overlay) → Task 2. Problem 3 (content rating doc) → Task 3. The two "already satisfied" findings (Privacy Policy URL, targetSdk) and the RevenueCat follow-up note are explicitly out of scope per the design doc and are not tasks here.
- **Placeholder scan:** no TBD/TODO markers; every step has literal code or commands.
- **Type/name consistency:** `onCoupleDeleted`/`onUserDeleted` names and the `memories/`/`profile_pictures/` prefixes are used identically in the design doc, Task 1's implementation, and Task 1's test.

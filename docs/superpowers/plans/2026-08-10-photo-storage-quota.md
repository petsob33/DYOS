# Per-Couple Photo Storage Quota Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Enforce a hard 150MB-per-couple ceiling on `memories/{coupleId}/` Storage usage, tracked accurately in Firestore and enforced server-side in Storage Rules.

**Architecture:** A Firestore doc `couples/{coupleId}/usage/current.bytesUsed` is kept in sync by two new Cloud Functions Storage triggers (increment on upload-settle, decrement on delete). `storage.rules` reads that field via `firestore.get()` to deny uploads once a couple is at/over quota, and splits the existing per-file size cap by content type (images 2MB, videos keep 10MB). A one-time script backfills the counter for couples with pre-existing media.

**Tech Stack:** Firebase Cloud Functions v1 (Node, `functions/index.js`), Firestore, Firebase Storage Rules, `@firebase/rules-unit-testing` (already used for `firestore.rules` in `test/security/rules/`), Flutter/Dart (`memory_repository.dart`), `node:test` for Functions unit tests, `flutter_test`/`mockito` for Dart tests.

## Global Constraints

- Quota ceiling: `150 * 1000 * 1000` bytes (150,000,000 — decimal MB, per the original ask), not binary MiB.
- Per-file cap: images `2 * 1024 * 1024` bytes (2MB); videos keep the existing `10 * 1024 * 1024` bytes (10MB) — unchanged from today.
- Quota scope: `memories/{coupleId}/` only. `profile_pictures/` is untouched.
- No changes to `flutter_image_compress` / client compression — out of scope per the approved spec (`docs/superpowers/specs/2026-08-10-photo-storage-quota-design.md`).
- The existing `compressImage` Cloud Function (`functions/index.js:427`) is unchanged; new triggers must account for its double-`onFinalize` behavior rather than modify it.
- Rollout order matters: deploy Functions → run backfill → deploy `storage.rules` (never the reverse).

---

### Task 1: Storage-usage pure helper functions

**Files:**
- Create: `functions/storage_usage_helpers.js`
- Create: `functions/storage_usage_helpers.test.js`

**Interfaces:**
- Produces: `parseCoupleIdFromMemoryPath(objectName: string|undefined): string|null`, `shouldCountFinalizeEvent({ contentType: string|undefined, alreadyCompressed: boolean }): boolean`, `clampNonNegative(value: number): number` — all consumed by Task 2's Cloud Functions triggers.

- [ ] **Step 1: Write the failing test file**

Create `functions/storage_usage_helpers.test.js`:

```js
const test = require("node:test");
const assert = require("node:assert/strict");

const {
  parseCoupleIdFromMemoryPath,
  shouldCountFinalizeEvent,
  clampNonNegative,
} = require("./storage_usage_helpers");

test("parseCoupleIdFromMemoryPath extracts the coupleId segment", () => {
  assert.equal(
    parseCoupleIdFromMemoryPath("memories/couple_123/1700000000000_0.jpg"),
    "couple_123"
  );
});

test("parseCoupleIdFromMemoryPath returns null outside memories/", () => {
  assert.equal(parseCoupleIdFromMemoryPath("profile_pictures/user_1/1.jpg"), null);
  assert.equal(parseCoupleIdFromMemoryPath(""), null);
  assert.equal(parseCoupleIdFromMemoryPath(undefined), null);
});

test("shouldCountFinalizeEvent skips the raw pre-compression image upload", () => {
  assert.equal(
    shouldCountFinalizeEvent({ contentType: "image/jpeg", alreadyCompressed: false }),
    false
  );
});

test("shouldCountFinalizeEvent counts the compressed-echo image event", () => {
  assert.equal(
    shouldCountFinalizeEvent({ contentType: "image/jpeg", alreadyCompressed: true }),
    true
  );
});

test("shouldCountFinalizeEvent counts videos immediately (never recompressed)", () => {
  assert.equal(
    shouldCountFinalizeEvent({ contentType: "video/mp4", alreadyCompressed: false }),
    true
  );
});

test("clampNonNegative floors at zero", () => {
  assert.equal(clampNonNegative(-5), 0);
  assert.equal(clampNonNegative(0), 0);
  assert.equal(clampNonNegative(42), 42);
});
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `cd functions && node --test storage_usage_helpers.test.js`
Expected: FAIL — `Cannot find module './storage_usage_helpers'`.

- [ ] **Step 3: Write the minimal implementation**

Create `functions/storage_usage_helpers.js`:

```js
const MEMORY_PATH_PREFIX = "memories/";

/**
 * Extracts the coupleId from a Storage object path of the form
 * "memories/{coupleId}/{fileName}". Returns null for any path outside
 * that prefix.
 */
function parseCoupleIdFromMemoryPath(objectName) {
  if (typeof objectName !== "string" || !objectName.startsWith(MEMORY_PATH_PREFIX)) {
    return null;
  }
  const segments = objectName.split("/");
  return segments[1] || null;
}

/**
 * Decides whether a Storage onFinalize event for a file under memories/
 * should be counted toward the couple's usage total.
 *
 * compressImage re-encodes every image in place, producing a second
 * onFinalize event for the same path (tagged metadata.compressed === "true").
 * Counting both would double-count every photo, so the raw pre-compression
 * event is skipped; the compressed-echo event (or a video, which
 * compressImage never touches and so only ever fires once) is counted.
 */
function shouldCountFinalizeEvent({ contentType, alreadyCompressed }) {
  const isImage = typeof contentType === "string" && contentType.startsWith("image/");
  if (isImage && !alreadyCompressed) {
    return false;
  }
  return true;
}

function clampNonNegative(value) {
  return value < 0 ? 0 : value;
}

module.exports = {
  parseCoupleIdFromMemoryPath,
  shouldCountFinalizeEvent,
  clampNonNegative,
};
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `cd functions && node --test storage_usage_helpers.test.js`
Expected: PASS, all 6 tests green.

- [ ] **Step 5: Commit**

```bash
git add functions/storage_usage_helpers.js functions/storage_usage_helpers.test.js
git commit -m "feat(functions): add pure helpers for memory storage usage tracking"
```

---

### Task 2: Wire usage tracking into Cloud Functions

**Files:**
- Modify: `functions/index.js` (add require near line 9; modify `setCoupleClaims` at lines 358-363; add two new exports after `compressImage`, currently ending at line 509)

**Interfaces:**
- Consumes: `parseCoupleIdFromMemoryPath`, `shouldCountFinalizeEvent`, `clampNonNegative` from Task 1.
- Produces: `couples/{coupleId}/usage/current.bytesUsed` Firestore field, kept live by `exports.trackMemoryUsageOnFinalize` / `exports.trackMemoryUsageOnDelete`, seeded to `0` at couple-creation time. Task 4 (Storage Rules) and Task 3 (backfill) both depend on this doc shape.

- [ ] **Step 1: Add the require**

In `functions/index.js`, after the existing `security_helpers` require block (ends at line 9 with `} = require("./security_helpers");`), add:

```js
const {
  parseCoupleIdFromMemoryPath,
  shouldCountFinalizeEvent,
  clampNonNegative,
} = require("./storage_usage_helpers");
```

- [ ] **Step 2: Seed the usage doc when a couple is created**

Replace the current `setCoupleClaims` function (lines 358-363):

```js
async function setCoupleClaims(uid1, uid2, coupleId) {
  await Promise.all([
    admin.auth().setCustomUserClaims(uid1, { coupleId }),
    admin.auth().setCustomUserClaims(uid2, { coupleId }),
  ]);
}
```

with:

```js
async function setCoupleClaims(uid1, uid2, coupleId) {
  await Promise.all([
    admin.auth().setCustomUserClaims(uid1, { coupleId }),
    admin.auth().setCustomUserClaims(uid2, { coupleId }),
    // Storage Rules check bytesUsed via firestore.get() before this doc has
    // ever been written by the triggers below - it must exist from the
    // couple's very first moment, or their first upload would be denied.
    db
      .collection("couples")
      .doc(coupleId)
      .collection("usage")
      .doc("current")
      .set({ bytesUsed: 0 }, { merge: true }),
  ]);
}
```

- [ ] **Step 3: Add the two new triggers**

After the existing `compressImage` export (ends at line 509 with the closing `});`), add:

```js
/**
 * Keep couples/{coupleId}/usage/current.bytesUsed in sync with Storage
 * usage under memories/. See shouldCountFinalizeEvent for why the raw
 * pre-compression image upload is skipped in favor of the compressed
 * echo event.
 */
exports.trackMemoryUsageOnFinalize = functions.storage.object().onFinalize(async (object) => {
  const coupleId = parseCoupleIdFromMemoryPath(object.name);
  if (!coupleId) return null;

  const alreadyCompressed = Boolean(
    object.metadata && object.metadata.compressed === "true"
  );
  if (!shouldCountFinalizeEvent({ contentType: object.contentType, alreadyCompressed })) {
    return null;
  }

  const size = Number(object.size) || 0;
  await db
    .collection("couples")
    .doc(coupleId)
    .collection("usage")
    .doc("current")
    .set({ bytesUsed: admin.firestore.FieldValue.increment(size) }, { merge: true });
  return null;
});

/** Decrement bytesUsed when a memory file is deleted, floored at zero. */
exports.trackMemoryUsageOnDelete = functions.storage.object().onDelete(async (object) => {
  const coupleId = parseCoupleIdFromMemoryPath(object.name);
  if (!coupleId) return null;

  const size = Number(object.size) || 0;
  const usageRef = db.collection("couples").doc(coupleId).collection("usage").doc("current");

  await db.runTransaction(async (tx) => {
    const snap = await tx.get(usageRef);
    const current = (snap.exists && snap.data().bytesUsed) || 0;
    tx.set(usageRef, { bytesUsed: clampNonNegative(current - size) }, { merge: true });
  });
  return null;
});
```

- [ ] **Step 4: Run the existing Functions test suite to confirm nothing broke**

Run: `cd functions && npm test`
Expected: PASS (existing `security_helpers.test.js` tests unaffected; this task adds no new unit tests of its own since it's wiring, not new pure logic — Task 1 already covers the decision logic these triggers call, and Task 6 covers end-to-end verification).

- [ ] **Step 5: Commit**

```bash
git add functions/index.js
git commit -m "feat(functions): track per-couple memory storage usage in Firestore"
```

---

### Task 3: Backfill script for existing couples

**Files:**
- Create: `functions/scripts/backfill-usage.js`

**Interfaces:**
- Consumes: none from prior tasks (standalone script using `firebase-admin` directly).
- Produces: seeds `couples/{coupleId}/usage/current.bytesUsed` for every existing couple — a prerequisite for Task 4's Storage Rules going live safely (see Rollout order in Task 6).

- [ ] **Step 1: Write the script**

Create `functions/scripts/backfill-usage.js`:

```js
// One-off script: seeds couples/{coupleId}/usage/current.bytesUsed from the
// real size of existing objects under memories/{coupleId}/, for couples that
// had media uploaded before usage tracking existed.
//
// Run once, against production, BEFORE deploying the storage.rules quota
// check (see the Rollout section of the photo-storage-quota plan) — the
// rule denies uploads once bytesUsed >= 150MB, and without this backfill
// existing heavy users would start from a false 0 and be measured
// incorrectly until their next upload/delete nudges the counter.
//
// Usage: GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json \
//   node functions/scripts/backfill-usage.js

const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();
const bucket = admin.storage().bucket();

async function sumCoupleUsage(coupleId) {
  const [files] = await bucket.getFiles({ prefix: `memories/${coupleId}/` });
  return files.reduce((total, file) => {
    const size = Number(file.metadata.size) || 0;
    return total + size;
  }, 0);
}

async function backfillUsage() {
  const couplesSnap = await db.collection("couples").get();
  console.log(`Found ${couplesSnap.size} couples.`);

  for (const coupleDoc of couplesSnap.docs) {
    const coupleId = coupleDoc.id;
    const bytesUsed = await sumCoupleUsage(coupleId);
    await db
      .collection("couples")
      .doc(coupleId)
      .collection("usage")
      .doc("current")
      .set({ bytesUsed });
    console.log(`${coupleId}: ${bytesUsed} bytes`);
  }

  console.log("Backfill complete.");
}

backfillUsage()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Backfill failed:", error);
    process.exit(1);
  });
```

- [ ] **Step 2: Dry-run against the Firestore + Storage emulators**

This is a one-off script with no automated test (it's a thin wrapper around already-tested Firestore/Storage Admin SDK calls) — verify it runs cleanly instead:

Run:
```bash
firebase emulators:exec --project demo-dyos-backfill-check --only firestore,storage \
  "node -e \"
    const admin = require('firebase-admin');
    process.env.FIRESTORE_EMULATOR_HOST = 'localhost:8080';
    process.env.FIREBASE_STORAGE_EMULATOR_HOST = 'localhost:9199';
    admin.initializeApp({ projectId: 'demo-dyos-backfill-check', storageBucket: 'demo-dyos-backfill-check.appspot.com' });
    admin.firestore().collection('couples').doc('c1').set({}).then(() => process.exit(0));
  \""
```
Expected: exits 0, proving a couple doc can be created against the emulator pair. Then run the actual script the same way (`node functions/scripts/backfill-usage.js`) with the same env vars set and confirm it logs `Found 1 couples.` / `c1: 0 bytes` / `Backfill complete.` without throwing.

- [ ] **Step 3: Commit**

```bash
git add functions/scripts/backfill-usage.js
git commit -m "feat(functions): add one-off backfill script for memory storage usage"
```

---

### Task 4: Storage Rules — quota + per-type size caps

**Files:**
- Modify: `storage.rules` (the `memories/{coupleId}/{fileName}` match block, lines 14-46)
- Modify: `firebase.json` (add a `storage` emulator entry)
- Create: `test/security/rules/storage_memories_rules.test.js`
- Modify: `test/security/rules/README.md`

**Interfaces:**
- Consumes: `couples/{coupleId}/usage/current.bytesUsed`, seeded/maintained by Task 2 and Task 3.
- Produces: none consumed by later tasks — this is the enforcement layer.

- [ ] **Step 1: Add the storage emulator to firebase.json**

In `firebase.json`, change:

```json
  "emulators": {
    "firestore": {
      "port": 8080
    }
  },
```

to:

```json
  "emulators": {
    "firestore": {
      "port": 8080
    },
    "storage": {
      "port": 9199
    }
  },
```

- [ ] **Step 2: Write the failing rules test**

Create `test/security/rules/storage_memories_rules.test.js`:

```js
const test = require("node:test");
const fs = require("fs");
const path = require("path");
const {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} = require("@firebase/rules-unit-testing");

const STORAGE_RULES_PATH = path.resolve(__dirname, "../../../storage.rules");
const FIRESTORE_RULES_PATH = path.resolve(__dirname, "../../../firestore.rules");

const COUPLE_ID = "couple_1";
const OTHER_COUPLE_ID = "couple_2";
const MEMBER_UID = "user_member";
const OUTSIDER_UID = "user_outsider";

const QUOTA_BYTES = 150 * 1000 * 1000;
const IMAGE_CAP_BYTES = 2 * 1024 * 1024;

let testEnv;

test.before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: "demo-dyos-storage-rules-test",
    storage: {
      rules: fs.readFileSync(STORAGE_RULES_PATH, "utf8"),
      host: "127.0.0.1",
      port: 9199,
    },
    firestore: {
      rules: fs.readFileSync(FIRESTORE_RULES_PATH, "utf8"),
      host: "127.0.0.1",
      port: 8080,
    },
  });
});

test.after(async () => {
  await testEnv.cleanup();
});

test.beforeEach(async () => {
  await setUsage(0);
});

async function setUsage(bytesUsed) {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await context
      .firestore()
      .collection("couples")
      .doc(COUPLE_ID)
      .collection("usage")
      .doc("current")
      .set({ bytesUsed });
  });
}

async function deleteUsageDoc() {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await context
      .firestore()
      .collection("couples")
      .doc(COUPLE_ID)
      .collection("usage")
      .doc("current")
      .delete();
  });
}

function memberStorage(coupleId = COUPLE_ID, uid = MEMBER_UID) {
  return testEnv.authenticatedContext(uid, { coupleId }).storage();
}

test("couple member can upload a small image under quota", async () => {
  const buffer = Buffer.alloc(1024, 1);
  await assertSucceeds(
    memberStorage()
      .ref(`memories/${COUPLE_ID}/photo.jpg`)
      .put(buffer, { contentType: "image/jpeg" })
  );
});

test("couple member cannot upload an image once at or over the 150MB quota", async () => {
  await setUsage(QUOTA_BYTES);
  const buffer = Buffer.alloc(1024, 1);
  await assertFails(
    memberStorage()
      .ref(`memories/${COUPLE_ID}/photo.jpg`)
      .put(buffer, { contentType: "image/jpeg" })
  );
});

test("couple member cannot upload an image over the 2MB per-file cap", async () => {
  const buffer = Buffer.alloc(IMAGE_CAP_BYTES + 1, 1);
  await assertFails(
    memberStorage()
      .ref(`memories/${COUPLE_ID}/photo.jpg`)
      .put(buffer, { contentType: "image/jpeg" })
  );
});

test("couple member can upload a video up to 10MB even though it exceeds the image cap", async () => {
  const buffer = Buffer.alloc(5 * 1024 * 1024, 1);
  await assertSucceeds(
    memberStorage()
      .ref(`memories/${COUPLE_ID}/clip.mp4`)
      .put(buffer, { contentType: "video/mp4" })
  );
});

test("couple member cannot upload a video over 10MB", async () => {
  const buffer = Buffer.alloc(10 * 1024 * 1024 + 1, 1);
  await assertFails(
    memberStorage()
      .ref(`memories/${COUPLE_ID}/clip.mp4`)
      .put(buffer, { contentType: "video/mp4" })
  );
});

test("non-member of the couple cannot upload regardless of quota", async () => {
  const buffer = Buffer.alloc(1024, 1);
  await assertFails(
    memberStorage(OTHER_COUPLE_ID, OUTSIDER_UID)
      .ref(`memories/${COUPLE_ID}/photo.jpg`)
      .put(buffer, { contentType: "image/jpeg" })
  );
});

test("upload is denied when the usage doc does not exist yet (fails closed)", async () => {
  await deleteUsageDoc();
  const buffer = Buffer.alloc(1024, 1);
  await assertFails(
    memberStorage()
      .ref(`memories/${COUPLE_ID}/photo.jpg`)
      .put(buffer, { contentType: "image/jpeg" })
  );
});
```

- [ ] **Step 3: Install deps and run the test to verify it fails**

Run:
```bash
cd test/security/rules && npm install && cd ../../..
firebase emulators:exec --project demo-dyos-storage-rules-test --only firestore,storage \
  "cd test/security/rules && node --test storage_memories_rules.test.js"
```
Expected: FAIL — today's `storage.rules` has no `bytesUsed` check and a flat 10MB cap for everything, so "cannot upload an image over the 2MB per-file cap" and "cannot upload once over the 150MB quota" both fail (the uploads wrongly succeed).

- [ ] **Step 4: Update storage.rules**

In `storage.rules`, replace the `memories/{coupleId}/{fileName}` match block (lines 14-46):

```
    match /memories/{coupleId}/{fileName} {
      // Helper function to check if user is authenticated
      function isAuthenticated() {
        return request.auth != null;
      }
      
      // Helper function to check if user is a member of the couple.
      // Uses the coupleId custom claim (stamped on the Auth token by the
      // pairing Cloud Functions) rather than firestore.exists/firestore.get:
      // those cross-service calls compiled and deployed fine but reliably
      // denied valid, verified-correct requests in this project, so
      // membership is checked from the token instead - no extra read needed.
      function isCoupleMember() {
        return isAuthenticated() && request.auth.token.coupleId == coupleId;
      }
      
      // Allow reading if user is a couple member
      allow read: if isCoupleMember();
      
      // Allow writing (upload/update) if user is authenticated and couple member
      // Only allow files up to 10MB (images/videos)
      // Note: contentType might be null during upload, so we check file extension via path
      allow write: if isAuthenticated() && 
                     isCoupleMember() &&
                     request.resource.size < 10 * 1024 * 1024 &&
                     // Allow common image and video formats (check contentType or path)
                     (request.resource.contentType.matches('image/.*') ||
                      request.resource.contentType.matches('video/.*') ||
                      fileName.matches('.*\\.(jpg|jpeg|png|gif|webp|mp4|mov|avi)$'));
      
      // Allow deletion if user is a couple member
      allow delete: if isCoupleMember();
    }
```

with:

```
    match /memories/{coupleId}/{fileName} {
      // Helper function to check if user is authenticated
      function isAuthenticated() {
        return request.auth != null;
      }
      
      // Helper function to check if user is a member of the couple.
      // Uses the coupleId custom claim (stamped on the Auth token by the
      // pairing Cloud Functions) rather than firestore.exists/firestore.get:
      // those cross-service calls compiled and deployed fine but reliably
      // denied valid, verified-correct requests in this project, so
      // membership is checked from the token instead - no extra read needed.
      function isCoupleMember() {
        return isAuthenticated() && request.auth.token.coupleId == coupleId;
      }

      function isImage() {
        return request.resource.contentType.matches('image/.*') ||
               fileName.matches('.*\\.(jpg|jpeg|png|gif|webp)$');
      }

      function isVideo() {
        return request.resource.contentType.matches('video/.*') ||
               fileName.matches('.*\\.(mp4|mov|avi)$');
      }

      // Per-couple storage ceiling. couples/{coupleId}/usage/current is
      // seeded at couple-creation time and kept live by
      // trackMemoryUsageOnFinalize/OnDelete (functions/index.js), so it
      // always exists by the time a couple can upload anything - a missing
      // doc here fails the read (and therefore the write) closed rather
      // than silently allowing unlimited storage.
      function bytesUsed() {
        return firestore.get(/databases/(default)/documents/couples/$(coupleId)/usage/current).data.bytesUsed;
      }

      function withinQuota() {
        // Decimal MB (150,000,000 bytes), not binary MiB - matches the
        // original storage-budget ask.
        return bytesUsed() < 150 * 1000 * 1000;
      }
      
      // Allow reading if user is a couple member
      allow read: if isCoupleMember();
      
      // Allow writing (upload/update) if authenticated, a couple member,
      // under the couple's overall quota, and within the per-file cap for
      // its type (images 2MB, videos keep the existing 10MB).
      allow write: if isAuthenticated() &&
                     isCoupleMember() &&
                     withinQuota() &&
                     (
                       (isImage() && request.resource.size < 2 * 1024 * 1024) ||
                       (isVideo() && request.resource.size < 10 * 1024 * 1024)
                     );
      
      // Allow deletion if user is a couple member
      allow delete: if isCoupleMember();
    }
```

- [ ] **Step 5: Run the test to verify it passes**

Run:
```bash
firebase emulators:exec --project demo-dyos-storage-rules-test --only firestore,storage \
  "cd test/security/rules && node --test storage_memories_rules.test.js"
```
Expected: PASS, all 7 tests green.

- [ ] **Step 6: Update the README to document the storage rules coverage**

In `test/security/rules/README.md`, change the "Running" section's command from:

```sh
firebase emulators:exec --project demo-dyos-rules-test --only firestore \
  "cd test/security/rules && npm test"
```

to:

```sh
firebase emulators:exec --project demo-dyos-rules-test --only firestore,storage \
  "cd test/security/rules && npm test"
```

and add a line above it noting: "`npm test` now also runs `storage_memories_rules.test.js`, which exercises `storage.rules` (including its cross-service `firestore.get()` quota check) against both emulators together."

- [ ] **Step 7: Commit**

```bash
git add storage.rules firebase.json test/security/rules/storage_memories_rules.test.js test/security/rules/README.md
git commit -m "feat(storage): enforce 150MB per-couple quota and per-type size caps"
```

---

### Task 5: Client-side friendly quota-exceeded message

**Files:**
- Modify: `lib/features/timeline/data/memory_repository.dart:102-114`
- Modify: `test/timeline/memory_repository_test.dart`

**Interfaces:**
- Consumes: nothing new from prior tasks (this only reacts to the `unauthorized` `FirebaseException` that Task 4's rule change causes Storage to throw).
- Produces: nothing consumed elsewhere — `memory_provider.dart:182-185` already does `e.toString().replaceFirst('Exception: ', '')` on whatever `createMemory` throws, so no further UI change is needed for the message to reach the user.

- [ ] **Step 1: Write the failing test**

In `test/timeline/memory_repository_test.dart`, add `import 'dart:typed_data';` and `import 'package:image_picker/image_picker.dart';` to the imports at the top, add a `MockReference` class next to the existing `MockFirebaseStorage`:

```dart
class MockReference extends Mock implements Reference {}
```

Then add a new test group at the end of `main()`, before the closing `}`:

```dart
  group('MemoryRepository.createMemory media upload errors', () {
    test('surfaces a friendly message when the couple is over its storage quota', () async {
      final mockStorage = MockFirebaseStorage();
      final mockRootRef = MockReference();
      final mockFileRef = MockReference();
      when(mockStorage.ref()).thenReturn(mockRootRef);
      when(mockRootRef.child(any)).thenReturn(mockFileRef);
      when(mockFileRef.putData(any, any)).thenThrow(
        FirebaseException(plugin: 'firebase_storage', code: 'unauthorized'),
      );

      final repo = MemoryRepository(firestore: firestore, storage: mockStorage);
      final file = XFile.fromData(
        Uint8List.fromList([1, 2, 3]),
        name: 'photo.jpg',
        mimeType: 'image/jpeg',
      );

      await expectLater(
        repo.createMemory(memory: buildMemory(), mediaFiles: [file]),
        throwsA(
          predicate(
            (e) => e is Exception && e.toString().contains("storage limit"),
          ),
        ),
      );
    });

    test('wraps other upload failures with file-index context (unchanged behavior)', () async {
      final mockStorage = MockFirebaseStorage();
      final mockRootRef = MockReference();
      final mockFileRef = MockReference();
      when(mockStorage.ref()).thenReturn(mockRootRef);
      when(mockRootRef.child(any)).thenReturn(mockFileRef);
      when(mockFileRef.putData(any, any)).thenThrow(Exception('network error'));

      final repo = MemoryRepository(firestore: firestore, storage: mockStorage);
      final file = XFile.fromData(
        Uint8List.fromList([1, 2, 3]),
        name: 'photo.jpg',
        mimeType: 'image/jpeg',
      );

      await expectLater(
        repo.createMemory(memory: buildMemory(), mediaFiles: [file]),
        throwsA(
          predicate(
            (e) => e is Exception && e.toString().contains('Failed to upload file 1/1'),
          ),
        ),
      );
    });
  });
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `flutter test test/timeline/memory_repository_test.dart`
Expected: FAIL on the first new test — today's code wraps every upload error identically, so the thrown exception's message contains `"Failed to upload file 1/1"`, not `"storage limit"`.

- [ ] **Step 3: Write the minimal implementation**

In `lib/features/timeline/data/memory_repository.dart`, replace the upload try/catch (lines 102-114):

```dart
          try {
            // Upload as bytes (not putFile) so this works on every platform,
            // including web, where dart:io's File/putFile are unsupported.
            final bytes = await file.readAsBytes();
            await storageRef.putData(bytes, metadata);

            // Get download URL
            final downloadUrl = await storageRef.getDownloadURL();
            downloadUrls.add(downloadUrl);
          } catch (e) {
            // Re-throw with more context
            throw Exception('Failed to upload file ${i + 1}/${mediaFiles.length}: $e');
          }
```

with:

```dart
          try {
            // Upload as bytes (not putFile) so this works on every platform,
            // including web, where dart:io's File/putFile are unsupported.
            final bytes = await file.readAsBytes();
            await storageRef.putData(bytes, metadata);

            // Get download URL
            final downloadUrl = await storageRef.getDownloadURL();
            downloadUrls.add(downloadUrl);
          } on FirebaseException catch (e) {
            // storage.rules denies the write once the couple is at/over its
            // 150MB quota, surfacing as 'unauthorized' - give a message the
            // user can act on instead of a generic upload failure.
            if (e.plugin == 'firebase_storage' && e.code == 'unauthorized') {
              throw Exception(
                "Your couple's storage limit has been reached. Delete some old photos or videos to free up space.",
              );
            }
            throw Exception('Failed to upload file ${i + 1}/${mediaFiles.length}: $e');
          } catch (e) {
            // Re-throw with more context
            throw Exception('Failed to upload file ${i + 1}/${mediaFiles.length}: $e');
          }
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `flutter test test/timeline/memory_repository_test.dart`
Expected: PASS, including both new tests and all pre-existing tests in the file.

- [ ] **Step 5: Commit**

```bash
git add lib/features/timeline/data/memory_repository.dart test/timeline/memory_repository_test.dart
git commit -m "feat(timeline): show a friendly message when a couple hits its storage quota"
```

---

### Task 6: Rollout and production verification

**Files:** none (deployment + manual verification only).

**Interfaces:** none — this task exercises everything built in Tasks 1-5 end-to-end against a real Firebase project.

- [ ] **Step 1: Deploy Cloud Functions**

Run: `firebase deploy --only functions:trackMemoryUsageOnFinalize,functions:trackMemoryUsageOnDelete,functions:pairWithInviteCode,functions:pairWithEmail`
Expected: deploy succeeds; the two new triggers and the two updated pairing functions show as deployed in the CLI output.

- [ ] **Step 2: Run the backfill script against production**

Run: `GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json node functions/scripts/backfill-usage.js`
Expected: logs one line per existing couple with a non-negative `bytesUsed`, ending in `Backfill complete.`. Spot-check one couple's `couples/{coupleId}/usage/current` doc in the Firebase console and confirm the number roughly matches what's visible in Storage for that `memories/{coupleId}/` prefix.

- [ ] **Step 3: Deploy storage.rules**

Run: `firebase deploy --only storage`
Expected: deploy succeeds. This must happen only after Steps 1-2, per the Rollout order in Global Constraints.

- [ ] **Step 4: Manual smoke test — normal upload still works**

Using a real (or staging) couple account with `bytesUsed` well under 150MB, add a memory with a photo through the app. Expected: upload succeeds, and the couple's `usage/current.bytesUsed` in the Firebase console increases by roughly the photo's compressed size shortly after (allow a few seconds for `compressImage` + `trackMemoryUsageOnFinalize` to run).

- [ ] **Step 5: Manual smoke test — quota denial surfaces the friendly message**

Temporarily set a test couple's `couples/{coupleId}/usage/current.bytesUsed` to `150000000` directly in the Firebase console. Attempt to add a memory with a photo as that couple in the app. Expected: the app shows "Your couple's storage limit has been reached. Delete some old photos or videos to free up space." (not a raw Firebase error). Afterward, reset that couple's `bytesUsed` back to its real value (re-run the backfill script for just that couple, or restore the value you overwrote).

- [ ] **Step 6: Manual smoke test — delete decrements usage**

Delete the memory added in Step 4. Expected: `bytesUsed` decreases by roughly the same amount it increased by (within the small drift documented in the spec's "Known limitation").

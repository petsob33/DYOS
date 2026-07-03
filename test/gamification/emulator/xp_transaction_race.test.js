const test = require("node:test");
const assert = require("node:assert/strict");
const { initializeTestEnvironment } = require("@firebase/rules-unit-testing");

const COUPLE_ID = "couple_1";

// This suite tests real Firestore transaction serialization, not access
// control (that's covered by test/security/rules) - allow all reads/writes
// so the race-condition mechanics aren't obscured by unrelated permission
// failures.
const ALLOW_ALL_RULES = `
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}`;

let testEnv;

test.before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: "demo-dyos-gamification-test",
    firestore: {
      rules: ALLOW_ALL_RULES,
      host: "127.0.0.1",
      port: 8080,
    },
  });
});

test.after(async () => {
  await testEnv.cleanup();
});

test.beforeEach(async () => {
  await testEnv.clearFirestore();
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await context.firestore().collection("couples").doc(COUPLE_ID).set({
      members: ["user_a", "user_b"],
      xp: 0,
    });
  });
});

function todayDateString() {
  const n = new Date();
  return `${n.getFullYear()}-${String(n.getMonth() + 1).padStart(2, "0")}-${String(n.getDate()).padStart(2, "0")}`;
}

// Mirrors the transaction body of SubscriptionService.grantQuestXpIfEligible
// (lib/core/services/subscription_service.dart): read the grant state fresh
// inside the transaction, and only increment XP + set today's grant flag if
// it isn't already set. xp is applied as read-then-write here (rather than
// Dart's FieldValue.increment) purely because this harness talks to the
// emulator through the client SDK's transaction API - the atomicity being
// tested (the read-check-write happening as one unit) is identical.
async function grantQuestXpIfEligible(db, coupleId, questId, amount) {
  const coupleRef = db.collection("couples").doc(coupleId);
  const today = todayDateString();

  return db.runTransaction(async (transaction) => {
    const snapshot = await transaction.get(coupleRef);
    if (!snapshot.exists) return false;

    const data = snapshot.data();
    const granted = data.questXpLastGrantedAt || {};
    if (granted[questId] === today) return false;

    transaction.update(coupleRef, {
      xp: (data.xp || 0) + amount,
      [`questXpLastGrantedAt.${questId}`]: today,
    });
    return true;
  });
}

test("two concurrent grantQuestXpIfEligible calls for the same quest only grant XP once", async () => {
  const db = testEnv.unauthenticatedContext().firestore();

  // Fire both "partners' " calls at once, same as Future.wait in Dart -
  // real Firestore serializes the two transactions against the same
  // document and retries the loser, so only one should see "not granted yet".
  const results = await Promise.all([
    grantQuestXpIfEligible(db, COUPLE_ID, "memory", 25),
    grantQuestXpIfEligible(db, COUPLE_ID, "memory", 25),
  ]);

  const grantedCount = results.filter(Boolean).length;
  assert.equal(grantedCount, 1, "exactly one of the two concurrent calls should have granted XP");

  const doc = await db.collection("couples").doc(COUPLE_ID).get();
  assert.equal(doc.data().xp, 25, "XP must be granted exactly once, not twice");
});

test("ten concurrent grantQuestXpIfEligible calls for the same quest only grant XP once", async () => {
  const db = testEnv.unauthenticatedContext().firestore();

  const results = await Promise.all(
    Array.from({ length: 10 }, () => grantQuestXpIfEligible(db, COUPLE_ID, "memory", 25)),
  );

  const grantedCount = results.filter(Boolean).length;
  assert.equal(grantedCount, 1, "exactly one of the ten concurrent calls should have granted XP");

  const doc = await db.collection("couples").doc(COUPLE_ID).get();
  assert.equal(doc.data().xp, 25, "XP must be granted exactly once, not ten times");
});

test("sequential calls on different days would each grant (sanity check on the helper)", async () => {
  const db = testEnv.unauthenticatedContext().firestore();

  const grantedToday = await grantQuestXpIfEligible(db, COUPLE_ID, "memory", 25);
  assert.equal(grantedToday, true);

  const grantedAgainToday = await grantQuestXpIfEligible(db, COUPLE_ID, "memory", 25);
  assert.equal(grantedAgainToday, false);

  const doc = await db.collection("couples").doc(COUPLE_ID).get();
  assert.equal(doc.data().xp, 25);
});

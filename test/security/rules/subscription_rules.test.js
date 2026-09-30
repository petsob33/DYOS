const test = require("node:test");
const assert = require("node:assert/strict");
const fs = require("fs");
const path = require("path");
const {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} = require("@firebase/rules-unit-testing");

// Clients must not be able to grant themselves premium: only the RevenueCat
// webhook (Admin SDK, bypasses rules) may write subscriptionTier/Expiry.
const RULES_PATH = path.resolve(__dirname, "../../../firestore.rules");
const COUPLE_ID = "couple_1";
const MEMBER = "user_a";
const OTHER = "user_b";

let testEnv;

test.before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: "demo-dyos-rules-test-subscription",
    firestore: {
      rules: fs.readFileSync(RULES_PATH, "utf8"),
      host: "127.0.0.1",
      port: 8080,
    },
  });
});
test.after(async () => testEnv.cleanup());
test.beforeEach(async () => {
  await testEnv.clearFirestore();
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    await ctx.firestore().collection("couples").doc(COUPLE_ID).set({
      members: [MEMBER, OTHER],
      subscriptionTier: "free",
      xp: 0,
    });
  });
});

const couple = (uid = MEMBER) =>
  testEnv.authenticatedContext(uid).firestore().collection("couples").doc(COUPLE_ID);

test("member cannot set subscriptionTier", async () => {
  await assertFails(couple().update({ subscriptionTier: "premium" }));
});

test("member cannot set subscriptionExpiry", async () => {
  await assertFails(couple().update({ subscriptionExpiry: new Date("2099-01-01") }));
});

test("member cannot overwrite the couple doc to add premium", async () => {
  await assertFails(
    couple().set({ members: [MEMBER, OTHER], subscriptionTier: "premium" })
  );
});

test("member can still update other fields (xp)", async () => {
  await assertSucceeds(couple().update({ xp: 10 }));
});

test("cannot create a couple that already carries premium", async () => {
  const db = testEnv.authenticatedContext(MEMBER).firestore();
  await assertFails(
    db.collection("couples").doc("new").set({
      members: [MEMBER, "x"],
      subscriptionTier: "premium",
    })
  );
  await assertSucceeds(
    db.collection("couples").doc("new2").set({ members: [MEMBER, "x"] })
  );
});

const test = require("node:test");
const assert = require("node:assert/strict");
const fs = require("fs");
const path = require("path");
const {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} = require("@firebase/rules-unit-testing");

// General notes access control (create/update/delete, and get/list for
// non-private/secretGift types) across all couple member roles. The
// private/secretGift-specific author-only read restriction is covered by
// notes_rules.test.js - this file covers the rest of the access matrix.
const RULES_PATH = path.resolve(__dirname, "../../../firestore.rules");

const COUPLE_ID = "couple_1";
const AUTHOR_UID = "user_author";
const PARTNER_UID = "user_partner";
const STRANGER_UID = "stranger_uid";

let testEnv;

test.before(async () => {
  testEnv = await initializeTestEnvironment({
    // Distinct from notes_rules.test.js's project id: node --test runs
    // test files concurrently by default, and both files' beforeEach hooks
    // clearFirestore() - sharing a project would race the two files against
    // each other's data.
    projectId: "demo-dyos-rules-test-general",
    firestore: {
      rules: fs.readFileSync(RULES_PATH, "utf8"),
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
      members: [AUTHOR_UID, PARTNER_UID],
    });
    await context
      .firestore()
      .collection("couples")
      .doc(COUPLE_ID)
      .collection("notes")
      .doc("shared_note")
      .set({ authorId: AUTHOR_UID, type: "shared", content: "grocery list" });
    await context
      .firestore()
      .collection("couples")
      .doc(COUPLE_ID)
      .collection("notes")
      .doc("bucket_note")
      .set({ authorId: AUTHOR_UID, type: "bucketList", content: "skydiving" });
  });
});

function notesCollection(uid) {
  const db = testEnv.authenticatedContext(uid).firestore();
  return db.collection("couples").doc(COUPLE_ID).collection("notes");
}

function notesDoc(uid, noteId) {
  return notesCollection(uid).doc(noteId);
}

// ---- create ----

test("a couple member can create a note as themselves with a string type", async () => {
  await assertSucceeds(
    notesCollection(PARTNER_UID).doc("new_note").set({
      authorId: PARTNER_UID,
      type: "bucketList",
      content: "learn to surf",
    }),
  );
});

test("create fails when authorId does not match the requester (impersonation)", async () => {
  await assertFails(
    notesCollection(PARTNER_UID).doc("new_note").set({
      authorId: AUTHOR_UID,
      type: "bucketList",
      content: "spoofed",
    }),
  );
});

test("create fails when type is missing", async () => {
  await assertFails(
    notesCollection(PARTNER_UID).doc("new_note").set({
      authorId: PARTNER_UID,
      content: "no type field",
    }),
  );
});

test("a non-member cannot create a note in the couple's collection", async () => {
  await assertFails(
    notesCollection(STRANGER_UID).doc("new_note").set({
      authorId: STRANGER_UID,
      type: "bucketList",
      content: "intruder",
    }),
  );
});

// ---- get/list for non-private types ----

test("both couple members can get and list shared/bucketList notes", async () => {
  await assertSucceeds(notesDoc(AUTHOR_UID, "shared_note").get());
  await assertSucceeds(notesDoc(PARTNER_UID, "shared_note").get());
  await assertSucceeds(
    notesCollection(AUTHOR_UID).where("type", "==", "bucketList").get(),
  );
  await assertSucceeds(
    notesCollection(PARTNER_UID).where("type", "==", "bucketList").get(),
  );
});

test("a non-member cannot get or list shared/bucketList notes", async () => {
  await assertFails(notesDoc(STRANGER_UID, "shared_note").get());
  await assertFails(
    notesCollection(STRANGER_UID).where("type", "==", "bucketList").get(),
  );
});

// ---- update ----

test("any couple member can update a shared/bucketList note, including one authored by the other member", async () => {
  await assertSucceeds(
    notesDoc(PARTNER_UID, "shared_note").update({ content: "updated by partner" }),
  );
  await assertSucceeds(
    notesDoc(AUTHOR_UID, "bucket_note").update({ content: "updated by author" }),
  );
});

test("a non-member cannot update a note", async () => {
  await assertFails(
    notesDoc(STRANGER_UID, "shared_note").update({ content: "hijacked" }),
  );
});

// ---- delete ----

test("only the author can delete a shared/bucketList note, not just any couple member", async () => {
  await assertFails(notesDoc(PARTNER_UID, "shared_note").delete());
  await assertSucceeds(notesDoc(AUTHOR_UID, "shared_note").delete());
});

test("a non-member cannot delete a note even if they know the id", async () => {
  await assertFails(notesDoc(STRANGER_UID, "bucket_note").delete());
});

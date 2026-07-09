const test = require("node:test");
const assert = require("node:assert/strict");
const fs = require("fs");
const path = require("path");
const {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} = require("@firebase/rules-unit-testing");

const RULES_PATH = path.resolve(__dirname, "../../../firestore.rules");

const COUPLE_ID = "couple_1";
const AUTHOR_UID = "user_author";
const PARTNER_UID = "user_partner";

let testEnv;

test.before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: "demo-dyos-rules-test",
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
    const db = context.firestore();
    await db.collection("couples").doc(COUPLE_ID).set({
      members: [AUTHOR_UID, PARTNER_UID],
    });
    await db
      .collection("couples")
      .doc(COUPLE_ID)
      .collection("notes")
      .doc("private_note")
      .set({
        authorId: AUTHOR_UID,
        type: "private",
        content: "author's private note",
      });
    await db
      .collection("couples")
      .doc(COUPLE_ID)
      .collection("notes")
      .doc("secret_gift_note")
      .set({
        authorId: AUTHOR_UID,
        type: "secretGift",
        content: "surprise gift idea",
      });
    await db
      .collection("couples")
      .doc(COUPLE_ID)
      .collection("notes")
      .doc("shared_note")
      .set({
        authorId: AUTHOR_UID,
        type: "shared",
        content: "grocery list",
      });
  });
});

function notesDoc(uid, noteId) {
  const db = testEnv.authenticatedContext(uid).firestore();
  return db
    .collection("couples")
    .doc(COUPLE_ID)
    .collection("notes")
    .doc(noteId);
}

function notesCollection(uid) {
  const db = testEnv.authenticatedContext(uid).firestore();
  return db.collection("couples").doc(COUPLE_ID).collection("notes");
}

test("partner cannot get another member's private note", async () => {
  await assertFails(notesDoc(PARTNER_UID, "private_note").get());
});

test("partner cannot get another member's secretGift note", async () => {
  await assertFails(notesDoc(PARTNER_UID, "secret_gift_note").get());
});

test("partner cannot list notes containing another member's private/secretGift notes", async () => {
  await assertFails(
    notesCollection(PARTNER_UID).where("type", "==", "private").get(),
  );
  await assertFails(
    notesCollection(PARTNER_UID).where("type", "==", "secretGift").get(),
  );
});

test("author can get their own private note", async () => {
  await assertSucceeds(notesDoc(AUTHOR_UID, "private_note").get());
});

test("author can get their own secretGift note", async () => {
  await assertSucceeds(notesDoc(AUTHOR_UID, "secret_gift_note").get());
});

test("author can list their own private notes", async () => {
  // The list rule can't verify an unconstrained authorId field, so the
  // client (see notes_repository.dart) must also filter by authorId for
  // private/secretGift types - mirror that query shape here.
  await assertSucceeds(
    notesCollection(AUTHOR_UID)
      .where("type", "==", "private")
      .where("authorId", "==", AUTHOR_UID)
      .get(),
  );
});

test("partner cannot list private notes even when also filtering by the author's id", async () => {
  await assertFails(
    notesCollection(PARTNER_UID)
      .where("type", "==", "private")
      .where("authorId", "==", AUTHOR_UID)
      .get(),
  );
});

test("both partners can get a shared note", async () => {
  await assertSucceeds(notesDoc(AUTHOR_UID, "shared_note").get());
  await assertSucceeds(notesDoc(PARTNER_UID, "shared_note").get());
});

test("both partners can list shared notes", async () => {
  await assertSucceeds(
    notesCollection(AUTHOR_UID).where("type", "==", "shared").get(),
  );
  await assertSucceeds(
    notesCollection(PARTNER_UID).where("type", "==", "shared").get(),
  );
});

test("author can still update their own private note", async () => {
  await assertSucceeds(
    notesDoc(AUTHOR_UID, "private_note").update({ content: "edited" }),
  );
});

test("partner can still update the author's private note (unchanged behavior)", async () => {
  // Update rule is unaffected by this fix - any couple member may still
  // update notes, matching pre-existing behavior before this change.
  await assertSucceeds(
    notesDoc(PARTNER_UID, "private_note").update({ content: "edited by partner" }),
  );
});

test("author can still delete their own private note", async () => {
  await assertSucceeds(notesDoc(AUTHOR_UID, "private_note").delete());
});

test("partner still cannot delete the author's private note", async () => {
  await assertFails(notesDoc(PARTNER_UID, "private_note").delete());
});

test("non-member cannot get any note regardless of type", async () => {
  await assertFails(notesDoc("stranger_uid", "shared_note").get());
  await assertFails(notesDoc("stranger_uid", "private_note").get());
});

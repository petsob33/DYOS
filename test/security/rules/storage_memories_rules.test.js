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

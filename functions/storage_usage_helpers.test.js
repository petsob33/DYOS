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

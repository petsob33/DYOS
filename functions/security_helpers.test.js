const test = require("node:test");
const assert = require("node:assert/strict");

const {
  normalizeInviteCode,
  isValidInviteCode,
  shouldRejectForMissingAppCheck,
  evaluateRateLimitWindow,
} = require("./security_helpers");

test("normalizeInviteCode trims and uppercases", () => {
  assert.equal(normalizeInviteCode("  petr-1234 "), "PETR-1234");
  assert.equal(normalizeInviteCode(1234), "");
});

test("isValidInviteCode accepts expected pattern", () => {
  assert.equal(isValidInviteCode("PETR-1234"), true);
  assert.equal(isValidInviteCode("A-1234"), false);
  assert.equal(isValidInviteCode("PETR1234"), false);
  assert.equal(isValidInviteCode("PETR-ABCD"), false);
});

test("shouldRejectForMissingAppCheck behavior", () => {
  assert.equal(shouldRejectForMissingAppCheck(false, {}), false);
  assert.equal(shouldRejectForMissingAppCheck(true, { app: { token: "ok" } }), false);
  assert.equal(shouldRejectForMissingAppCheck(true, {}), true);
});

test("evaluateRateLimitWindow resets outside window", () => {
  const result = evaluateRateLimitWindow({
    existingCount: 4,
    existingWindowStartMs: 1000,
    nowMs: 8000,
    maxRequests: 5,
    windowMs: 2000,
  });

  assert.equal(result.blocked, false);
  assert.equal(result.nextCount, 1);
  assert.equal(result.resetWindow, true);
  assert.equal(result.nextWindowStartMs, 8000);
});

test("evaluateRateLimitWindow increments inside window", () => {
  const result = evaluateRateLimitWindow({
    existingCount: 2,
    existingWindowStartMs: 1000,
    nowMs: 1500,
    maxRequests: 5,
    windowMs: 2000,
  });

  assert.equal(result.blocked, false);
  assert.equal(result.nextCount, 3);
  assert.equal(result.resetWindow, false);
  assert.equal(result.nextWindowStartMs, 1000);
});

test("evaluateRateLimitWindow blocks when limit reached", () => {
  const result = evaluateRateLimitWindow({
    existingCount: 5,
    existingWindowStartMs: 1000,
    nowMs: 1500,
    maxRequests: 5,
    windowMs: 2000,
  });

  assert.equal(result.blocked, true);
  assert.equal(result.nextCount, 5);
  assert.equal(result.resetWindow, false);
  assert.equal(result.nextWindowStartMs, 1000);
});

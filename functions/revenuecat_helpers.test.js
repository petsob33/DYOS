const test = require("node:test");
const assert = require("node:assert/strict");
const { isAuthorizedWebhook, parseRevenueCatEvent } = require("./revenuecat_helpers");

const NOW = 1_800_000_000_000;
const ev = (over) => ({
  event: {
    type: "INITIAL_PURCHASE",
    app_user_id: "uid_1",
    entitlement_ids: ["premium"],
    expiration_at_ms: NOW + 1000,
    ...over,
  },
});

test("auth: matches exact secret only", () => {
  assert.equal(isAuthorizedWebhook("s3cret", "s3cret"), true);
  assert.equal(isAuthorizedWebhook("Bearer s3cret", "s3cret"), true);
  assert.equal(isAuthorizedWebhook("Bearer wrong", "s3cret"), false);
  assert.equal(isAuthorizedWebhook("s3creT", "s3cret"), false);
  assert.equal(isAuthorizedWebhook("s3cret1", "s3cret"), false);
  assert.equal(isAuthorizedWebhook(undefined, "s3cret"), false);
  assert.equal(isAuthorizedWebhook("", ""), false);
  assert.equal(isAuthorizedWebhook("x", undefined), false);
});

test("purchase grants with expiry", () => {
  assert.deepEqual(parseRevenueCatEvent(ev({}), "premium", NOW), {
    action: "grant", uid: "uid_1", expiryMs: NOW + 1000,
  });
});

test("lifetime (no expiry) grants with null expiry", () => {
  const r = parseRevenueCatEvent(ev({ type: "NON_RENEWING_PURCHASE", expiration_at_ms: null }), "premium", NOW);
  assert.equal(r.action, "grant");
  assert.equal(r.expiryMs, null);
});

test("renewal and product change grant", () => {
  assert.equal(parseRevenueCatEvent(ev({ type: "RENEWAL" }), "premium", NOW).action, "grant");
  assert.equal(parseRevenueCatEvent(ev({ type: "PRODUCT_CHANGE" }), "premium", NOW).action, "grant");
});

test("expiration revokes", () => {
  assert.equal(parseRevenueCatEvent(ev({ type: "EXPIRATION", expiration_at_ms: NOW - 1 }), "premium", NOW).action, "revoke");
});

test("cancellation keeps access until expiry, refund revokes", () => {
  assert.equal(parseRevenueCatEvent(ev({ type: "CANCELLATION" }), "premium", NOW).action, "ignore");
  assert.equal(parseRevenueCatEvent(ev({ type: "CANCELLATION", expiration_at_ms: NOW - 5 }), "premium", NOW).action, "revoke");
});

test("grant with already-past expiry is a revoke", () => {
  assert.equal(parseRevenueCatEvent(ev({ expiration_at_ms: NOW - 1 }), "premium", NOW).action, "revoke");
});

test("ignores other entitlements, anonymous users, junk", () => {
  assert.equal(parseRevenueCatEvent(ev({ entitlement_ids: ["other"] }), "premium", NOW).action, "ignore");
  assert.equal(parseRevenueCatEvent(ev({ app_user_id: "$RCAnonymousID:abc" }), "premium", NOW).action, "ignore");
  assert.equal(parseRevenueCatEvent(ev({ type: "TEST" }), "premium", NOW).action, "ignore");
  assert.equal(parseRevenueCatEvent({}, "premium", NOW).action, "ignore");
  assert.equal(parseRevenueCatEvent(null, "premium", NOW).action, "ignore");
});

// Event types that (re)activate premium; expiration_at_ms is null for lifetime.
const GRANT_EVENTS = new Set([
  "INITIAL_PURCHASE",
  "RENEWAL",
  "NON_RENEWING_PURCHASE",
  "PRODUCT_CHANGE",
  "UNCANCELLATION",
  "TEMPORARY_ENTITLEMENT_GRANT",
]);
// Event types after which access has ended.
const REVOKE_EVENTS = new Set(["EXPIRATION", "REFUND_REVERSED_NEVER"]);

/**
 * Checks the shared secret RevenueCat sends in the Authorization header.
 * Constant-time comparison; an empty configured secret never matches.
 */
function isAuthorizedWebhook(headerValue, secret) {
  if (typeof secret !== "string" || secret.length === 0) return false;
  if (typeof headerValue !== "string") return false;
  // Google's frontend rejects non-"Bearer" Authorization values, so the
  // RevenueCat header is configured as "Bearer <secret>".
  const a = Buffer.from(headerValue.replace(/^Bearer\s+/i, ""));
  const b = Buffer.from(secret);
  if (a.length !== b.length) return false;
  return require("node:crypto").timingSafeEqual(a, b);
}

/**
 * Turns a RevenueCat webhook body into a decision.
 * Returns { action: "grant" | "revoke" | "ignore", uid, expiryMs }.
 * CANCELLATION and BILLING_ISSUE are ignored: access lasts until EXPIRATION.
 */
function parseRevenueCatEvent(body, entitlementId = "premium", nowMs = Date.now()) {
  const event = body && body.event;
  if (!event || typeof event.type !== "string") {
    return { action: "ignore", uid: null, expiryMs: null };
  }
  const uid = typeof event.app_user_id === "string" ? event.app_user_id : null;
  const ids = Array.isArray(event.entitlement_ids)
    ? event.entitlement_ids
    : event.entitlement_id
    ? [event.entitlement_id]
    : [];
  if (!uid || uid.startsWith("$RCAnonymousID") || !ids.includes(entitlementId)) {
    return { action: "ignore", uid, expiryMs: null };
  }
  const expiryMs =
    typeof event.expiration_at_ms === "number" ? event.expiration_at_ms : null;

  if (REVOKE_EVENTS.has(event.type)) {
    return { action: "revoke", uid, expiryMs };
  }
  if (event.type === "REFUND" || event.type === "CANCELLATION") {
    // Refunded/cancelled with immediate effect: expiry already in the past.
    if (expiryMs !== null && expiryMs <= nowMs) {
      return { action: "revoke", uid, expiryMs };
    }
    return { action: "ignore", uid, expiryMs };
  }
  if (GRANT_EVENTS.has(event.type)) {
    if (expiryMs !== null && expiryMs <= nowMs) {
      return { action: "revoke", uid, expiryMs };
    }
    return { action: "grant", uid, expiryMs };
  }
  return { action: "ignore", uid, expiryMs };
}

module.exports = { isAuthorizedWebhook, parseRevenueCatEvent };

function normalizeInviteCode(value) {
  if (typeof value !== "string") return "";
  return value.trim().toUpperCase();
}

function isValidInviteCode(value) {
  return /^[A-Z]{2,10}-\d{4}$/.test(value);
}

function shouldRejectForMissingAppCheck(enforceAppCheck, context) {
  return Boolean(enforceAppCheck && !context?.app);
}

function evaluateRateLimitWindow({
  existingCount,
  existingWindowStartMs,
  nowMs,
  maxRequests,
  windowMs,
}) {
  const safeNowMs = typeof nowMs === "number" ? nowMs : Date.now();
  const count = typeof existingCount === "number" ? existingCount : 0;
  const windowStartMs =
    typeof existingWindowStartMs === "number" ? existingWindowStartMs : safeNowMs;

  const inSameWindow = safeNowMs - windowStartMs < windowMs;
  if (!inSameWindow) {
    return {
      blocked: false,
      nextCount: 1,
      nextWindowStartMs: safeNowMs,
      resetWindow: true,
    };
  }

  if (count >= maxRequests) {
    return {
      blocked: true,
      nextCount: count,
      nextWindowStartMs: windowStartMs,
      resetWindow: false,
    };
  }

  return {
    blocked: false,
    nextCount: count + 1,
    nextWindowStartMs: windowStartMs,
    resetWindow: false,
  };
}

module.exports = {
  normalizeInviteCode,
  isValidInviteCode,
  shouldRejectForMissingAppCheck,
  evaluateRateLimitWindow,
};

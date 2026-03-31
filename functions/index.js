const functions = require("firebase-functions/v1");
const admin = require("firebase-admin");
const sharp = require("sharp");
const {
  normalizeInviteCode,
  isValidInviteCode,
  shouldRejectForMissingAppCheck,
  evaluateRateLimitWindow,
} = require("./security_helpers");

admin.initializeApp();
const db = admin.firestore();
const ENFORCE_APP_CHECK = process.env.ENFORCE_APP_CHECK === "true";

function assertAppCheck(context) {
  if (shouldRejectForMissingAppCheck(ENFORCE_APP_CHECK, context)) {
    throw new functions.https.HttpsError(
      "failed-precondition",
      "App Check token is required."
    );
  }
}

async function enforceRateLimit(uid, action, maxRequests, windowSeconds) {
  const key = `${uid}_${action}`;
  const nowMs = Date.now();
  const windowMs = windowSeconds * 1000;
  const ref = db.collection("security_rate_limits").doc(key);

  await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    if (!snap.exists) {
      tx.set(ref, {
        uid,
        action,
        count: 1,
        windowStartMs: nowMs,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      return;
    }

    const data = snap.data() || {};
    const next = evaluateRateLimitWindow({
      existingCount: data.count,
      existingWindowStartMs: data.windowStartMs,
      nowMs,
      maxRequests,
      windowMs,
    });

    if (next.resetWindow) {
      tx.set(
        ref,
        {
          uid,
          action,
          count: 1,
          windowStartMs: nowMs,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );
      return;
    }

    if (next.blocked) {
      throw new functions.https.HttpsError(
        "resource-exhausted",
        "Too many requests. Please try again later."
      );
    }

    tx.set(
      ref,
      {
        count: next.nextCount,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );
  });
}

exports.getUserByInviteCode = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "The function must be called while authenticated."
    );
  }
  assertAppCheck(context);
  await enforceRateLimit(context.auth.uid, "lookup_invite_code", 30, 60);

  const inviteCode = normalizeInviteCode(data.inviteCode);
  if (!inviteCode) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "The function must be called with one arguments 'inviteCode'."
    );
  }
  if (!isValidInviteCode(inviteCode)) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Invite code format is invalid."
    );
  }

  try {
    const usersRef = db.collection("users");
    const query = await usersRef
      .where("inviteCode", "==", inviteCode)
      .limit(1)
      .get();

    if (query.docs.length === 0) {
      return null;
    }

    const userDoc = query.docs[0];
    const user = userDoc.data() || {};
    return {
      uid: userDoc.id,
      displayName: user.displayName || "",
      inviteCode: user.inviteCode || "",
      coupleId: user.coupleId || null,
      // Keep compatibility with current UserModel deserialization.
      email: "",
    };
  } catch (error) {
    throw new functions.https.HttpsError("internal", error.message, error.details);
  }
});

/** Get partner UID from couple doc (the member that is not fromUserId). */
async function getPartnerUid(coupleId, fromUserId) {
  const coupleDoc = await db.collection("couples").doc(coupleId).get();
  if (!coupleDoc.exists) return null;
  const members = coupleDoc.data().members || [];
  const partnerUid = members.find((uid) => uid !== fromUserId) || null;
  return partnerUid;
}

/** Send FCM to user by UID. Returns true if sent. */
async function sendFcmToUser(uid, notification, data) {
  const userDoc = await db.collection("users").doc(uid).get();
  const fcmToken = userDoc.exists ? userDoc.data().fcmToken : null;
  if (!fcmToken) return false;
  await admin.messaging().send({
    token: fcmToken,
    notification: notification,
    data: data || {},
    android: { priority: "high" },
    apns: { payload: { aps: { contentAvailable: true } } },
  });
  return true;
}

/** On new haptic signal – send push to partner. */
exports.onHapticSignalCreated = functions.firestore
  .document("couples/{coupleId}/haptic_signals/{signalId}")
  .onCreate(async (snap, context) => {
    const coupleId = context.params.coupleId;
    const data = snap.data();
    const fromUserId = data.fromUserId || "";
    const partnerUid = await getPartnerUid(coupleId, fromUserId);
    if (!partnerUid) return;
    await sendFcmToUser(
      partnerUid,
      { title: "Touch", body: "Your partner touched you" },
      { type: "haptic" }
    );
  });

/** On new quick message – send push to partner. */
exports.onQuickMessageCreated = functions.firestore
  .document("couples/{coupleId}/quick_messages/{messageId}")
  .onCreate(async (snap, context) => {
    const coupleId = context.params.coupleId;
    const data = snap.data();
    const fromUserId = data.fromUserId || "";
    const message = (data.message || "").slice(0, 100);
    const partnerUid = await getPartnerUid(coupleId, fromUserId);
    if (!partnerUid) return;
    await sendFcmToUser(
      partnerUid,
      { title: "Quick Message", body: message || "New message from your partner" },
      { type: "quick_message", message: message }
    );
  });

/** Automatically compress images when uploaded to Storage. */
exports.compressImage = functions.storage.object().onFinalize(async (object) => {
  const filePath = object.name;
  const contentType = object.contentType;
  const bucket = admin.storage().bucket(object.bucket);

  // Only process images
  if (!contentType || !contentType.startsWith("image/")) {
    console.log("Skipping non-image file:", filePath);
    return null;
  }

  // Only process profile pictures and memories
  if (!filePath.startsWith("profile_pictures/") && !filePath.startsWith("memories/")) {
    console.log("Skipping file outside target folders:", filePath);
    return null;
  }

  // Skip if already compressed (has _compressed suffix)
  if (filePath.includes("_compressed")) {
    console.log("Skipping already compressed file:", filePath);
    return null;
  }

  const file = bucket.file(filePath);
  const tempFilePath = `/tmp/${filePath.split("/").pop()}`;
  const tempCompressedPath = `/tmp/compressed_${filePath.split("/").pop()}`;

  try {
    // Download the file to a temporary location
    await file.download({ destination: tempFilePath });

    // Compress the image
    // Settings: max width/height 2048px, quality 85%, convert to JPEG
    await sharp(tempFilePath)
      .resize(2048, 2048, {
        fit: "inside",
        withoutEnlargement: true,
      })
      .jpeg({ quality: 85, mozjpeg: true })
      .toFile(tempCompressedPath);

    // Upload compressed image back to Storage (overwrite original)
    const metadata = {
      contentType: "image/jpeg",
      metadata: {
        originalContentType: contentType,
        compressed: "true",
      },
    };

    await bucket.upload(tempCompressedPath, {
      destination: filePath,
      metadata: metadata,
    });

    console.log("Image compressed successfully:", filePath);
  } catch (error) {
    console.error("Error compressing image:", filePath, error);
    // Don't throw - allow original upload to succeed even if compression fails
  } finally {
    // Clean up temporary files
    const fs = require("fs");
    try {
      if (fs.existsSync(tempFilePath)) fs.unlinkSync(tempFilePath);
      if (fs.existsSync(tempCompressedPath)) fs.unlinkSync(tempCompressedPath);
    } catch (cleanupError) {
      console.error("Error cleaning up temp files:", cleanupError);
    }
  }

  return null;
});

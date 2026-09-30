// One-off script: seeds couples/{coupleId}/usage/current.bytesUsed from the
// real size of existing objects under memories/{coupleId}/.
//
// Run once, against production, BEFORE deploying the storage.rules quota
// check - otherwise existing heavy users would be measured against a false 0.
//
// Usage: GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json \
//   node functions/scripts/backfill-usage.js

const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();
const bucket = admin.storage().bucket();

async function sumCoupleUsage(coupleId) {
  const [files] = await bucket.getFiles({ prefix: `memories/${coupleId}/` });
  return files.reduce((total, file) => total + (Number(file.metadata.size) || 0), 0);
}

async function backfillUsage() {
  const couplesSnap = await db.collection("couples").get();
  console.log(`Found ${couplesSnap.size} couples.`);

  for (const coupleDoc of couplesSnap.docs) {
    const coupleId = coupleDoc.id;
    const bytesUsed = await sumCoupleUsage(coupleId);
    await db
      .collection("couples")
      .doc(coupleId)
      .collection("usage")
      .doc("current")
      .set({ bytesUsed });
    console.log(`${coupleId}: ${bytesUsed} bytes`);
  }

  console.log("Backfill complete.");
}

backfillUsage()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Backfill failed:", error);
    process.exit(1);
  });

const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.getUserByInviteCode = functions.https.onCall(async (data, context) => {
  // Check if the user is authenticated.
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "The function must be called while authenticated."
    );
  }

  const inviteCode = data.inviteCode;
  if (!inviteCode) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "The function must be called with one arguments 'inviteCode'."
    );
  }

  try {
    const usersRef = admin.firestore().collection("users");
    const query = await usersRef
      .where("inviteCode", "==", inviteCode.toUpperCase())
      .limit(1)
      .get();

    if (query.docs.length === 0) {
      return null;
    }

    const userDoc = query.docs[0];
    return userDoc.data();
  } catch (error) {
    throw new functions.https.HttpsError("internal", error.message, error.details);
  }
});

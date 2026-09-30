#!/usr/bin/env node
/**
 * Seeds the LOCAL Firebase Emulator Suite with a paired demo couple and
 * realistic fake data (memories with photos, events, notes, tracker, cycle).
 *
 * Never touches production: it refuses to run unless the emulator env vars
 * are set. Usage (emulators must be running: `firebase emulators:start`):
 *
 *   FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 \
 *   FIREBASE_AUTH_EMULATOR_HOST=127.0.0.1:9099 \
 *   FIREBASE_STORAGE_EMULATOR_HOST=127.0.0.1:9199 \
 *   node scripts/seed_local_demo.js
 *
 * Demo logins (emulator only):  tomas@demo.dyos / adela@demo.dyos  —  password demo1234
 * Pairing goes through the real `pairWithInviteCode` Cloud Function.
 */
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const admin = require('../functions/node_modules/firebase-admin');

const PROJECT = 'dyos-520c2';
const BUCKET = 'dyos-520c2.firebasestorage.app';
const PHOTOS = process.env.DEMO_PHOTOS || path.join(__dirname, '../../marketing/demo/photos');
// Host the *app* uses to fetch photos (10.0.2.2 = host machine from the Android emulator).
const APP_STORAGE_HOST = process.env.DEMO_STORAGE_HOST || '10.0.2.2:9199';
const PASSWORD = 'demo1234';

for (const v of ['FIRESTORE_EMULATOR_HOST', 'FIREBASE_AUTH_EMULATOR_HOST', 'FIREBASE_STORAGE_EMULATOR_HOST']) {
  if (!process.env[v]) {
    console.error(`Refusing to run: ${v} is not set (this script is emulator-only).`);
    process.exit(1);
  }
}

admin.initializeApp({ projectId: PROJECT, storageBucket: BUCKET });
const db = admin.firestore();
const auth = admin.auth();
const bucket = admin.storage().bucket();
const ts = (d) => admin.firestore.Timestamp.fromDate(d);
const daysAgo = (n, h = 20, m = 0) => {
  const d = new Date();
  d.setDate(d.getDate() - n);
  d.setHours(h, m, 0, 0);
  return d;
};
const daysAhead = (n, h = 18) => daysAgo(-n, h);

// The app's Freezed models read a required `id` field stored inside each doc.
async function addDoc(col, data) {
  const ref = col.doc();
  await ref.set({ id: ref.id, ...data });
  return ref;
}

async function mkUser(email, displayName, inviteCode, status) {
  try { await auth.deleteUser((await auth.getUserByEmail(email)).uid); } catch (_) { /* new */ }
  const u = await auth.createUser({ email, password: PASSWORD, displayName, emailVerified: true });
  await db.collection('users').doc(u.uid).set({
    email, displayName, inviteCode, coupleId: null,
    status, createdAt: ts(daysAgo(420)),
  });
  return u.uid;
}

async function idTokenFor(email) {
  const host = process.env.FIREBASE_AUTH_EMULATOR_HOST;
  const r = await fetch(`http://${host}/identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=fake`, {
    method: 'POST', headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ email, password: PASSWORD, returnSecureToken: true }),
  });
  return (await r.json()).idToken;
}

async function pair(email, inviteCode) {
  const token = await idTokenFor(email);
  const r = await fetch(`http://127.0.0.1:5001/${PROJECT}/us-central1/pairWithInviteCode`, {
    method: 'POST',
    headers: { 'content-type': 'application/json', authorization: `Bearer ${token}` },
    body: JSON.stringify({ data: { inviteCode } }),
  });
  const body = await r.json();
  if (!r.ok || body.error) throw new Error('pair failed: ' + JSON.stringify(body));
  return body.result;
}

async function upload(coupleId, file, i) {
  const buf = fs.readFileSync(path.join(PHOTOS, file));
  const dest = `memories/${coupleId}/seed_${Date.now()}_${i}.jpg`;
  const tok = crypto.randomUUID();
  await bucket.file(dest).save(buf, {
    contentType: 'image/jpeg',
    metadata: { metadata: { firebaseStorageDownloadTokens: tok, compressed: 'true' } },
  });
  return `http://${APP_STORAGE_HOST}/v0/b/${BUCKET}/o/${encodeURIComponent(dest)}?alt=media&token=${tok}`;
}

async function resetEmulators() {
  // Emulator-only REST endpoints: wipe Firestore + Auth so the seed is repeatable.
  await fetch(`http://${process.env.FIRESTORE_EMULATOR_HOST}/emulator/v1/projects/${PROJECT}/databases/(default)/documents`, { method: 'DELETE' });
  await fetch(`http://${process.env.FIREBASE_AUTH_EMULATOR_HOST}/emulator/v1/projects/${PROJECT}/accounts`, { method: 'DELETE' });
}

(async () => {
  await resetEmulators();
  // Questionnaire content (normally seeded once into production by seed_blueprint_sections.js).
  const sections = JSON.parse(fs.readFileSync(path.join(__dirname, 'blueprint_sections_seed.json'), 'utf8'));
  for (const { id, ...data } of sections) await db.collection('blueprint_sections').doc(id).set(data);
  const tomas = await mkUser('tomas@demo.dyos', 'Alex', 'TOMAS-4821', { emoji: '☕', text: 'Making us coffee' });
  const adela = await mkUser('adela@demo.dyos', 'Mia', 'ADELA-7305', { emoji: '📚', text: 'Reading by the window' });

  const paired = await pair('adela@demo.dyos', 'TOMAS-4821');
  const coupleId = paired?.coupleId || (await db.collection('users').doc(tomas).get()).data().coupleId;
  if (!coupleId) throw new Error('No coupleId after pairing');
  console.log('paired, coupleId =', coupleId);

  const couple = db.collection('couples').doc(coupleId);
  await couple.set({
    anniversaryDate: ts(new Date(new Date().getFullYear() - 2, 10, 14)),
    xp: 1340,
    status: {
      [tomas]: { emoji: '☕', text: 'Making us coffee', updatedAt: ts(daysAgo(0, 8)) },
      [adela]: { emoji: '📚', text: 'Reading by the window', updatedAt: ts(daysAgo(0, 9)) },
    },
    completedBlueprintSections: [],
    questXpLastGrantedAt: {},
  }, { merge: true });

  // ---- memories with photos ----
  const mem = [
    ['couple_sofa.jpg', 'Sunday night in. Nothing happened and it was perfect.', 'dailyLife', 6, { name: 'Home', lat: 40.7128, lng: -74.0060 }, tomas],
    ['trip_mountains.jpg', 'Blue Ridge hike. Mia said she was done. Then she reached the top first.', 'trip', 21, { name: 'Blue Ridge Mountains', lat: 35.7596, lng: -82.2651 }, adela],
    ['hug.jpg', 'A long hug after a long week.', 'milestone', 33, { name: 'Brooklyn', lat: 40.6782, lng: -73.9442 }, tomas],
    ['trip_sunset.jpg', 'The sunset we missed on camera, so I am painting it.', 'nature', 48, { name: 'Central Park', lat: 40.7829, lng: -73.9654 }, adela],
    ['highfive.jpg', 'We both ordered the same thing. After 30 minutes of deciding.', 'funny', 60, { name: 'Home', lat: 40.7128, lng: -74.0060 }, tomas],
    ['trip_sea.jpg', 'Our first trip together. Amalfi Coast.', 'trip', 130, { name: 'Amalfi Coast', lat: 40.6340, lng: 14.6027 }, adela],
    ['laugh.jpg', 'Who laughed more? Nobody won.', 'funny', 190, { name: 'Home', lat: 40.7128, lng: -74.0060 }, tomas],
    ['cuddle.jpg', 'Blanket, movie and tea. Holiday mood already in November.', 'dateNight', 250, { name: 'Home', lat: 40.7128, lng: -74.0060 }, adela],
    ['smile_phone.jpg', 'Alex remembered our anniversary. Almost.', 'milestone', 320, { name: 'Brooklyn', lat: 40.6782, lng: -73.9442 }, adela],
    ['hike_photo.jpg', 'Our first hike. We had no idea how it would end.', 'trip', 410, { name: 'Yosemite', lat: 37.8651, lng: -119.5383 }, tomas],
  ];
  let i = 0;
  for (const [file, caption, category, ago, location, author] of mem) {
    const url = await upload(coupleId, file, i++);
    await addDoc(couple.collection('memories'), {
      pairId: coupleId, authorId: author, mediaUrls: [url], caption,
      date: ts(daysAgo(ago, 18)), category, location, createdAt: ts(daysAgo(ago, 21)),
    });
  }

  // ---- events ----
  const events = [
    ['Anniversary, two years', new Date(new Date().getFullYear(), 10, 14, 18)],
    ['Concert downtown', daysAhead(9)],
    ['Weekend getaway', daysAhead(17)],
    ["Mia's birthday", new Date(new Date().getFullYear(), 11, 3, 18)],
    ['Christmas Eve', new Date(new Date().getFullYear(), 11, 24, 17)],
    ['First date (coffee shop)', daysAgo(700)],
  ];
  for (const [title, date] of events) {
    await addDoc(couple.collection('events'), { title, date: ts(date) });
  }

  // ---- notes ----
  const notes = [
    ['shared', 'Weekend groceries', 'Coffee, avocado, bagels, cheese. And those cookies you love.', tomas],
    ['shared', 'Things to try', 'Skiing, a cooking class, a weekend in the mountains with no signal.', adela],
    ['bucketList', 'Bucket list', 'Watch the sunrise from a mountain top', tomas],
    ['bucketList', 'Bucket list', 'Road trip through Italy', adela],
    ['bucketList', 'Bucket list', 'Learn to dance salsa together', adela],
    ['bucketList', 'Bucket list', 'Adopt a rescue pet', tomas],
    ['private', 'Just for me', 'Remind myself to tell Mia how much I appreciate her.', tomas],
    ['secretGift', 'Secret gift', 'Photo book of our trips. Order by Dec 10.', tomas],
  ];
  for (const [type, title, content, authorId] of notes) {
    await addDoc(couple.collection('notes'), { type, title, content, authorId, createdAt: ts(daysAgo(Math.floor(Math.random() * 30), 12)) });
  }

  // ---- tracker (tasteful) ----
  const logs = [[2, 5, ['Romantic', 'Evening']], [5, 4, ['Morning']], [9, 5, ['Romantic', 'Massage']], [14, 4, ['Evening']], [19, 5, ['Romantic']], [27, 4, ['Morning']], [33, 5, ['Evening', 'Massage']], [41, 4, ['Romantic']]];
  for (const [ago, rating, tags] of logs) {
    await addDoc(couple.collection('intimacy_logs'), {
      date: ts(daysAgo(ago, 22)), initiatorId: ago % 2 ? tomas : adela, rating, tags, positions: [],
      userOrgasmCount: 1, partnerOrgasmCount: 1, duration: 30 + ago % 3 * 15, protectionUsed: ago % 3 !== 0,
    });
  }

  // ---- cycle ----
  await couple.collection('cycle_settings').doc('settings').set({
    id: 'settings', averageCycleLength: 28, periodLength: 5, lastPeriodDate: ts(daysAgo(20)),
    isTryingToConceive: false, hideMenstruation: false,
  });
  const flows = ['medium', 'heavy', 'medium', 'light', 'light'];
  const moods = ['sensitive', 'irritable', 'sensitive', 'happy', 'energetic'];
  for (let k = 0; k < 5; k++) {
    await addDoc(couple.collection('cycle_logs'), { date: ts(daysAgo(20 - k, 9)), flowIntensity: flows[k], mood: moods[k], notes: k === 1 ? 'Tea and a blanket.' : null });
  }

  console.log('Seed done. Logins: tomas@demo.dyos / adela@demo.dyos, password', PASSWORD);
  process.exit(0);
})().catch((e) => { console.error(e); process.exit(1); });

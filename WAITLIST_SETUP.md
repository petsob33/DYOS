# Waitlist Setup Instructions

> **Pro nasazení na Firebase Hosting, viz [DEPLOY.md](./DEPLOY.md)**

## Firebase Web Configuration

To get your Firebase web configuration:

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `dyos-520c2`
3. Click the gear icon ⚙️ next to "Project Overview"
4. Select "Project settings"
5. Scroll down to "Your apps" section
6. If you don't have a web app, click "Add app" and select the web icon `</>`
7. Copy the config object and update `index.html` with your values:

```javascript
const firebaseConfig = {
  apiKey: "YOUR_API_KEY",
  authDomain: "dyos-520c2.firebaseapp.com",
  projectId: "dyos-520c2",
  storageBucket: "dyos-520c2.firebasestorage.app",
  messagingSenderId: "112080403338",
  appId: "YOUR_WEB_APP_ID"
};
```

## Deploy Firestore Rules

After updating `firestore.rules`, deploy them:

```bash
firebase deploy --only firestore:rules
```

Or if you don't have Firebase CLI installed:

```bash
npm install -g firebase-tools
firebase login
firebase deploy --only firestore:rules
```

## View Waitlist Emails

To view the collected emails:

1. Go to Firebase Console
2. Navigate to Firestore Database
3. Open the `waitlist` collection
4. Each document ID is the normalized email address
5. Documents contain: email, createdAt, source, timestamp

### Export Emails (via Firebase Console)

1. In Firestore, select the `waitlist` collection
2. Use the Export function (if available) or manually view/export

### Export Emails (via Script)

Create a simple Node.js script to export:

```javascript
const admin = require('firebase-admin');
const fs = require('fs');

// Initialize with service account
const serviceAccount = require('./path-to-service-account-key.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function exportWaitlist() {
  const snapshot = await db.collection('waitlist').get();
  const emails = [];
  
  snapshot.forEach(doc => {
    emails.push({
      email: doc.id,
      ...doc.data()
    });
  });
  
  fs.writeFileSync('waitlist-export.json', JSON.stringify(emails, null, 2));
  console.log(`Exported ${emails.length} emails to waitlist-export.json`);
  
  // Also create CSV
  const csv = emails.map(e => `${e.email},${e.createdAt?.toDate() || ''},${e.timestamp || ''}\n`).join('');
  fs.writeFileSync('waitlist-export.csv', 'Email,Created At,Timestamp\n' + csv);
  console.log('Also exported to waitlist-export.csv');
}

exportWaitlist();
```

## Testing

1. Open `index.html` in a browser
2. Enter an email and click "Join Waitlist"
3. Check Firebase Console > Firestore > waitlist collection
4. You should see a new document with the email as ID

## Security Notes

- Firestore rules allow anyone to CREATE waitlist entries (no auth required)
- READ access is denied for client-side (only admins can read via backend)
- Email is normalized (lowercase) and used as document ID to prevent duplicates
- Each document stores: email, createdAt (server timestamp), source, timestamp, userAgent

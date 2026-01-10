#!/usr/bin/env node

/**
 * Export waitlist emails from Firestore
 * 
 * Usage:
 *   node scripts/export-waitlist.js [output-format]
 * 
 * Output formats: json (default), csv, txt
 * 
 * Requirements:
 *   1. Firebase Admin SDK: npm install firebase-admin
 *   2. Service account key from Firebase Console
 *      Project Settings > Service Accounts > Generate new private key
 */

const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// Get output format from command line argument
const outputFormat = process.argv[2] || 'json';

// Initialize Firebase Admin
// Option 1: Use service account key file
// Uncomment and update path to your service account key
/*
const serviceAccount = require('../path-to-service-account-key.json');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});
*/

// Option 2: Use environment variable
// Set GOOGLE_APPLICATION_CREDENTIALS environment variable
// export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service-account-key.json"
if (!admin.apps.length) {
  try {
    admin.initializeApp();
  } catch (error) {
    console.error('Error initializing Firebase Admin:', error.message);
    console.error('\nPlease either:');
    console.error('1. Set GOOGLE_APPLICATION_CREDENTIALS environment variable');
    console.error('2. Or uncomment and configure serviceAccount in this script');
    process.exit(1);
  }
}

const db = admin.firestore();

async function exportWaitlist() {
  try {
    console.log('Fetching waitlist emails from Firestore...');
    const snapshot = await db.collection('waitlist').orderBy('createdAt', 'desc').get();
    
    if (snapshot.empty) {
      console.log('No emails found in waitlist.');
      return;
    }

    const emails = [];
    snapshot.forEach(doc => {
      const data = doc.data();
      emails.push({
        email: doc.id,
        createdAt: data.createdAt?.toDate?.()?.toISOString() || data.createdAt || 'N/A',
        timestamp: data.timestamp || 'N/A',
        source: data.source || 'N/A',
        userAgent: data.userAgent || 'N/A'
      });
    });

    console.log(`Found ${emails.length} email(s)`);

    // Export based on format
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-').slice(0, -5);
    
    switch (outputFormat.toLowerCase()) {
      case 'csv':
        exportCSV(emails, timestamp);
        break;
      case 'txt':
        exportTXT(emails, timestamp);
        break;
      case 'json':
      default:
        exportJSON(emails, timestamp);
        break;
    }

    console.log(`\n✅ Export complete!`);
  } catch (error) {
    console.error('Error exporting waitlist:', error);
    process.exit(1);
  }
}

function exportJSON(emails, timestamp) {
  const filename = `waitlist-export-${timestamp}.json`;
  fs.writeFileSync(filename, JSON.stringify(emails, null, 2));
  console.log(`\nExported to: ${filename}`);
}

function exportCSV(emails, timestamp) {
  const filename = `waitlist-export-${timestamp}.csv`;
  const headers = 'Email,Created At,Timestamp,Source,User Agent\n';
  const rows = emails.map(e => {
    // Escape commas and quotes in CSV
    const escapeCSV = (str) => `"${String(str).replace(/"/g, '""')}"`;
    return [
      escapeCSV(e.email),
      escapeCSV(e.createdAt),
      escapeCSV(e.timestamp),
      escapeCSV(e.source),
      escapeCSV(e.userAgent)
    ].join(',');
  }).join('\n');
  
  fs.writeFileSync(filename, headers + rows);
  console.log(`\nExported to: ${filename}`);
}

function exportTXT(emails, timestamp) {
  const filename = `waitlist-export-${timestamp}.txt`;
  const content = emails.map((e, index) => 
    `${index + 1}. ${e.email}\n   Created: ${e.createdAt}`
  ).join('\n\n');
  
  fs.writeFileSync(filename, `Waitlist Export - ${new Date().toISOString()}\n`);
  fs.appendFileSync(filename, `Total: ${emails.length} emails\n\n`);
  fs.appendFileSync(filename, content);
  console.log(`\nExported to: ${filename}`);
}

// Run export
exportWaitlist();

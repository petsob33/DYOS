// Firebase Cloud Messaging service worker.
//
// This runs independently of the Flutter app and is what lets browser push
// notifications arrive when the DYOS tab isn't open (background tab, browser
// minimized, or fully closed on platforms that keep the service worker
// registered, e.g. desktop Chrome/Edge/Firefox and Android Chrome).
//
// Registered automatically by the firebase_messaging_web plugin - it must
// live at web/firebase-messaging-sw.js (copied to build/web/ on `flutter
// build web`) so it's served from the site root.
importScripts('https://www.gstatic.com/firebasejs/10.13.2/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.13.2/firebase-messaging-compat.js');

// Same values as lib/firebase_options.dart (DefaultFirebaseOptions.web) -
// public web config, safe to ship client-side.
firebase.initializeApp({
  apiKey: 'AIzaSyAogCPm1zPJ6y8eYF25mAIy6c6HO1Ycg6A',
  appId: '1:112080403338:web:fccb37953fd8f13669a673',
  messagingSenderId: '112080403338',
  projectId: 'dyos-520c2',
  authDomain: 'dyos-520c2.firebaseapp.com',
  storageBucket: 'dyos-520c2.firebasestorage.app',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  const title = (payload.notification && payload.notification.title) || 'DYOS';
  const body = (payload.notification && payload.notification.body) || '';

  self.registration.showNotification(title, {
    body,
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    data: payload.data || {},
  });
});

self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then((windowClients) => {
      for (const client of windowClients) {
        if ('focus' in client) return client.focus();
      }
      if (clients.openWindow) return clients.openWindow('/');
    }),
  );
});

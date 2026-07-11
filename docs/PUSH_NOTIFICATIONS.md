# Push oznámení (mimo aplikaci)

Aplikace používá **Firebase Cloud Messaging (FCM)** pro doručování oznámení, i když je aplikace na pozadí nebo zavřená.

## Co je implementováno

- **FCM token** se ukládá do Firestore (`users/{uid}.fcmToken`) po přihlášení a při každé obnově tokenu.
- **Cloud Functions** při vytvoření záznamu v `haptic_signals` nebo `quick_messages` odešlou push partnerovi.
- **Foreground**: příchozí zpráva se zobrazí jako lokální notifikace.
- **Background / ukončená aplikace**: systém zobrazí notifikaci z FCM (payload s `notification.title` a `notification.body`).

## Nastavení

### Android

- V projektu je `google-services.json`; FCM funguje s výchozí konfigurací.
- Pro Android 13+ se oprávnění k notifikacím žádá přes `permission_handler` při prvním otevření obrazovky s notifikacemi.

### iOS

1. V Xcode: **Signing & Capabilities** → přidat **Push Notifications**.
2. V Apple Developer: vytvořit **Key** pro Apple Push Notifications (APNs) a nahrát ji do Firebase Console (Project Settings → Cloud Messaging → Apple app configuration).
3. První spuštění: uživatel musí povolit notifikace (volá se `FirebaseMessaging.instance.requestPermission()`).

### Web (prohlížeč)

Aby oznámení chodila i do prohlížeče (a to i když je karta na pozadí nebo je
prohlížeč zavřený, dokud běží na pozadí systému), je potřeba:

1. **Vygenerovat VAPID klíč** ve Firebase Console: Project settings → Cloud
   Messaging → záložka "Web configuration" → "Web Push certificates" →
   Generate key pair.
2. Vloženou hodnotu (public key) dát do
   `lib/firebase_options.dart` → `DefaultFirebaseOptions.webPushVapidKey`
   (nahradit placeholder `REPLACE_WITH_VAPID_KEY_FROM_FIREBASE_CONSOLE`).
   Je to veřejný klíč, není to tajemství, takže může být v klientském kódu.
3. Deploynout web build (`flutter build web` → `firebase deploy --only
   hosting`) - `web/firebase-messaging-sw.js` se zkopíruje do `build/web/` a
   Firebase SDK ho automaticky zaregistruje jako service worker při prvním
   načtení stránky.
4. Uživatel musí v prohlížeči povolit oznámení (vyskočí prompt při prvním
   spuštění, stejně jako na mobilu).

Bez nastaveného VAPID klíče `NotificationService` na webu tiše přeskočí
registraci FCM tokenu (viz `_saveFcmTokenIfLoggedIn` v
`notification_service.dart`) - aplikace dál funguje, jen web push nechodí.

Poznámka: doručení „i když je prohlížeč úplně zavřený" závisí na OS a
prohlížeči - service worker se probouzí přes systémovou push službu
(FCM/APNs pod kapotou), takže to funguje bez otevřené karty, ale ne bez
nainstalovaného/spuštěného prohlížeče/zařízení (typicky funguje na desktop
Chrome/Edge/Firefox i na Androidu; na iOS Safari vyžaduje PWA přidanou na
plochu kvůli Apple omezením pro web push).

### Cloud Functions

Nasazení funkcí, které posílají push:

```bash
cd functions
npm install
firebase deploy --only functions
```

Funkce:

- `onHapticSignalCreated` – při novém haptic signálu odešle partnerovi „Your partner touched you“.
- `onQuickMessageCreated` – při nové quick message odešle partnerovi text zprávy.

## Testování

1. Přihlásit se na dvou zařízeních (nebo emulátor + zařízení) s různými účty v páru.
2. Na jednom zařízení odeslat haptic nebo quick message.
3. Na druhém zařízení **minimalizovat nebo zavřít aplikaci** – během chvíle by měla přijít push notifikace.

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

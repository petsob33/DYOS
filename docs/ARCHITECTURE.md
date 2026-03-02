# DYOS – Architektura a technická dokumentace

Popisuje Auth, Pairing, Router, Firebase schéma a RevenueCat.

---

## 1. Auth (přihlášení a registrace)

- **Implementace:** `lib/features/auth/` (presentation: `LoginScreen`, `RegisterScreen`; data: `UserRepository`, `AuthService`).
- **Backend:** Firebase Auth (email+heslo, Google Sign-In).
- **Tok:**
  1. Uživatel se přihlásí nebo zaregistruje.
  2. Po úspěchu se načte/ vytvoří dokument `users/{uid}` ve Firestore (`FirebaseService.createOrUpdateUser`).
  3. Pokud uživatel nemá `coupleId`, router přesměruje na `/pairing`.
  4. Pokud má `coupleId`, přístup do shellu (`/home`, `/memory`, `/data`, `/cycle`).
- **Stav uživatele:** Řízen přes Riverpod (`authStateProvider`, `userProvider`). Router sleduje auth a `userProvider` a podle toho redirectuje.

---

## 2. Pairing (párování)

- **Účel:** Propojit dva účty do jednoho „páru“ (couple). Všechna sdílená data (memories, notes, events, …) jsou vázaná na `coupleId`.
- **Implementace:** `PairingScreen`, `FirebaseService.pairUsers`, `findUserByInviteCode`.
- **Tok:**
  1. Uživatel A po přihlášení nemá `coupleId` → přijde na Pairing.
  2. A vytvoří pár → vytvoří se dokument `couples/{coupleId}` s `members: [uidA, uidB_placeholder]` (nebo jen A), A dostane **invite kód** (např. `PETR-8821`), uložený v `users/{uidA}.inviteCode`.
  3. Uživatel B se přihlásí, přijde na Pairing, zadá A-invite kód.
  4. Aplikace najde A podle `inviteCode`, vytvoří/aktualizuje pár s `members: [uidA, uidB]`, oběma uživatelům nastaví `users/{uid}.coupleId = coupleId`.
- **Firestore pravidla:** Uživatel může měnit u `users/{userId}` jen svůj dokument; výjimka je zápis pouze do pole `coupleId` (pro dokončení párování druhým uživatelem). Toto pravidlo je citlivé z hlediska zneužití – viz `docs/APP_REPORT_CRITICAL.md`.
- **Modely:** `UserModel` (uid, email, displayName, photoUrl, inviteCode, coupleId, …), `CoupleModel` (id, members, anniversaryDate, subscriptionTier, status, …).

---

## 3. Router (navigace)

- **Implementace:** `lib/core/router/app_router.dart`, GoRouter, generovaný `app_router.g.dart`.
- **Vstupní route:** `initialLocation: '/login'`.
- **Veřejné route (bez auth):** `/login`, `/register`. V **debug** buildu také `/firebase-test` (test Firebase připojení).
- **Route vyžadující auth, ale ne pairing:** `/pairing`.
- **Chráněné route (auth + coupleId):** vše ostatní včetně shellu.
- **Shell (StatefulShellRoute):** 4 větve – `/home` (HomeScreen), `/memory` (TimelineScreen), `/data` (DataScreen), `/cycle` (CycleTrackingScreen). Střední FAB otevírá Quick Add sheet (poznámka, memory, intimita, event).
- **Důležité jednorázové route:** `/add-memory`, `/memory/detail`, `/memory/map`, `/add-note`, `/events`, `/lists`, `/secret-notes`, `/intimacy-history`, `/profile`, `/premium`, `/blueprints`, `/blueprint/:sectionId`, `/level`, `/settings`, `/edit-profile-picture`, atd.
- **Redirect logika:** Není-li uživatel přihlášen → `/login`. Je-li přihlášen, ale nemá `coupleId` → `/pairing`. Má pár a je na veřejné/pairing route → `/home`.

---

## 4. Firebase schéma (Firestore + Storage)

### 4.1 Firestore

- **`users/{userId}`**  
  Profil uživatele: email, displayName, photoUrl, inviteCode, **coupleId**, dateOfBirth, status, createdAt. Čtení: přihlášený uživatel. Zápis: vlastník; nebo kdokoli přihlášený jen pro pole `coupleId` (párování).

- **`couples/{coupleId}`**  
  Pár: `members` (pole UID), anniversaryDate, subscriptionTier, subscriptionExpiry, status (mapa UID → emoji + text), xp, blueprintAnswers, completedBlueprintSections, questXpLastGrantedAt. Čtení/zápis jen pro členy páru. Delete zakázán.

- **Subkolekce pod `couples/{coupleId}`:**
  - **`memories/{memoryId}`** – vzpomínky (autor, datum, lokace, kategorie, media URLs). Delete jen autor.
  - **`intimacy_logs/{logId}`** – záznamy intimity (initiatorId, hodnocení, tagy, …).
  - **`notes/{noteId}`** – poznámky (typ: shared, private, bucketList, secretGift). Delete jen autor.
  - **`events/{eventId}`** – události (výročí, schůzky).
  - **`cycle_logs/{logId}`** – záznamy cyklu (flow, nálada).
  - **`cycle_settings/{settingsId}`** – nastavení cyklu. Delete zakázán.
  - **`haptic_signals/{signalId}`** – haptická „ťuknutí“ od partnera.
  - **`quick_messages/{messageId}`** – rychlé zprávy (notifikace).

- **`waitlist/{emailId}`**  
  Waitlist (email jako ID). Create: kdokoli, pokud data.email == emailId. Get: jen přihlášení uživatelé. List/update/delete: zakázány.

### 4.2 Storage

- **`memories/{coupleId}/{fileName}`** – obrázky/videa vzpomínek. Čtení/zápis/smazání jen pro členy páru. Max 10 MB, povolené typy image/*, video/* a přípony jpg, jpeg, png, gif, webp, mp4, mov, avi.
- **`profile_pictures/{userId}/{fileName}`** – profilové fotky. Čtení: přihlášený uživatel. Zápis/smazání: jen vlastník (userId == auth.uid). Max 2 MB, image/* nebo jpg, jpeg, png, gif, webp.

Pravidla: `firestore.rules`, `storage.rules`.

---

## 5. RevenueCat (premium)

- **Účel:** Jedna brána pro předplatné (iOS + Android). Po nákupu se stav předplatného zapisuje do Firestore, aby oba partneři měli premium.
- **Implementace:** `lib/features/premium/` (PurchaseService, paywall, premium_provider). RevenueCat SDK: `purchases_flutter`.
- **Konfigurace:** API klíč přes `--dart-define=REVENUECAT_API_KEY=...`. V `main.dart` se při startu volá `Purchases.configure(...)`; pokud je klíč prázdný, konfigurace se přeskočí.
- **Tok nákupu:**
  1. Uživatel na Premium stránce vybere plán (monthly/yearly) z RevenueCat Offerings.
  2. `PurchaseService.purchaseProduct(storeProduct)` zavolá RevenueCat.
  3. Po úspěchu `_syncCustomerInfoToFirestore` načte `coupleId` z Firestore a zavolá `FirebaseService.updateCoupleSubscription(coupleId, 'premium', expirationDate)`.
  4. Do `couples/{coupleId}` se zapíše `subscriptionTier: 'premium'` a `subscriptionExpiry`.
  5. Oba partneři sledují `coupleProvider` → okamžitě vidí `isPremium == true`.
- **Entitlement ID:** V kódu je `premiumEntitlementId = 'premium'`; v RevenueCat dashboardu musí být entitlement s identifikátorem `premium` a k němu přiřazené produkty/offerings.
- **Dokumentace:** Viz `docs/REVENUECAT_REAL_PURCHASES.md`.

---

## 6. Další služby

- **Notifikace:** FCM + Flutter Local Notifications. Token se ukládá do Firestore (uživatel). Haptic a Quick Message vyvolají lokální notifikaci a/nebo FCM.
- **Profilová fotka:** Upload do Storage `profile_pictures/{userId}/{fileName}` přes `StorageService.uploadProfilePicture`. Storage pravidla viz výše.
- **Google Places (iOS):** API klíč se bere z `GOOGLE_PLACES_API_KEY` v `Info.plist` (hodnota z `Secrets.xcconfig`). Viz `ios/Runner/Secrets.xcconfig.example` a `docs/ANDROID_GOOGLE_API_KEY.md`.

---

## 7. Level systém (Soul Points / XP)

- **Cíl:** Jeden společný „level“ pro pár, který roste podle aktivit (vzpomínky, intimita, události, blueprints) a odemyká vizuální i funkční odměny.
- **Datový model:**
  - Hodnota SP/XP je uložena v `couples/{coupleId}.xp` (čisté `int`, sdílené pro oba).
  - Stream páru (`coupleProvider`) → `currentXpProvider` → číslo SP v UI.
- **Fáze („OS verze“):** Definované v `ProgressionPlan.phases` (`progression_plan.dart`):
  - `Boot Sequence` (0–1000 SP) → v1.0
  - `Local Network` (1000–5000 SP) → v2.0 (Connected)
  - `Cloud Sync` (5000–20000 SP) → v3.0 (Synchronized)
  - `Mainframe` (20000–100000 SP) → v4.0 (Mainframe)
  - `Singularity` (100000+) → Endgame
- **Odvozené hodnoty (LevelManager + ProgressionPlan):**
  - Aktuální fáze: `phaseForSp(sp)`
  - Progress v rámci fáze: `progressInPhase(sp)` (0.0–1.0)
  - Verze string: `versionStringForSp(sp)` → např. `"v2.0"`
  - SP do další fáze: `spToNextPhase(sp)` + `currentPhaseMaxSp(sp)` + `nextPhaseVersionLabel(sp)`
- **Milníky a odměny:**
  - `ProgressionPlan.milestones` – seznam milestone (SP threshold + typ):
    - `MilestoneType.levelUp` – přechod na novou „OS verzi“.
    - `MilestoneType.reward` – odměna (badge, widget, dark mode, taptic, blueprint pack, map view, premium trial, chat wallpapers, lifetime license…).
  - Každý milestone má `spRequired`, `title`, `description`, volitelně `rewardKind` a `emoji`.
  - API:
    - `nextMilestone(sp)` – další nedosažený milník.
    - `isMilestoneUnlocked(sp, spRequired)` – jestli je odměna odemčená.
    - `nextRewardTip(sp)` – krátký text pro UI („Next: X at Y SP“).
- **Získávání SP:**
  - Základ: `FirebaseService.addCoupleXp(coupleId, amount)` a `setQuestXpGrantedAt`.
  - Helper v prezentaci: `addCoupleXp(ref, amount)` + `grantQuestXpIfEligible(ref, questId, amount)` v `user_stats_provider.dart`.
  - Denní questy v `LevelScreen`:
    - `questId: 'blueprint'` – „Complete a Blueprint section“ → +100 SP (max 1× denně, sdíleno pro všechny blueprint questy `blueprint_*`).
    - `questId: 'memory'` – „Add a memory“ → +25 SP.
    - `questId: 'event'` – „Add an event“ → +15 SP.
    - `questId: 'intimacy'` – „Log intimacy“ → +20 SP.
  - Dny se sledují v `couples/{id}.questXpLastGrantedAt` (mapa `questId` → `YYYY-MM-DD`).
- **UI napojení:**
  - `LevelScreen` – hlavní obrazovka levelu:
    - hero karta s názvem fáze, emoji, verzí, textem „Collect X SP to get to vY“ a aktuálním počtem SP,
    - `_TierStepper` – pruh s verzemi v1.0–v4.0+Singularity,
    - `_MilestonesList` – seznam všech milníků jako vertikální timeline,
    - blok „Complete tasks & win rewards“ – denní questy.
  - `SystemStatusCard` – Bento karta (např. na Home):
    - „Current Version: vX.Y“, progress bar v aktuální fázi,
    - text „currentSP / targetSP SP to nextVersion“ nebo „SP · Max level“,
    - `nextRewardTip(sp)` jako text „Next reward“.

---

## 8. Premium model (DYOS+)

- **Cíl:** Jedno předplatné (`DYOS+`) pro celý pár. RevenueCat je zdroj pravdy o nákupech, Firestore ukládá zjednodušený stav (`subscriptionTier`, `subscriptionExpiry`) pro pár.
- **Stav v Firestore:**
  - `couples/{coupleId}.subscriptionTier` – `'free'` nebo `'premium'`.
  - `couples/{coupleId}.subscriptionExpiry` – datum konce předplatného (nebo `null` u lifetime).
  - Getter `CoupleModel.isPremium` vrací `true`, pokud:
    - `subscriptionTier == 'premium'` **a**
    - `subscriptionExpiry` je `null` nebo v budoucnosti.
- **Stav v aplikaci:**
  - `isPremiumProvider` (Riverpod) čte `coupleProvider` a převádí `CoupleModel.isPremium` na `AsyncValue<bool>`.
  - Všechny prémiové části UI by měly používat `isPremiumProvider` jako jediný zdroj pravdy.
- **Integrace s RevenueCat (`PurchaseService`):**
  - `getOfferings()` → `Purchases.getOfferings()` – načte měsíční/roční plány (`Offerings.current.monthly/annual`).
  - `purchaseProduct(storeProduct)`:
    1. Zavolá `Purchases.purchase(PurchaseParams.storeProduct(storeProduct))`.
    2. Z `CustomerInfo` vezme entitlement `premium` (`premiumEntitlementId = 'premium'`).
    3. Pokud je entitlement aktivní, načte `currentUser` z Firebase Auth a jeho `coupleId` (`FirebaseService.getUserData()`).
    4. Zavolá `FirebaseService.updateCoupleSubscription(coupleId, 'premium', expirationDate)`.
  - `restorePurchases()`:
    1. `Purchases.restorePurchases()` → `CustomerInfo`.
    2. Stejný `_syncCustomerInfoToFirestore` jako u purchase.
- **UX – prémiové obrazovky:**
  - `PremiumLandingScreen` (`/premium`):
    - Když `isPremium == true` → jednoduchá potvrzovací obrazovka („You have DYOS+“).
    - Když `isPremium == false` →
      - hero karta s DYOS+,
      - karta „Okamžité benefity“ (texty z `PremiumCopy.instantBenefits`),
      - výpis plánů z RevenueCat (měsíční/roční),
      - CTA „Get DYOS+ now“ → `purchaseService.purchaseProduct(...)`,
      - „Restore“ odkaz → `purchaseService.restorePurchases()`.
  - `PaywallModal` – tmavý modal paywall:
    - otevírá se jako bottom sheet přes `PaywallModal.show(context, ref)`,
    - uvnitř má stejný princip: načtení offerings, karty s plány, `purchase` a `restore` tlačítka.
- **Vztah level systému a premium:**
  - V `ProgressionPlan.functionalRewardKinds` jsou definované **funkční** odměny (widget, taptic, blueprintPack, mapView).
  - `isFeatureUnlocked(RewardKind kind, int currentSp, bool isPremium)` vrací `true`, pokud:
    - uživatel má aktivní **premium** a reward je funkční **→ vždy odemčeno**, nebo
    - i bez premium dosáhl potřebného SP milníku.
  - Kosmetické odměny (badges, icon pack, chat wallpapers, lifetime license) jsou navázané čistě na SP, i když je uživatel premium.

---

## 9. Související dokumenty

- **Kritický report (bezpečnost, chybějící funkce):** `docs/APP_REPORT_CRITICAL.md`
- **RevenueCat a reálné nákupy:** `docs/REVENUECAT_REAL_PURCHASES.md`
- **Push notifikace:** `docs/PUSH_NOTIFICATIONS.md`
- **Google API klíč (Android):** `docs/ANDROID_GOOGLE_API_KEY.md`

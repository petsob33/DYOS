# Jak zapnout reálné transakce (RevenueCat + App Store + Google Play)

V aplikaci už je připravený kód: po úspěšném nákupu přes RevenueCat se zapíše `subscriptionTier: 'premium'` do Firestore na `couples/{id}` a oba partneři dostanou premium. Aby šly opravdu peníze, musíš nastavit obchody a RevenueCat.

---

## 1. RevenueCat (jedna brána pro oba obchody)

1. **Účet a projekt**
   - Jdi na [revenuecat.com](https://www.revenuecat.com), založ účet.
   - Vytvoř **Project** (např. „DYOS“).
   - V projektu přidej **Apps**: jednu pro **iOS** (Apple App Store), jednu pro **Android** (Google Play). Pro každou appku zadáš bundle ID / package name (stejné jako v Xcode / `build.gradle`).

2. **API klíč**
   - V projektu: **Project Settings → API Keys**.
   - Zkopíruj **Public API key** (začíná např. `appl_` pro iOS nebo `goog_` pro Android). Jeden projekt může mít jeden klíč pro obě platformy, nebo klíč per app – použij ten, který RevenueCat ukáže pro tvou appku.

3. **Produkty a entitlement**
   - **Products**: V RevenueCat přidej produkty, které budou odpovídat ID z App Store / Play Console:
     - např. `dyos_monthly`, `dyos_yearly` (nebo přesně ta ID, která vytvoříš v Apple/Google).
   - **Entitlements**: Vytvoř entitlement s identifikátorem **`premium`** (v kódu je `premiumEntitlementId = 'premium'`). Všechny předplatné plány (měsíční i roční) přiřaď k tomuto entitlementu.
   - **Offerings**: Vytvoř Offering (např. „Default“). Do něj přidej **Packages**: monthly (typ Monthly), yearly (typ Annual) a přiřaď jim produkty z kroku 3. Toto Offering bude v aplikaci vráceno jako `current` v `getOfferings()`.

4. **Propojení s App Store / Google Play**
   - V RevenueCat u iOS app: **App Store Connect API** (Shared Secret / In-App Purchase Key podle doporučení RevenueCat).
   - U Android app: propojení s Google Play (service account / credentials podle RevenueCat návodu).

Bez tohoto propojení RevenueCat neověří účtenky a entitlementy nebudou aktivní.

---

## 2. Apple App Store (iOS)

1. **Smlouvy a platby**
   - V [App Store Connect](https://appstoreconnect.apple.com): **Agreements, Tax, and Banking** – doplnit smlouvy a platby, jinak nelze přidat in-app nákupy.

2. **Subscription skupina**
   - Tvůj app → **Subscriptions** → vytvoř **Subscription Group** (např. „DYOS Premium“).

3. **Subscription produkty**
   - V této skupině vytvoř alespoň dva **Subscriptions**:
     - **Monthly**: Product ID např. `dyos_monthly` (nebo jak máš v RevenueCat), cena, billing interval 1 month.
     - **Yearly**: Product ID např. `dyos_yearly`, cena, billing interval 1 year.
   - (Volitelně) u produktu zapni **Free Trial** (např. 7 dní) – pak bude „Enable 7-day free trial“ v aplikaci odpovídat reálnému trialu.

4. **RevenueCat**
   - V RevenueCat u iOS app zadej stejná **Product ID** jako v App Store. RevenueCat pak při nákupu dostane účtenku od Apple a aktivuje entitlement `premium`.

---

## 3. Google Play (Android)

1. **Merchant účet**
   - V [Google Play Console](https://play.google.com/console): nastav obchodní účet a platby.

2. **Subscription produkty**
   - Tvůj app → **Monetize → Subscriptions** → vytvoř předplatné:
     - např. **Monthly**: Product ID `dyos_monthly`, měsíční cena.
     - **Yearly**: Product ID `dyos_yearly`, roční cena.
   - Product ID mohou být stejná jako na iOS, nebo jiná – v RevenueCat je přiřadíš ke správným „Products“ a k entitlementu `premium`.

3. **RevenueCat**
   - V RevenueCat u Android app zadej Product ID z Play Console a propojení s Google Play (ověření nákupů). Po úspěšném nákupu RevenueCat aktivuje `premium`.

---

## 4. Aplikace: předat API klíč

RevenueCat se v aplikaci inicializuje jen když je nastavený klíč (viz `lib/main.dart`).

**Spuštění s reálným klíčem:**

```bash
# iOS (použij svůj skutečný public API key z RevenueCat)
flutter run --dart-define=REVENUECAT_API_KEY=appl_TVASdvaZAbCdEfGhIjKlMnOpQrStUvWxYz

# Android
flutter run --dart-define=REVENUECAT_API_KEY=goog_AbCdEfGhIjKlMnOpQrStUvWxYz
```

Pokud má RevenueCat v jednom projektu jeden klíč pro obě platformy, můžeš použít ten samý `REVENUECAT_API_KEY` pro iOS i Android.

**Produkční build (např. Android):**

```bash
flutter build appbundle --dart-define=REVENUECAT_API_KEY=goog_xxx
```

Klíč **nepiš** do kódu ani do repozitáře – drž ho v CI (secret) nebo v lokální konfiguraci.

---

## 5. Jak to v aplikaci proběhne (reálná transakce)

1. Uživatel na stránce DYOS+ vybere plán (Monthly/Yearly) a stiskne **Continue**.
2. Aplikace zavolá `Purchases.purchase(PurchaseParams.storeProduct(storeProduct))` – produkt bere z `getOfferings()` (RevenueCat).
3. **iOS**: otevře se systémové okno App Store pro nákup / předplatné (včetně Face ID / Touch ID).  
   **Android**: otevře se Google Play platební dialog.
4. Po úspěšné platbě RevenueCat vrátí `CustomerInfo` s aktivním entitlementem `premium`.
5. `PurchaseService._syncCustomerInfoToFirestore()` načte `coupleId` z Firestore (aktuální uživatel) a zavolá `FirebaseService.updateCoupleSubscription(coupleId, 'premium', expirationDate)`.
6. Do dokumentu `couples/{coupleId}` se zapíše `subscriptionTier: 'premium'` a `subscriptionExpiry` (pokud RevenueCat vrátí datum).
7. Oba partneři mají na tento dokument odběr (`coupleProvider`), takže druhý partner okamžitě vidí `isPremium == true` a dostane premium bez dalšího nákupu.

---

## 6. Testování (bez reálných plateb)

- **Apple**: V zařízení se odhlasuj z produkčního Apple ID a přihlas se **Sandbox** testovacím účtem (App Store Connect → Users and Access → Sandbox Testers). Nákupy pak jdou „jako reálné“, ale neúčtují se.
- **Google**: V Play Console přidej **License testers** a na testovacím zařízení se přihlas účtem z této skupiny. Nákupy se neúčtují.
- **RevenueCat**: Můžeš použít jejich sandbox / test režim podle [RevenueCat Test Store](https://www.revenuecat.com/docs/test-and-launch/sandbox/test-store).

---

## 7. Kontrolní seznam

- [ ] RevenueCat: projekt, iOS + Android app, Public API key
- [ ] RevenueCat: entitlement `premium`, produkty (monthly, yearly), Offering s Packages
- [ ] RevenueCat: propojení s App Store (Shared Secret / In-App Purchase Key) a s Google Play
- [ ] App Store Connect: smlouvy, Subscription Group, subscription produkty (Product ID shodné s RevenueCat)
- [ ] Google Play: subscription produkty (Product ID v RevenueCat)
- [ ] Aplikace: build s `--dart-define=REVENUECAT_API_KEY=...`
- [ ] Otestovat nákup na iOS (sandbox) a Android (license tester) a ověřit zápis do `couples/{id}` a zobrazení premium u obou partnerů

Až toto bude hotové, reálná transakce proběhne tak, jak je popsáno v bodu 5.

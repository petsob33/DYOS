# DYOS – Kritický report o stavu aplikace

**Datum:** březen 2025  
**Účel:** Kompletní přehled hotového / nedokončeného, bezpečnostní rizika, funkčnost a doporučení. Dokument je záměrně kritický.

**Po úpravách (dle tohoto reportu):** Odstraněn hardcoded Google Places API klíč z Info.plist (použit Secrets.xcconfig). Přidána Storage pravidla pro `profile_pictures`. Route `/firebase-test` je jen v debug buildu. Waitlist get jen pro přihlášené. V notification_service a couple_model použit `debugPrint` místo `print`. Přidána dokumentace `docs/ARCHITECTURE.md` (Auth, Pairing, Router, Firebase, RevenueCat).

---

## 1. Přehled aplikace

**DYOS (OurOS)** je Flutter aplikace pro páry: timeline vzpomínek, intimita tracker, menstruační kalendář, sdílené seznamy, události, rychlé zprávy a haptická „ťuknutí“. Backend: Firebase (Auth, Firestore, Storage, Functions, FCM). Monetizace: RevenueCat (předplatné premium).

- **Tech stack:** Flutter, Dart 3.10+, Riverpod, GoRouter, Firebase, RevenueCat, freezed, json_serializable.
- **Struktura:** feature-first (`lib/features/<feature>/data|domain|presentation`).

---

## 2. Co je hotové (funguje)

### 2.1 Auth a párování
- Přihlášení / registrace (včetně Google Sign-In).
- Párování přes **invite kód** – jeden uživatel vytvoří pár a vygeneruje kód, druhý ho zadá a připojí se.
- Firestore pravidla: uživatel může měnit jen svůj `users/{uid}`; pro párování je povolený zápis jen do pole `coupleId` („hack“ v pravidlech).
- Profil: zobrazení, editace jména, **fotka profilu** (upload do Storage).

### 2.2 Dashboard (Home)
- Bento mřížka: status s avatary a emoji, Days Together, countdown na událost, Quick Note, Intimacy Spark.
- Editovatelný emoji status s tichou notifikací partnerovi.
- Swipe mezi záložkami, swipe nahoru → Quick Add sheet.

### 2.3 Timeline (Memories)
- Chronologický feed po měsících, karty s fotkou/datum/lokace.
- Filtry (dateNight, trip, milestone…).
- Přidání/editace vzpomínky, nahrání fotek/videí do Storage.
- Mapa vzpomínek (`/memory/map`).

### 2.4 Data (Tracker)
- Intimacy logy (kalendář, tečky, detail: iniciátor, hodnocení 1–5, tagy).
- DYOS Analytics: grafy (frekvence, iniciátor, tagy, „favorite day“).
- Historie intimit (`IntimacyHistoryScreen`).

### 2.5 Cycle (menstruační kalendář)
- Nastavení (délka cyklu, perioda, poslední perioda).
- Logy (flow, nálada), predikce.
- **Chybí v UI:** `partnerMessage` z predikce („Dnes buď trpělivý“) se nikde nezobrazuje – logika je v kódu, ne v UI.

### 2.6 Lists a poznámky
- **Bucket List** a **Secret Gift** listy (typy poznámek), obrazovky Lists a Secret Notes.
- Přidání poznámky s typem (shared, private, bucketList, secretGift).
- Poznámky v Firestore: `couples/{id}/notes`.

### 2.7 Události
- Kalendář událostí (výročí, schůzky), Add Event sheet, napojení na countdown na Home.

### 2.8 Interakce v páru
- **Taptic Touch** – podržení → vibrace partnerovi (haptic_signals + notifikace).
- **Quick Message** – rychlé zprávy do notifikací (quick_messages + FCM).

### 2.9 Premium (RevenueCat)
- Paywall modal, Premium landing, PurchaseService: nákup → sync do `couples/{id}` (`subscriptionTier`, `subscriptionExpiry`) → oba partneři vidí premium.
- Premium gate widget pro uzamčení funkcí.
- API klíč přes `--dart-define=REVENUECAT_API_KEY` (správně není v repu).

### 2.10 Blueprints
- Seznam sekcí (mock data), Blueprint detail s otázkami, Travel Config blueprint.
- Data zatím z `BlueprintMockData`, ne z Firestore.

### 2.11 Gamifikace (částečně)
- Level screen, system status demo, progression plan, level tiers – spíš kostra než plnohodnotná feature.

### 2.12 Firebase a infrastruktura
- Firestore rules pro users, couples a subkolekce (memories, intimacy_logs, notes, events, cycle_logs, cycle_settings, haptic_signals, quick_messages).
- Storage rules **pouze pro** `memories/{coupleId}/{fileName}` (obrázky/videa, max 10 MB).
- FCM + lokální notifikace, ukládání FCM tokenu (např. do users).
- Router: veřejné route (login, register, **firebase-test**), pairing, chráněné route, shell s 4 záložkami + Quick Add.

---

## 3. Co není hotové / chybí

### 3.1 Funkce ze specifikace
- **Groceries** – sdílený nákupní seznam s checkboxy a real-time sync. V kódu není; notes mají jen shared/private/bucketList/secretGift.
- **Achievement** – odznaky / odemykání. Není spec ani implementace.
- **Recap** – týdenní/měsíční přehled. Zmíněno v dokumentu, v kódu ne.
- **Limit fotek (30/měsíc, „top 6“)** – žádný limit ani výběr „top“ memories.
- **Dark Mode** – theme je jen light (`ThemeMode.light`).
- **Emoce mode** – emoji picker pro status (nyní TextField pro emoji + text, ne předvybrané smajlíky).
- **Time Capsule** – složka `lib/features/time_capsule` existuje, ale je **prázdná** (žádné soubory).

### 3.2 UX a dokončení
- **TODO v kódu:**  
  - `notification_service.dart`: „Navigate to appropriate screen based on payload“ – deep link z notifikace neřešen.  
  - `memory_screen.dart`: „Navigate to map view“, „Navigate to memory detail“ – pravděpodobně placeholdery.
- **Partner message (Cycle):** `CycleCalculator.calculateStatus()` vrací `partnerMessage`, v UI se nezobrazuje.
- **Navigace:** 5. tab v dokumentu je „Calendar (Organizér)“, v app je 4. tab „Calendar“ = Cycle; Lists/Organizér je jen odkaz z Home, ne tab – může to být záměr, ale spec to neupřesňuje.

### 3.3 Testování
- **Unit/widget testy:** jen pár souborů (`test/pairing/*`, `widget_test.dart`). Žádná širší pokrytí repozitářů, providerů ani kritických flow (auth, purchase, memory create).
- **Firestore test:** používá kolekci `_test` – v pravidlech není výjimka, takže v produkci by zápis/čtení selhal (správně), ale obrazovka zůstává v buildu.

### 3.4 Dokumentace a konzistence
- RevenueCat a technické detaily (Auth, Pairing, Router, Firebase) jsou v `docs/ARCHITECTURE.md`.

---

## 4. Bezpečnostní problémy a rizika

### 4.1 Kritické

1. **Google Places API klíč v repozitáři (iOS)**  
   V `ios/Runner/Info.plist` je **hardcoded** klíč:
   ```xml
   <key>GOOGLE_PLACES_API_KEY</key>
   <string>REDACTED-ROTATED-GOOGLE-PLACES-KEY</string>
   ```
   Klíč je ve verzování; kdokoli s přístupem k repu může klíč zneužít (např. překročení kvót, fakturace).  
   **Doporučení:** Přesunout do `xcconfig` / env nebo build-time substituce (např. `--dart-define` + skript do Info.plist), klíč nikdy necommittovat. V Google Cloud Console omezit klíč na bundle ID a případně API (Maps, Places).

2. **Debug / test route v produkčním routeru**  
   Route `/firebase-test` je **veřejná** (nevyžaduje auth). Zobrazuje stav Firebase a **email přihlášeného uživatele** (pokud je někdo přihlášen). V produkci by neměla být dostupná.  
   **Doporučení:** Odstranit route z produkčního buildu (např. `kReleaseMode` / `kDebugMode`) nebo ji chránit auth a nepoužívat v release.

3. **Firestore test kolekce**  
   `FirebaseTestScreen` píše do `_test/connection_test`. Pravidla mají default deny, takže v produkci zápis selže – to je v pořádku. Kolekce `_test` ale v pravidlech není výslovně zakázaná pro čtení (spadá pod `match /{document=**}` → deny). Záměr je správný; jen je třeba dbát na to, aby se nikde jinde neotevřela „díra“ pro `_test`.

### 4.2 Vysoké

4. **Storage: chybí pravidla pro `profile_pictures`**  
   V `storage.rules` je pouze:
   - `memories/{coupleId}/{fileName}` – čtení/zápis pro členy páru.
   - Default deny pro vše ostatní.  
   `StorageService.uploadProfilePicture()` ukládá do **`profile_pictures/{userId}/{timestamp}.jpg`**. Tato cesta v pravidlech **není** – spadá pod default deny.  
   **Důsledek:** Upload profilové fotky by měl v produkci končit **Permission denied** (pokud se nevyužívá jiný bucket nebo lokální vývoj s volnějšími pravidly).  
   **Doporučení:** Přidat do `storage.rules` blok např. `profile_pictures/{userId}/{fileName}` s podmínkou: write pouze `request.auth.uid == userId`, read např. pro ověřené uživatele (nebo jen vlastník). Omezit velikost a typ (např. image/*).

5. **Users – zápis `coupleId` od kohokoli**  
   Pravidlo: zápis povolen, pokud měním jen `coupleId`. To znamená, že **libovolný přihlášený uživatel** může jinému uživateli přepsat `coupleId` na svůj výběr (pokud zná nebo uhádne `userId`). To je záměr pro párování (druhý uživatel si přepíše svůj `coupleId` po zadání kódu), ale zneužití: útočník může „připojit“ cizí účet ke svému páru a číst data páru.  
   **Mitigace:** Párování by mělo být v praxi vázané na znalost jednorázového kódu a ověření identity; přesto je to citlivé pravidlo. Zvážit užší omezení (např. povolit změnu `coupleId` jen na hodnotu, která odpovídá páru, kde je uživatel pozván – např. přes Cloud Function nebo kontrolu dokumentu `couples/{coupleId}` a pole `invitedUserId` / kód).

6. **Waitlist – čtení libovolného dokumentu**  
   `match /waitlist/{emailId}`: `allow get: if true;` – kdokoli (i neauth) může **načíst jeden dokument** z waitlistu, pokud zná `emailId` (což je podle pravidel asi email). Únik jedné emailové adresy při znalosti ID není nutně kritický, ale je to zbytečné rozšíření přístupu.  
   **Doporučení:** Omezit get na auth nebo admin; nebo nepoužívat waitlist pro citlivá data.

### 4.3 Střední / nízké

7. **Logování a printy**  
   V kódu zůstávají `print()` (např. `notification_service.dart`). V release buildu by mělo jít do `debugPrint` nebo vůbec ne logovat citlivé informace.  
   **Doporučení:** Nahradit `print` za `debugPrint` nebo logger s úrovní; v produkci nelogovat tokeny, emaily atd.

8. **RevenueCat při startu**  
   `main.dart` volá `Purchases.configure(..., appUserID: uid)` – pokud uživatel není přihlášen, `uid` je null. RevenueCat to typicky zvládne, ale po přihlášení by měl být uživatel znovu identifikován (např. `Purchases.logIn(uid)`), aby nákupy byly svázané s účtem. Ověřit, zda se po login volá identifikace.

9. **Chyby v purchase flow**  
   Selhání RevenueCat (např. `configure` v main) se pouze `debugPrint`; uživatel nedostane jasnou zpravu. Doporučeno: logovat a v UI (paywall) zobrazit např. „Nepodařilo se připojit k obchodu“.

---

## 5. Funkcionalita – shrnutí

| Oblast            | Stav        | Poznámka |
|------------------|------------|----------|
| Auth + Pairing   | Hotovo     | Párování přes invite kód; Firestore „coupleId“ write omezení je riskantní. |
| Home / Dashboard | Hotovo     | Chybí zobrazení partner message (Cycle). |
| Timeline         | Hotovo     | TODO: deep link z notifikace, případně map/detail. |
| Data / Tracker   | Hotovo     | – |
| Cycle            | Skoro      | Partner message v kódu, ne v UI. |
| Lists / Notes    | Částečně   | Bucket List, Secret Gift; chybí Groceries. |
| Events           | Hotovo     | – |
| Premium          | Hotovo     | RevenueCat + sync do Firestore. |
| Blueprints       | Mock       | Data z mocku, ne backend. |
| Time Capsule     | Prázdné    | Složka bez implementace. |
| Notifikace       | Hotovo     | FCM + lokální; deep link TODO. |
| Storage          | Částečně   | Memories OK; profile_pictures bez pravidel. |
| Firestore rules  | Rozumné    | Kromě users write a waitlist get. |
| Testy            | Minimální  | Jen pár pairing testů. |
| Dark mode        | Ne         | – |
| Lokalizace       | Ne         | Podle .cursorrules hardcoded strings pro v1. |

---

## 6. Doporučení (prioritizované)

### Okamžitě
1. **Odstranit Google Places API klíč z `Info.plist`** a nastavit ho přes build/env; v konzoli omezit klíč.
2. **Přidat Storage pravidla pro `profile_pictures/{userId}/{fileName}`** a ověřit upload profilové fotky v produkci.
3. **Vypnout nebo chránit route `/firebase-test`** v release buildu a neexponovat email uživatele.

### Krátkodobě
4. Zúžit zápis `users.coupleId` (např. jen na hodnoty z „pozvánek“ ověřených serverem/Function).
5. Omezit `waitlist` get (auth nebo odstranit veřejné get).
6. Nahradit `print` za `debugPrint`/logger; po přihlášení volat RevenueCat identifikaci uživatele.

### Střednědobě
7. Doplnit zobrazení **partner message** (Cycle) v UI.
8. Implementovat **Groceries** (sdílený seznam s checkboxy) nebo ho vyškrtnout ze spec.
9. Rozhodnout o **Time Capsule** – buď implementovat, nebo složku odstranit.
10. Rozšířit testy (repository, auth, purchase flow).
11. Přidat **Dark Mode** a případně emoji picker pro status (Emoce mode).

### Dlouhodobě
12. Specifikovat a implementovat Achievement, Recap, limit fotek (30/měsíc, top 6).
13. Doplnit technický dokument o Auth, Pairing, Events, Notes, Router, Firebase, RevenueCat.

---

## 7. Závěr

Aplikace má solidní základ: auth, párování, timeline, tracker, cycle, události, poznámky, premium a notifikace jsou implementované a většinou funkční. Hlavní mezery jsou: **bezpečnost (API klíč v repu, firebase-test route, Storage pro profilové fotky)**, **nedokončené spec funkce (Groceries, Dark Mode, Time Capsule, partner message v UI)** a **nízké testové pokrytí**. Doporučuje se nejdřív zavřít kritické a vysoké bezpečnostní body, pak doplnit chybějící pravidla Storage a až poté rozšiřovat feature set.

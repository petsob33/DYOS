# Logika Login a Párování v OurOS App

## 📋 Přehled

Tento dokument popisuje, jak funguje autentizace a párování uživatelů v aplikaci OurOS.

---

## 🔐 1. LOGIN (Přihlášení)

### Krok 1: Uživatel zadá email a heslo
- Uživatel otevře `LoginScreen`
- Vyplní email a heslo do formuláře
- Klikne na tlačítko "Přihlásit se"

### Krok 2: Validace formuláře
- Email musí být ve správném formátu (např. `user@example.com`)
- Heslo musí mít minimální délku (podle Firebase pravidel)

### Krok 3: Volání Firebase Auth
```dart
// V AuthService.signInWithEmailAndPassword()
await FirebaseAuth.instance.signInWithEmailAndPassword(
  email: email.trim(),
  password: password,
);
```

**Co se stane:**
- Firebase Auth ověří email a heslo
- Pokud jsou správné, vytvoří se autentizační session
- Firebase Auth vrátí `UserCredential` s informacemi o uživateli
- `authStateChanges` stream začne emitovat `User` objekt

### Krok 4: Router automaticky přesměruje
- Router sleduje `authStateChanges` stream
- Když se uživatel přihlásí, stream emituje `User` objekt
- Router automaticky přesměruje na:
  - `/home` - pokud je uživatel spárovaný
  - `/pairing` - pokud uživatel není spárovaný

### Krok 5: Načtení uživatelských dat
- Po přihlášení se načte `UserModel` z Firestore (`users/{uid}`)
- Pokud dokument neexistuje, vytvoří se automaticky s `inviteCode`
- `inviteCode` se použije pro párování (např. `PETR-8821`)

---

## 👥 2. REGISTRACE (Vytvoření účtu)

### Krok 1: Uživatel vyplní registrační formulář
- Email, heslo, jméno (displayName)
- Validace formuláře

### Krok 2: Vytvoření Firebase Auth účtu
```dart
// V AuthService.registerWithEmailAndPassword()
final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
  email: email.trim(),
  password: password,
);
```

**Co se stane:**
- Firebase Auth vytvoří nový účet
- Vrátí `UserCredential` s UID uživatele

### Krok 3: Aktualizace display name v Firebase Auth
```dart
await credential.user?.updateDisplayName(displayName);
```

### Krok 4: Vytvoření Firestore dokumentu
```dart
// Generování invite kódu (např. "PETR-8821")
final inviteCode = _generateInviteCode(displayName);

// Vytvoření UserModel
final userModel = UserModel(
  uid: credential.user!.uid,
  email: email.trim(),
  displayName: displayName,
  inviteCode: inviteCode,
  createdAt: DateTime.now(),
  coupleId: null, // Bude nastaveno při párování
);

// Uložení do Firestore
await _userRepository.createUser(userModel);
```

**Výsledek:**
- Vytvoří se dokument v `users/{uid}` s:
  - `email`: Email uživatele
  - `displayName`: Jméno uživatele
  - `inviteCode`: Unikátní kód pro párování (např. `PETR-8821`)
  - `coupleId`: `null` (bude nastaveno při párování)
  - `createdAt`: Datum vytvoření účtu

---

## 💑 3. PÁROVÁNÍ (Pairing)

### Krok 1: Uživatel otevře PairingScreen
- Zobrazí se jeho vlastní `inviteCode` (např. `PETR-8821`)
- Uživatel může zkopírovat svůj kód nebo zadat kód partnera

### Krok 2: Uživatel zadá partnerův invite kód
- Např. `ANNA-1234`
- Validace formátu (musí být `NAME-####`)

### Krok 3: Vyhledání partnera podle invite kódu
```dart
// V FirebaseService.findUserByInviteCode()
final query = await FirebaseFirestore.instance
    .collection('users')
    .where('inviteCode', isEqualTo: inviteCode.toUpperCase())
    .limit(1)
    .get();

if (query.docs.isEmpty) {
  throw PartnerNotFoundException();
}

final partnerUser = UserModel.fromFirestore(query.docs.first);
```

**Kontrola:**
- Partner musí existovat v databázi
- Partner nesmí být už spárovaný (`coupleId == null`)
- Uživatel se nesmí spárovat sám se sebou

### Krok 4: Vytvoření páru (Couple)
```dart
// V FirebaseService.pairUsers(currentUserId, partnerUserId)
```

**Proces:**

1. **Validace:**
   - Oba uživatelé musí existovat
   - Ani jeden nesmí být už spárovaný
   - Uživatel se nesmí spárovat sám se sebou

2. **Vytvoření Couple dokumentu:**
   ```dart
   final coupleId = 'couple_${DateTime.now().millisecondsSinceEpoch}';
   final couple = CoupleModel(
     id: coupleId,
     members: [currentUserId, partnerUserId], // ← DŮLEŽITÉ: Pole s 2 UID
     anniversaryDate: DateTime.now(),
     createdAt: DateTime.now(),
     subscriptionTier: 'free',
     status: {
       currentUserId: CoupleStatus(...),
       partnerUserId: CoupleStatus(...),
     },
   );
   ```

3. **Atomický zápis pomocí Batch:**
   ```dart
   final batch = FirebaseFirestore.instance.batch();
   
   // 1. Vytvoření couple dokumentu
   batch.set(coupleRef, couple.toJson());
   
   // 2. Aktualizace currentUser s coupleId
   batch.update(currentUserRef, {'coupleId': coupleId});
   
   // 3. Aktualizace partnerUser s coupleId
   batch.update(partnerUserRef, {'coupleId': coupleId});
   
   // 4. Commit všech změn najednou (atomicky)
   await batch.commit();
   ```

**Důležité:**
- Všechny 3 operace se provedou atomicky (všechno nebo nic)
- Pokud jedna operace selže, všechny se vrátí zpět
- `members` pole musí obsahovat přesně 2 UID (pro Firestore Security Rules)

### Krok 5: Firestore Security Rules kontrola

Při vytváření `couples/{coupleId}` dokumentu se kontroluje:

```javascript
allow create: if 
  request.auth != null &&
  request.resource.data.members != null &&
  request.auth.uid in request.resource.data.members &&
  request.resource.data.members.size() == 2;
```

**Co se kontroluje:**
- ✅ Uživatel musí být přihlášen (`request.auth != null`)
- ✅ Pole `members` musí existovat
- ✅ Uživatel musí být v poli `members` (`request.auth.uid in members`)
- ✅ Pole `members` musí mít přesně 2 prvky

### Krok 6: Úspěšné párování
- Batch commit proběhne úspěšně
- Oba uživatelé mají nastavené `coupleId` ve svých dokumentech
- Vytvoří se dokument `couples/{coupleId}` s:
  - `members`: `[currentUserId, partnerUserId]`
  - `anniversaryDate`: Aktuální datum
  - `subscriptionTier`: `"free"`
  - `status`: Status obou uživatelů

### Krok 7: Router přesměruje na Home
- Router zkontroluje `isUserPaired()` provider
- Pokud je uživatel spárovaný, přesměruje na `/home`
- Home screen načte data páru a partnera

---

## 🔍 4. DEBUGGING

### Debugging kód v `pairUsers()`

Před zápisem do Firestore se vypíše:

```dart
print("=== DEBUGGING FIRESTORE WRITE ===");
print("My ID (from currentUser): $myId");
print("Current User ID (param): $currentUserId");
print("Partner ID (param): $partnerUserId");
print("Members List: $membersList");
print("Members Length: ${membersList.length}");
print("Couple ID: $coupleId");
print("Couple data keys: ${coupleData.keys.join(", ")}");
print("Members in couple data: ${coupleData['members']}");
```

**Co kontrolovat:**
- ✅ `currentUserId` a `partnerUserId` nejsou `null` ani prázdné
- ✅ `membersList.length == 2`
- ✅ `coupleData['members']` je pole s 2 prvky
- ✅ Oba UID jsou správné (odpovídají skutečným uživatelům)

---

## 📊 5. DATOVÁ STRUKTURA

### Users Collection (`users/{uid}`)
```json
{
  "uid": "abc123...",
  "email": "petr@example.com",
  "displayName": "Petr",
  "inviteCode": "PETR-8821",
  "coupleId": "couple_1234567890", // null pokud není spárovaný
  "createdAt": "2024-01-15T10:30:00Z"
}
```

### Couples Collection (`couples/{coupleId}`)
```json
{
  "members": ["user1_uid", "user2_uid"], // ← DŮLEŽITÉ: Pole s 2 UID
  "anniversaryDate": "2024-01-15T10:30:00Z",
  "createdAt": "2024-01-15T10:30:00Z",
  "subscriptionTier": "free",
  "status": {
    "user1_uid": {
      "emoji": "😊",
      "text": "Ready to connect",
      "updatedAt": "2024-01-15T10:30:00Z"
    },
    "user2_uid": {
      "emoji": "😊",
      "text": "Ready to connect",
      "updatedAt": "2024-01-15T10:30:00Z"
    }
  }
}
```

---

## ⚠️ 6. ČASTÉ CHYBY

### Chyba: `PERMISSION_DENIED` při vytváření páru

**Příčiny:**
1. Firestore Security Rules nejsou nasazeny
   - **Řešení:** `firebase deploy --only firestore:rules`

2. Pole `members` je `null` nebo neexistuje
   - **Řešení:** Zkontroluj, že `couple.toJson()` obsahuje `members`

3. Uživatel není v poli `members`
   - **Řešení:** Zkontroluj, že `currentUserId` je v `members` poli

4. Pole `members` nemá přesně 2 prvky
   - **Řešení:** Zkontroluj, že `members.length == 2`

### Chyba: Partner nenalezen

**Příčiny:**
1. Invite kód je špatně zadaný
   - **Řešení:** Zkontroluj formát (musí být `NAME-####`)

2. Partner ještě není zaregistrovaný
   - **Řešení:** Partner musí nejdřív vytvořit účet

### Chyba: Uživatel už je spárovaný

**Příčiny:**
1. Uživatel už má `coupleId` v dokumentu
   - **Řešení:** Nelze spárovat už spárovaného uživatele

---

## 🔄 7. FLOW DIAGRAM

```
┌─────────────┐
│   LOGIN     │
└──────┬──────┘
       │
       ▼
┌─────────────┐     ┌──────────────┐
│  Firebase   │────▶│  Firestore   │
│    Auth     │     │  User Doc    │
└─────────────┘     └──────┬───────┘
                           │
                           ▼
                    ┌──────────────┐
                    │  Is Paired?  │
                    └──────┬───────┘
                           │
            ┌──────────────┴──────────────┐
            │                             │
            ▼                             ▼
    ┌──────────────┐            ┌──────────────┐
    │    HOME      │            │   PAIRING     │
    │   Screen     │            │   Screen      │
    └──────────────┘            └──────┬───────┘
                                       │
                                       ▼
                              ┌──────────────┐
                              │ Enter Code   │
                              └──────┬───────┘
                                     │
                                     ▼
                              ┌──────────────┐
                              │ Find Partner │
                              └──────┬───────┘
                                     │
                                     ▼
                              ┌──────────────┐
                              │ Create Couple│
                              │   (Batch)    │
                              └──────┬───────┘
                                     │
                                     ▼
                              ┌──────────────┐
                              │    HOME      │
                              │   Screen     │
                              └──────────────┘
```

---

## 📝 8. ZÁVĚR

- **Login:** Firebase Auth ověří přihlašovací údaje a vytvoří session
- **Registrace:** Vytvoří Firebase Auth účet + Firestore dokument s `inviteCode`
- **Párování:** Atomicky vytvoří `couples` dokument a aktualizuje oba `users` dokumenty
- **Security Rules:** Kontrolují, že uživatel může vytvořit pouze páry, kde je členem

Všechny operace jsou atomické a bezpečné díky Firestore Batch a Security Rules.

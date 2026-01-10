# Deployment Guide - Firebase Hosting

Tento návod popisuje, jak nasadit landing page na Firebase Hosting a správně nastavit Firestore databázi.

## 📋 Předpoklady

1. **Firebase CLI nainstalované:**
   ```bash
   npm install -g firebase-tools
   ```

2. **Přihlášení do Firebase:**
   ```bash
   firebase login
   ```

3. **Firebase projekt nastavený:**
   - Projekt ID: `dyos-520c2`
   - `.firebaserc` již obsahuje správnou konfiguraci

## 🚀 Krok 1: Nasazení Firestore Rules

Nejdřív nasaďte Firestore rules, aby waitlist fungoval správně:

```bash
firebase deploy --only firestore:rules
```

Ověření v Firebase Console:
- Přejděte na [Firebase Console](https://console.firebase.google.com/)
- Vyberte projekt `dyos-520c2`
- Přejděte na **Firestore Database** > **Rules**
- Ověřte, že jsou nasazené nejnovější rules (měly by obsahovat sekci `waitlist`)

## 🌐 Krok 2: Nasazení na Firebase Hosting

### 2.1 Ověření konfigurace

Zkontrolujte, že `firebase.json` obsahuje hosting konfiguraci:

```bash
cat firebase.json
```

Mělo by obsahovat sekci `hosting` s `public: "public"`.

### 2.2 Nasazení

Nasazení celé aplikace (hosting + rules):

```bash
firebase deploy
```

Nebo pouze hosting:

```bash
firebase deploy --only hosting
```

### 2.3 Ověření nasazení

Po nasazení získáte URL typu:
- **Production:** `https://dyos-520c2.web.app`
- **Custom domain:** (pokud je nastaveno) `https://yourdomain.com`

## ✅ Krok 3: Testování

1. **Otevřete nasazenou stránku:**
   ```
   https://dyos-520c2.web.app
   ```

2. **Otestujte waitlist formulář:**
   - Zadejte email a klikněte "Join Waitlist"
   - Měli byste vidět úspěšnou zprávu
   - Zkontrolujte v Firebase Console > Firestore > `waitlist` collection, že se email uložil

3. **Zkontrolujte Firestore:**
   - Firebase Console > Firestore Database
   - Kolekce `waitlist`
   - Dokument by měl mít ID = normalizovaný email (lowercase)
   - Obsahovat: `email`, `createdAt`, `source`, `timestamp`, `userAgent`

## 🔍 Kontrola Firestore Databáze

### Zobrazení waitlist emailů:

1. **Přes Firebase Console:**
   - Firebase Console > Firestore Database
   - Kolekce `waitlist`
   - Každý dokument = jeden email

2. **Export pomocí skriptu:**
   ```bash
   # Nejdřív nainstalujte firebase-admin
   npm install firebase-admin
   
   # Nastavte service account key
   export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service-account-key.json"
   
   # Spusťte export
   node scripts/export-waitlist.js json  # nebo csv, txt
   ```

### Service Account Key:

1. Firebase Console > Project Settings > Service Accounts
2. Klikněte "Generate new private key"
3. Stáhněte JSON soubor
4. Použijte ho pro export skript

## 🔄 Aktualizace

Při každé změně v `public/index.html` nebo `firestore.rules`:

```bash
# Nasazení všeho
firebase deploy

# Nebo pouze změněných částí
firebase deploy --only hosting
firebase deploy --only firestore:rules
```

## 🐛 Troubleshooting

### Chyba: "Permission denied"

**Řešení:** Ověřte, že jsou Firestore rules nasazené:
```bash
firebase deploy --only firestore:rules
```

### Chyba: "Firebase not initialized"

**Řešení:** 
- Zkontrolujte Firebase config v `public/index.html`
- Ověřte, že máte správný `apiKey` a `appId` z Firebase Console

### Email se neukládá

**Řešení:**
1. Otevřete Developer Tools (F12) > Console
2. Podívejte se na chybové zprávy
3. Zkontrolujte Firestore rules v Firebase Console
4. Ověřte, že dokument ID = normalizovaný email (lowercase)

### Hosting nefunguje

**Řešení:**
1. Ověřte, že `public/index.html` existuje
2. Zkontrolujte `firebase.json` hosting konfiguraci
3. Zkuste znovu nasadit: `firebase deploy --only hosting`

## 📊 Monitoring

### Firebase Console Dashboard:
- **Hosting:** Zobrazuje návštěvnost, chyby, rychlost načítání
- **Firestore:** Zobrazuje čtení/zápisy, chyby, kvóty
- **Analytics:** (pokud je zapnuté) Uživatelské metriky

### Logs:
```bash
# Zobrazení hosting logů
firebase hosting:channel:list

# Zobrazení Firestore logů
firebase functions:log
```

## 🔒 Bezpečnost

- ✅ Firestore rules blokují čtení waitlist kolekce z klienta
- ✅ Pouze vytváření (create) je povoleno bez autentizace
- ✅ Email je normalizovaný (lowercase) jako document ID pro prevenci duplikátů
- ✅ Server timestamp je automaticky přidán

## 🌍 Custom Domain (Volitelné)

Pokud chcete použít vlastní doménu:

1. Firebase Console > Hosting > Add custom domain
2. Postupujte podle instrukcí
3. DNS záznamy budou automaticky navrženy
4. Po propagaci DNS bude stránka dostupná na vaší doméně

## 📝 Poznámky

- `public/` adresář obsahuje soubory pro hosting
- `.firebaseignore` určuje, které soubory se NEbudou nasazovat
- `firestore.rules` jsou nasazeny samostatně a mění se jen když jsou změny
- Hosting cache může trvat pár minut, než se projeví změny

## 🎯 Quick Deploy Checklist

- [ ] `firebase login` - přihlášení
- [ ] `firebase deploy --only firestore:rules` - nasazení rules
- [ ] Ověření rules v Firebase Console
- [ ] `firebase deploy --only hosting` - nasazení stránky
- [ ] Testování formuláře na nasazené URL
- [ ] Kontrola Firestore, že se email uložil

---

**Hotovo!** 🎉 Vaše landing page je nyní live na Firebase Hosting a waitlist ukládá emaily do Firestore.

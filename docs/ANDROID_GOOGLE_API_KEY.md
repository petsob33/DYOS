# Oprava DEVELOPER_ERROR na fyzickém Android zařízení

Na telefonu se objevuje `ConnectionResult{statusCode=DEVELOPER_ERROR}` a Maps/Google služby nefungují. API klíč musí být v Google Cloud Console omezen na tvůj Android build.

## 1. Otevři Google Cloud Console

1. Jdi na https://console.cloud.google.com/
2. Vyber projekt, ve kterém máš API klíč pro Maps/Places
3. **APIs & Services** → **Credentials**

## 2. Uprav API klíč

1. V seznamu **API keys** klikni na svůj klíč (ten, co je v `AndroidManifest.xml` u `com.google.android.geo.API_KEY`)
2. V sekci **Application restrictions** zvol **Android apps**
3. Klikni **+ Add an item** a zadej:

| Pole | Hodnota |
|------|---------|
| **Package name** | `com.example.dyos_app` |
| **SHA-1 certificate fingerprint** | `87:26:FA:7F:7C:07:D2:8B:35:6C:68:2E:3F:BC:C7:B8:1F:1B:35:5E` |

4. (Volitelně) Přidej i **SHA-256** pro stejný package:
   `0B:20:15:7A:DE:18:C1:F1:17:D7:9B:8D:27:7E:AF:69:49:46:A8:BF:BD:26:0B:CC:B5:B9:B2:D3:87:AA:64:CA`

5. **Save**

## 3. API omezení (doporučeno)

V sekci **API restrictions** u klíče měj povolené alespoň:
- Maps SDK for Android
- Places API (pokud používáš autocomplete)

## 4. Po uložení

Změny v konzoli mohou trvat pár minut. Pak na telefonu:

1. Odinstaluj aplikaci (nebo vymaž data)
2. Spusť znovu: `flutter run`

---

**Poznámka:** SHA-1 výše je z **debug** keystore (`~/.android/debug.keystore`). Pro release build budeš potřebovat SHA-1 z release keystore a přidat ho v konzoli jako další položku (stejný package name, jiný SHA-1).

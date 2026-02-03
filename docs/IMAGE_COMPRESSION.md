# Automatická komprese obrázků

Aplikace komprimuje obrázky **dvojitě**:

1. **Na klientovi** (Flutter) – při výběru z galerie (`imageQuality: 85`, `maxWidth/maxHeight: 1024`)
2. **Na serveru** (Firebase Cloud Functions) – automaticky při uploadu do Storage

## Jak to funguje

### Klient (Flutter)

Při výběru obrázku z galerie se automaticky:
- Nastaví kvalita na **85%**
- Omezí rozměry na **max 1024px** (šířka nebo výška)

To se děje v:
- `edit_profile_picture_screen.dart` – profilové fotky
- `add_memory_screen.dart` – fotky ve vzpomínkách

### Server (Cloud Functions)

Cloud Function `compressImage` se automaticky spustí při uploadu obrázku do Storage a:
- Stáhne nahraný obrázek
- Zkomprimuje ho pomocí `sharp`:
  - Max rozměr: **2048px** (šířka nebo výška)
  - Kvalita: **85%**
  - Formát: **JPEG** (i když originál byl PNG)
- Přepíše originál komprimovanou verzí

**Zpracovává pouze:**
- `profile_pictures/` – profilové fotky
- `memories/` – fotky ve vzpomínkách

**Přeskakuje:**
- Neobrázkové soubory (videa, dokumenty)
- Soubory mimo cílové složky
- Už zkomprimované soubory (s `_compressed` v názvu)

## Nasazení

```bash
cd functions
npm install
firebase deploy --only functions:compressImage
```

## Výhody dvojité komprese

1. **Rychlejší upload** – menší soubory z klienta = rychlejší nahrání
2. **Úspora Storage** – serverová komprese zajistí optimální velikost i když klient pošle větší soubor
3. **Konzistentní formát** – všechny obrázky jsou JPEG s jednotnou kvalitou
4. **Automatické** – funguje bez zásahu uživatele

## Poznámky

- Komprese probíhá **asynchronně** – upload dokončí okamžitě, komprese běží na pozadí
- Pokud komprese selže, originál zůstane v Storage (neblokuje upload)
- PNG s průhledností se převedou na JPEG (průhlednost se ztratí)

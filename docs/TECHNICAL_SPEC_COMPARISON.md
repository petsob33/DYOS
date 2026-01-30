# Technická specifikace vs. stav implementace

Porovnání dokumentu „Technická stránka“ s aktuálním kódem a plán dalších kroků.

---

## 1. Co je v dokumentu a co je hotové

### 1.1 Design System (theme.dart) ✅

| Spec | Stav |
|------|------|
| Barevná paleta (Background, Cards, Primary, Text, Secondary, Love, Success, Warning) | ✅ `lib/core/theme/app_theme.dart` – `AppPalette` |
| Font GoogleFonts.inter() | ✅ `GoogleFonts.interTextTheme()` v theme |
| Border radius 24 pro karty | ✅ `CardThemeData` + `RoundedRectangleBorder(24)` |
| Jemné stíny, žádné tvrdé obrysy | ✅ `elevation: 0`, `shadowColor` |

**Chybí v theme:**  
- Explicitní definice „měkkých“ stínů (blur, offset) jako design token – karty mají `elevation: 0`; stíny jsou řešené lokálně (např. v `RootShell`).

---

### 1.2 Navigace (Bottom Bar)

| Spec | Stav |
|------|------|
| 5 sekcí: HOME, TIMELINE, ADD, DATA, Calendar | ⚠️ Částečně |
| HOME | ✅ `/home` |
| TIMELINE (Memory) | ✅ `/memory` |
| ADD (střední tlačítko) | ✅ Quick Add sheet |
| DATA | ✅ `/data` |
| Calendar | ✅ Jako „Cycle“ – `/cycle` (menstruační kalendář) |

**Rozdíl:**  
- V dokumentu je 5. sekce „Calendar (Organizér)“. V app je 5. záložka **Cycle** (menstruační kalendář), ne Organizér/Lists.  
- **LISTS (Organizér)** není v bottom baru – dostupné z HOME (widget „Lists“) a pravděpodobně ze Settings. V dokumentu je „📝 Calendar (Organizér)“ – může jít o nejasnost: Organizér = Lists, nebo Calendar = Cycle.

**Doporučení:** V dokumentu upřesnit:  
- Buď 5. tab = „Lists/Organizér“ a Cycle brát jako součást DATA,  
- nebo 5. tab = „Cycle“ a Organizér (Lists) zůstane vstup z HOME.

---

### 1.3 HOME (Dashboard) ✅

| Widget | Stav |
|--------|------|
| StaggeredGridView (mřížka widgetů) | ✅ `MasonryGridView.count` |
| Status Header – dva avatary + emoji status | ✅ `_StatusHeader` + `_AvatarStatus` |
| Editovatelný emoji status, tichá notifikace partnerovi | ✅ Update status → Firebase |
| Days Together | ✅ `_DaysTogetherCard` |
| Countdown (nejbližší událost) | ✅ `_CountdownCard` |
| Quick Note (sdílená sticky note) | ✅ `_QuickNoteCard` + `QuickNoteCard` |
| Intimacy Spark (last sync) | ✅ `_IntimacySparkCard` |

---

### 1.4 TIMELINE (Memories) ✅

| Spec | Stav |
|------|------|
| Chronologický feed | ✅ `ListView.builder` po měsících |
| Karty s fotkou, datem, lokací | ✅ `_TimelineMonthSection` + karty |
| Smart Filters (chips) | ✅ `_CategoryFilter` + `MemoryCategory` (dateNight, trip, milestone, …) |
| Map Toggle (špendlíky na mapě) | ✅ `/memory/map` – `MemoriesMapScreen` |

---

### 1.5 DATA (Tracker & zdraví) ✅

| Spec | Stav |
|------|------|
| Intimacy Log – kalendář s tečkami | ✅ Cycle screen zobrazuje i intimitu; detail v `IntimacyHistoryScreen` / list |
| Detail záznamu: iniciátor, hodnocení 1–5, tagy, ochrana | ✅ `IntimacyLog` model + `AddIntimacySheet` + `IntimacyLogDetailSheet` |
| Cycle Sync (menstruační kalendář) | ✅ `CycleTrackingScreen` |
| DYOS Analytics (grafy, „nejčastěji v úterý“) | ✅ `DataScreen` – `_StatsRow`, `_FrequencyChart`, `_InitiatorChart`, `_TagsRadarChart`, „Favorite day“ |

**Chybí v UI:**  
- **Predikce nálady pro partnera** („Dnes buď trpělivý“): `CycleCalculator.calculateStatus()` vrací `partnerMessage`, ale tato zpráva se v Cycle UI nikde nezobrazuje. Doplnit např. banner/card na Cycle obrazovce pro partnera.

---

### 1.6 LISTS (Organizér)

| Spec | Stav |
|------|------|
| Groceries (Shared) – seznam s checkboxy, real-time sync | ❌ Chybí. Notes mají typy `shared`, `private`, `bucketList`, `secretGift` – žádný „grocery“ ani položky s checkboxy. |
| Bucket List | ✅ `NoteType.bucketList` + `ListsScreen` (jen Bucket List) |
| Secret Gift List (private) | ✅ `NoteType.secretGift` + `SecretNotesScreen` |

**Shrnutí:**  
- Bucket List a Secret Gift List jsou hotové.  
- **Groceries** jako sdílený seznam s checkboxy a real-time sync v dokumentu je, v kódu ne.

---

### 1.7 Další funkce

| Spec | Stav |
|------|------|
| Taptic Touch (podržení → vibrace partnerovi) | ✅ `_TapticTouchCard` + `sendHapticTouch` + notifikace |
| Quick Message (rychlé zprávy do notifikací) | ✅ `_QuickMessageCard` + `sendQuickMessage` + overlay/notifikace |
| Achievement | ❌ V kódu ani v dokumentu není specifikace (badges, odznaky, …). |
| Dark Mode | ❌ `app.dart`: `themeMode: ThemeMode.light` – pouze light. V dokumentu zmíněno. |
| Emoce mode – při kliknutí na smajlík výběr emoji | ⚠️ Status se edituje v dialogu (TextField pro emoji + text). Není to „emoji picker“ – předvybrané smajlíky. |
| Recap | ❌ V dokumentu zmíněn, v kódu ne. |
| Limit na fotky (30 měsíčně, pak top 6) | ❌ Žádný limit ani „top 6“ v kódu. |

---

## 2. Co v dokumentu chybí (ale je v kódu)

- **Auth flow:** Login, Register, Pairing (pairing screen, invite code).  
- **Profil:** Profile screen, edit profile, edit profile picture.  
- **Events:** Kalendář událostí (výročí, schůzky) – Events screen, Add Event sheet, napojení na Countdown/Days Together.  
- **Poznámky:** Typy poznámek (shared, private, bucketList, secretGift), Add Note, Secret Notes screen.  
- **Cycle:** Nastavení (cycle length, period length, last period), logy (flow, mood), predikce – bez popisu „partner message“ v UI.  
- **Router:** Přesný seznam route (např. `/home`, `/memory`, `/data`, `/cycle`, `/lists`, `/events`, `/secret-notes`, `/add-note`, `/add-memory`, …).  
- **Firebase:** Struktura (users, couples, subcollections timeline, intimacy_logs, lists/notes).  
- **RevenueCat:** Zmínka v .cursorrules, v technickém dokumentu chybí.

---

## 3. Plán dalších kroků (prioritizovaný)

### Fáze A – Doplnit dokument a drobné UX

1. **Dokument**  
   - Doplnit sekce: Auth, Pairing, Profile, Events, Notes typy, Router, Firebase schema (stručně).  
   - Upřesnit navigaci: 5. tab = Cycle vs. Lists a kde se LISTS/Organizér otevírá.  
   - Specifikovat Achievement, Recap, Photo limit (30/měsíc, top 6), Dark Mode, Emoce mode (emoji picker).

2. **Theme**  
   - (Volitelně) Přidat do `app_theme.dart` design token pro měkký stín (blur, offset) a používat ho u karet konzistentně.

3. **Cycle – predikce nálady pro partnera**  
   - V `CycleTrackingScreen` (nebo v DATA) zobrazit `status.partnerMessage` pro dnešek (např. banner „Pro partnera: Dnes buď trpělivý“), když je uživatel „partner“ (ne ten, kdo loguje cyklus). Případně vždy pro oba.

### Fáze B – Chybějící funkce ze spec

4. **Emoce mode – emoji picker pro status**  
   - V dialogu úpravy statusu nahradit/ doplnit TextField pro emoji předvybranými emoji (např. 🔋 🤯 😊 ❤️ …). Uložení stejně jako dnes.

5. **Groceries (shared list s checkboxy)**  
   - Nový typ položky nebo nová kolekce: položky s checkboxem (checked/unchecked), real-time sync, sdílené mezi párem.  
   - UI: sekce „Groceries“ v Lists nebo samostatná obrazovka.

6. **Dark Mode**  
   - `AppPalette` / `AppTheme.dark` s dark barvami, v `app.dart` přepínač (např. podle system nebo v Settings).

### Fáze C – Premium / později

7. **Limit fotek (30 měsíčně, top 6)**  
   - Pravidla: max 30 nových fotek (memories) za měsíc; po překročení výběr „top 6“ (nebo jiná logika).  
   - Implementace: Storage/Firestore kvóta + UI pro výběr „top“ memories.

8. **Recap**  
   - Specifikovat (týdenní/měsíční přehled? co přesně) a pak implementovat.

9. **Achievement**  
   - Specifikovat (jaké odznaky, jak se odemykají) a pak implementovat.

10. **RevenueCat**  
    - V dokumentu popsat, kde je integrace (např. DYOS Analytics Premium, zvýšení limitu fotek, …).

---

## 4. Rychlý checklist – co udělat jako další

- [ ] Doplnit technický dokument o Auth, Pairing, Events, Notes, Router, Firebase.  
- [ ] Upřesnit v dokumentu 5. tab (Cycle vs. Lists) a vstup na Organizér.  
- [ ] Zobrazit `partnerMessage` (Cycle) v UI pro partnera.  
- [ ] Emoji picker pro status (Emoce mode).  
- [ ] Specifikovat Achievement, Recap, Photo limit, Dark Mode.  
- [ ] Implementovat Dark Mode (theme + přepínač).  
- [ ] Implementovat Groceries (shared list s checkboxy).  
- [ ] Implementovat limit fotek + top 6 (a případně Recap/Achievement podle spec).

Pokud chceš, můžu konkrétní body (např. „partner message v Cycle“ nebo „emoji picker pro status“) rozepsat do úkolů v kódu krok po kroku.

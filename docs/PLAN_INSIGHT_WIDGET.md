# Plán: Insight Widget

Cíl: jeden widget na Home, který zobrazuje agregované „insighty“ pro pár (počet vzpomínek, intimita, cyklus, nejbližší událost) v jednotném Bento stylu.

---

## 1. Rozsah

- **Fáze 1 (doporučená první):** In-app Bento karta **Insight** na Home obrazovce – agreguje data z existujících providerů a zobrazí je v jedné kartě.
- **Fáze 2 (volitelná):** Nativní widget na ploše (iOS WidgetKit / Android App Widget) – zobrazí zkrácený insight bez otevření aplikace.

---

## 2. Co widget zobrazí (insight data)

| Zdroj | Co z něj vzít | Příklady zobrazení |
|-------|----------------|---------------------|
| **Memories** (`memoriesStreamProvider`) | Počet vzpomínek za tento měsíc (volitelně i minulý měsíc) | „5 memories this month“ |
| **Intimacy** (`intimacyLogsStreamProvider`) | Počet záznamů za tento měsíc | „3 moments this month“ |
| **Cycle** (`cycleSettingsStreamProvider` + `CycleCalculator`) | Aktuální fáze, „next period in X days“ nebo „fertile window“ | „Period in 7 days“ / „Fertile“ |
| **Events** (`nextEventProvider`) | Nejbližší nadcházející událost | „Birthday in 12 days“ |
| **Couple** (`coupleProvider`) | Výročí (`anniversaryDate`) | „42 days together“ (doplňuje _DaysTogetherCard) |

Všechna data už v aplikaci jsou – jde jen o agregaci a jeden společný model.

---

## 3. Data vrstva

### 3.1 Model (volitelný, pro čistotu)

- **Soubor:** `lib/features/dashboard/domain/insight_summary.dart`  
- **Obsah:** Jednoduchý model (nebo record/freezed), např.:
  - `memoriesThisMonth`, `intimacyThisMonth` (int)
  - `cycleSummary` (String? – např. „Period in 7 days“)
  - `nextEvent` (Event? nebo název + datum)
  - `daysTogether` (int?, z anniversary)
- Není nutné ukládat do Firestore – jde o odvozený stav z existujících streamů.

### 3.2 Provider

- **Soubor:** `lib/features/dashboard/presentation/insight_provider.dart`  
- **Provider:** např. `insightSummaryProvider` (Riverpod).
- **Logika:**
  - Závisí na: `memoriesStreamProvider`, `intimacyLogsStreamProvider`, `cycleSettingsStreamProvider`, `nextEventProvider`, `coupleProvider`.
  - Z `memoriesStreamProvider`: filtrovat podle `date` v aktuálním měsíci → `memoriesThisMonth`.
  - Z `intimacyLogsStreamProvider`: filtrovat podle data v aktuálním měsíci → `intimacyThisMonth`.
  - Z cycle: `CycleCalculator.calculateStatus(...)` + z toho sestavit krátký text („Period in X days“ / „Fertile“ / „Safe“ apod.).
  - Z `nextEventProvider`: vzít první nadcházející event → `nextEvent`.
  - Z `coupleProvider`: `anniversaryDate` → počet dní do dnes = `daysTogether`.
- Vrací `AsyncValue<InsightSummary>` (nebo jednoduchý typ bez modelu: např. `AsyncValue<Map<String, dynamic>>` pro rychlý start).

---

## 4. UI – Insight karta na Home

- **Soubor:** `lib/features/dashboard/presentation/widgets/insight_card.dart` (nebo přímo v `home_screen.dart` jako `_InsightCard`).
- **Design:**
  - Bento karta (stejný styl jako ostatní karty na Home), zaoblené rohy 24, stín dle `AppTheme`.
  - Nadpis: „Insights“ nebo „This month“ (titulková řádka).
  - Obsah: 2–4 řádky nebo „chips“:
    - řádek 1: ikona + „X memories this month“ (z memories)
    - řádek 2: ikona + „X moments“ (z intimacy)
    - řádek 3 (volitelně): ikona + cycle text („Period in 7 days“ / „Fertile“)
    - řádek 4 (volitelně): „Next: [event title] in X days“ (z `nextEventProvider`)
  - Barvy: `AppTheme.colors` (primary, text, textSecondary), ikony Phosphor.
- **Chování:**
  - Klik na kartu: buď nic, nebo navigace na existující obrazovku (Timeline / Data / Events) – dle produktu.
- **Umístění na Home:**
  - Přidat `_InsightCard` do seznamu `_cards` v `home_screen.dart` (např. hned za `_PartnerInsightBanner` nebo na začátek gridu), nebo jako samostatný `SliverToBoxAdapter` nad gridem.

---

## 5. Premium (volitelně)

- Pokud chceš insight plně jen pro premium:
  - Obalit obsah karty (nebo celou kartu) do `PremiumGate`: premium uživatelé vidí plný insight, free vidí např. „Unlock insights with DYOS+“ + `lockedChild` (rozmazaný náhled nebo CTA).
- Alternativa: free zobrazí jen „X memories · X moments“, premium navíc cycle + next event (nebo detailnější texty).

---

## 6. Kontrolní seznam implementace (Fáze 1)

1. [ ] **Model** (volitelně): `InsightSummary` v `lib/features/dashboard/domain/insight_summary.dart`.
2. [ ] **Provider:** `insightSummaryProvider` v `lib/features/dashboard/presentation/insight_provider.dart` – agregace z memories, intimacy, cycle, nextEvent, couple.
3. [ ] **Widget:** `InsightCard` v `lib/features/dashboard/presentation/widgets/insight_card.dart` – Bento karta, nadpis „Insights“ / „This month“, řádky s čísly a krátkými texty.
4. [ ] **Integrace:** Přidat `InsightCard` do Home (např. do `_cards` nebo jako sliver).
5. [ ] **Premium:** (volitelně) obalit do `PremiumGate` nebo omezit řádky pro free.

---

## 7. Fáze 2 – Nativní widget (iOS / Android)

- **iOS:** Widget Extension (WidgetKit). Data pro widget: buď sdílené UserDefaults (App Group) nebo malý backend endpoint – aplikace při otevření zapíše poslední `InsightSummary` (nebo zkrácenou verzi) a widget je čte.
- **Android:** App Widget + např. WorkManager nebo AlarmManager – periodicky aktualizovat widget; data opět z cache (např. SharedPreferences) nebo z backendu.
- Oba: minimální layout (např. „5 memories · 3 moments · Period in 7 days“) v jednom řádku nebo 2–3 řádky, barvy dle designu aplikace.

Tento krok můžeš nechat až po dokončení Fáze 1 a ověření, že insight data a UI v aplikaci dávají smysl.

---

## 8. Shrnutí

- **Insight widget (Fáze 1)** = jedna Bento karta na Home, která kombinuje počty (memories, intimacy) a krátké texty (cycle, next event, případně days together) z existujících providerů.
- **Žádné nové API ani Firestore kolekce** – vše odvozené z `memoriesStreamProvider`, `intimacyLogsStreamProvider`, cycle, `nextEventProvider`, `coupleProvider`.
- Po implementaci provideru a `InsightCard` stačí na Home přidat kartu do layoutu a případně zapnout Premium gate.

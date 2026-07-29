# Design: Orgasm Comparison & Monthly Stats on Data & Analytics screen

**Date:** 2026-07-29
**Status:** Approved

---

## Problem

`DataScreen` (`lib/features/tracker/presentation/data_screen.dart`) shows all-time totals (`_StatsRow`), a frequency chart, an initiator chart, and a tags radar. `IntimacyLog` already carries `userOrgasmCount`, `partnerOrgasmCount`, and `duration` per log, but nothing on screen surfaces orgasm totals per person or any current-month breakdown (longest session, average duration, average orgasms).

---

## Scope

- **In scope:** Two new sections on `DataScreen`: an orgasm comparison card (all-time, per person) and a current-month stats card (session count, longest duration, average duration, average orgasms). Pure computation from the already-loaded `logs` list.
- **Out of scope:** Historical month-by-month table/trend (only the current month is shown); changes to `IntimacyLog` model or Firestore schema (fields already exist); new Firestore queries.

---

## Design

### 1. `_OrgasmComparisonChart` widget

Mirrors the existing `_InitiatorChart` pattern exactly (donut `PieChart` + `_LegendItem` list), placed directly below `_InitiatorChart` and above `_TagsRadarChart` in `data_screen.dart`.

Computation:
```dart
int userOrgasms = 0;
int partnerOrgasms = 0;
for (final log in logs) {
  userOrgasms += log.userOrgasmCount;
  partnerOrgasms += log.partnerOrgasmCount;
}
```
Title: "Orgasm Comparison". Reuses `_LegendItem` ("You" / "Partner") and `context.colors.primary` / `context.colors.love` for consistency with `_InitiatorChart`. If both totals are 0, render the same "No data yet" empty state pattern used by `_TagsRadarChart`.

### 2. `_CurrentMonthStats` widget

A `BentoCard` containing a `Row` of four `_StatCard`s (reusing the existing `_StatCard` widget), placed directly below `_StatsRow` and above `_FrequencyChart`.

Computation, filtering `logs` to `log.date.year == now.year && log.date.month == now.month`:
- **Total** — `monthLogs.length`
- **Longest Sex** — `monthLogs.map((l) => l.duration ?? 0).reduce(max)` minutes (skip nulls as 0; if no logs have a non-null duration, show "–")
- **Avg Duration** — mean of non-null `duration` values this month, minutes, one decimal
- **Avg Orgasms** — mean of `(userOrgasmCount + partnerOrgasmCount)` across `monthLogs`, one decimal

Four `_StatCard`s in one `Row` (matching the existing three-card `_StatsRow` layout, just one more `Expanded` + `SizedBox(width: AppSpacing.md)`).

Empty state: if `monthLogs.isEmpty`, all four cards show `0` / `–` rather than erroring (no special-case branch needed — the reduce/mean helpers must guard empty lists explicitly since `Iterable.reduce` throws on empty).

### 3. Data flow

Both widgets take `List<IntimacyLog> logs` (already fetched via `intimacyLogsStreamProvider` in `DataScreen.build`) as their only input — no new providers, no new Firestore reads.

### 4. Testing

`test/tracker/` gets a new file testing the pure aggregation logic (extracted as small top-level or static helper functions rather than buried in widget `build()`, so they're testable without `WidgetTester`):
- `totalOrgasms(logs)` → `(user, partner)` tuple
- `currentMonthStats(logs, now)` → record with count/longest/avgDuration/avgOrgasms, taking `now` as a parameter so the test can pin the month instead of depending on `DateTime.now()`

Cases: empty logs, logs all in current month, logs spanning multiple months (only current month counted), logs with null `duration`.

# Swipeable "This Month" Stats Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the "This Month" stat cards on the Data screen horizontally scrollable instead of squeezed into a fixed row, matching the existing "Best Of" carousel above it.

**Architecture:** Single-widget change: `_CurrentMonthStats` in `lib/features/tracker/presentation/data_screen.dart` swaps its inner `Row` of three `Expanded(_StatCard(...))` children for a `SizedBox` + `ListView.separated` that scrolls horizontally, mirroring the sibling `_BestOfCarousel` widget already in the same file.

**Tech Stack:** Flutter, no new dependencies.

## Global Constraints

- Match the existing `_BestOfCarousel` pattern exactly: `SizedBox(height: 140)`, `ListView.separated` with `scrollDirection: Axis.horizontal`, cards wrapped in `SizedBox(width: 160, ...)`, `separatorBuilder` using `SizedBox(width: AppSpacing.md)`.
- No changes to `_StatCard`, `currentMonthStats()`, or any other section of `data_screen.dart`.
- No page-indicator dots — plain horizontal scroll, same as "Best Of".

---

### Task 1: Convert `_CurrentMonthStats` row to a horizontal scroll list

**Files:**
- Modify: `lib/features/tracker/presentation/data_screen.dart:286-357` (the `_CurrentMonthStats` class)

**Interfaces:**
- Consumes: `currentMonthStats(logs, DateTime.now())` (unchanged, from `../domain/intimacy_stats.dart`), `_StatCard` (unchanged, defined later in the same file at `data_screen.dart:927`).
- Produces: nothing consumed elsewhere — `_CurrentMonthStats` is only used once, at `data_screen.dart:70`.

- [ ] **Step 1: Replace the inner `Row` with a horizontal `ListView.separated`**

Current code (`lib/features/tracker/presentation/data_screen.dart:317-353`):

```dart
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: PhosphorIconsBold.heart,
                  title: 'Total',
                  value: stats.count.toString(),
                  subtitle: 'This month',
                  color: context.colors.love,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _StatCard(
                  icon: PhosphorIconsBold.timer,
                  title: 'Avg Duration',
                  value: stats.avgDurationMinutes == null
                      ? '–'
                      : '${stats.avgDurationMinutes!.toStringAsFixed(1)}m',
                  subtitle: 'This month',
                  color: context.colors.warning,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _StatCard(
                  icon: PhosphorIconsBold.fire,
                  title: 'Avg Orgasms',
                  value: stats.avgOrgasms.toStringAsFixed(1),
                  subtitle: 'This month',
                  color: context.colors.love,
                ),
              ),
            ],
          ),
```

Replace with:

```dart
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
              itemBuilder: (context, index) {
                final cards = [
                  _StatCard(
                    icon: PhosphorIconsBold.heart,
                    title: 'Total',
                    value: stats.count.toString(),
                    subtitle: 'This month',
                    color: context.colors.love,
                  ),
                  _StatCard(
                    icon: PhosphorIconsBold.timer,
                    title: 'Avg Duration',
                    value: stats.avgDurationMinutes == null
                        ? '–'
                        : '${stats.avgDurationMinutes!.toStringAsFixed(1)}m',
                    subtitle: 'This month',
                    color: context.colors.warning,
                  ),
                  _StatCard(
                    icon: PhosphorIconsBold.fire,
                    title: 'Avg Orgasms',
                    value: stats.avgOrgasms.toStringAsFixed(1),
                    subtitle: 'This month',
                    color: context.colors.love,
                  ),
                ];
                return SizedBox(width: 160, child: cards[index]);
              },
            ),
          ),
```

- [ ] **Step 2: Run static analysis**

Run: `flutter analyze lib/features/tracker/presentation/data_screen.dart`
Expected: no new errors/warnings (pre-existing `info`-level lints elsewhere in the file, if any, are unrelated and not required to fix).

- [ ] **Step 3: Manual verification**

Run: `flutter run` (or hot-reload if already running), navigate to the Data screen (bottom nav → Data/Analytics), scroll to the "This Month" card.
Expected: the three stat cards (Total / Avg Duration / Avg Orgasms) scroll horizontally as a group, no text overflow/wrapping, visually consistent with the "Best Of" carousel directly above.

- [ ] **Step 4: Commit**

```bash
git add lib/features/tracker/presentation/data_screen.dart
git commit -m "feat(tracker): make This Month stats horizontally scrollable"
```

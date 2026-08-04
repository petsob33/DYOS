# Swipeable "This Month" stats — design

## Context

The Data screen (`lib/features/tracker/presentation/data_screen.dart`) shows a
"This Month" section (`_CurrentMonthStats`) with three stat cards (Total,
Avg Duration, Avg Orgasms) laid out in a fixed `Row` of `Expanded` cells. On
narrower phones or with larger system font sizes, the cards get squeezed and
text wraps/overflows.

The "Best Of" section directly above it already solves this exact problem for
its own cards by using a horizontally scrollable `ListView.separated` instead
of a fixed row (see `_BestOfCarousel`, added in `891b831`).

## Goal

Make the "This Month" stat cards swipeable/scrollable instead of squeezed
into a fixed row, matching the existing "Best Of" carousel's visual language.

## Design

In `_CurrentMonthStats`:

- Keep the `BentoCard` wrapper and the "This Month" header (icon + title)
  unchanged.
- Replace the inner `Row` of three `Expanded(_StatCard(...))` children with a
  horizontally scrolling list, mirroring `_BestOfCarousel`:
  - `SizedBox(height: 140)` containing a `ListView.separated`
  - `scrollDirection: Axis.horizontal`
  - each card wrapped `SizedBox(width: 160, child: _StatCard(...))`
  - `separatorBuilder` uses `SizedBox(width: AppSpacing.md)`
- No changes to `_StatCard`, to the stats computation (`currentMonthStats`),
  or to any other section of the Data screen.
- No new dependencies.

## Out of scope

- Any other section of the Data screen (Frequency Chart, Initiator Chart,
  Orgasm Comparison, Tags Radar) is unchanged.
- No page-indicator dots — this follows the "Best Of" carousel's plain
  horizontal-scroll style, not a `PageView`.

## Testing

Manual: run the app, open Data screen, confirm the "This Month" cards scroll
horizontally and no longer overflow/wrap on a narrow viewport or with large
text scale.

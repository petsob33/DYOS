# One-job onboarding: Timeline + daily ritual

**Date:** 2026-08-06

## Problem

DYOS has no dedicated first-run onboarding today. After pairing, users land directly
on the `/home` bento-grid dashboard with 9 cards of equal visual weight (Days
Together, Countdown, Intimacy Spark, Taptic Touch, Quick Message, Quick Note, Events,
Lists, Blueprints). There's no guided path pointing a new user at what to do first.

The goal: give new users a short, focused onboarding that gets them to do exactly one
job — build their shared Timeline and complete a daily ritual of small connection
actions. Blueprint, Cycle, and Intimacy Log are demoted out of onboarding entirely;
they remain fully visible on the permanent `/home` dashboard, unchanged.

## Scope

**In scope:** a new first-run onboarding flow (3 screens) shown once per user, between
pairing and the dashboard shell.

**Out of scope:**
- The permanent `/home` dashboard, bottom-tab shell, and `/cycle` tab — unchanged.
  Blueprint/Cycle/Intimacy Log keep their existing prominence there.
- The SP/progression system itself (thresholds, quest rewards, milestones) — unchanged.
  The bypass described below is scoped to the two onboarding entry points only.
- Pairing flow, auth, and the internal logic of existing dashboard cards.

## Flow

Three screens, shown once per user, with a global exit ("X") available on every
screen at all times.

### Screen 1 — "Build your story" (Timeline job)

Short header + CTA "Add your first memory," which pushes into the existing
`AddMemoryScreen` (`/add-memory`), reused unmodified. A "Skip for now" link advances
to Screen 2 without adding anything.

### Screen 2 — "Your daily ritual"

Three tiles: Taptic Touch, Quick Message, Quick Note. Each tile opens the
corresponding *existing* sheet (`TapticTouchCard`, `QuickMessageCard`,
`QuickNoteDashboardCard`) inline, unmodified. Each tile is independently skippable.
A "Continue" button advances to Screen 3 regardless of how many tiles were completed.

### Screen 3 — teaser + finish

One short screen: "There's more waiting — Blueprint, your cycle, and your intimacy
log, whenever you're ready." Single CTA "Go to dashboard" → marks onboarding complete
and routes to `/home`.

### Global exit

An "X" in the top corner, visible on all three screens, jumps straight to `/home`.
This also marks onboarding complete (skipping counts as done, not pending) — it does
not re-prompt the user later.

## Technical architecture

### New route + redirect gate

`app_router.dart`'s existing reactive redirect chain (`auth → pairing → shell`) gains
a fourth state, read from `currentUserDataProvider`:

```
unauthenticated       → /login, /register
authenticated,         → /pairing
  not paired
authenticated, paired,  → /onboarding
  !hasCompletedOnboarding
authenticated, paired,  → shell (/home)
  hasCompletedOnboarding
```

### Data model

Add `hasCompletedOnboarding` (`bool`) to `UserModel` / `users/{uid}`. Per-user, not
per-couple — each partner in a couple goes through their own onboarding
independently (e.g. one partner pairs first and onboards immediately; the other
partner onboards separately whenever they first open the app).

Written once: either on Screen 3's "Go to dashboard" tap, or on global skip via "X".

**Existing users:** no backfill migration needed. Treat a missing field as: already
had a `coupleId` at rollout time → implicitly complete (`true`); not yet paired →
`false`, so anyone newly pairing after this ships goes through onboarding normally.
This can be computed at read time rather than requiring a batch write.

### Feature-gate bypass

`AddMemoryScreen` and the Quick Message sheet are normally gated by
`ProgressionPlan.isFeatureUnlocked(FeatureID.memories | .quickMessages, currentSp,
isPremium)` — a brand-new couple starts at 0 SP, below both the Memories (25 SP) and
Quick Message (200 SP) thresholds. Onboarding needs these to work before that SP
exists.

Fix: thread a `bypassFeatureGate: true` param through the route/screen for these two
onboarding entry points only. Every other entry point (bottom-tab, Quick Add sheet,
dashboard cards) keeps enforcing the gate exactly as today — a user who skips ahead
in onboarding and comes back to add a second memory later, before reaching 25 SP,
will hit the normal locked state again outside onboarding.

### New code footprint

```
lib/features/onboarding/
  presentation/
    screens/
      onboarding_timeline_screen.dart
      onboarding_ritual_screen.dart
      onboarding_teaser_screen.dart
    onboarding_provider.dart   — marks hasCompletedOnboarding
```

No `domain`/`data` layers needed beyond the one new `UserModel` field — onboarding
screens orchestrate navigation/sheets around existing widgets and don't duplicate
their business logic.

## Testing

- Redirect logic: unpaired user never sees `/onboarding`; paired user with
  `hasCompletedOnboarding: false` is forced there; `true` skips straight to `/home`.
- Each screen's skip path advances without side effects (no memory/message/note
  created).
- Global "X" exit marks onboarding complete and routes to `/home` from any of the
  3 screens.
- Gate bypass: `AddMemoryScreen` and Quick Message sheet work from onboarding at
  0 SP; the same actions remain gated when reached from their normal dashboard entry
  points at 0 SP.
- Existing paired users (pre-rollout) never see onboarding on next login.

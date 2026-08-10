# Remove paywall, RevenueCat, and all paid gates

## Goal

Unlock every feature for every user. No RevenueCat SDK ships in the app.
Gamification (Soul Points, phases, cosmetic rewards) stays exactly as-is —
it just no longer blocks access to anything.

## Background

The app currently gates access two ways:

1. **Premium subscription** (`CoupleModel.isPremium`, backed by RevenueCat
   purchases synced to Firestore via `PurchaseService`).
2. **SP milestones** (`ProgressionPlan.isFeatureUnlocked` /
   `isRewardUnlocked`) — free users unlock functional features
   progressively by earning Soul Points; premium unlocks them immediately.

There's also a plain "30 free memories" cap in the timeline/add-memory
screens, unrelated to SP — a straight paid-tier limit.

`ProgressionPlan` already distinguishes **functional** reward kinds
(Widget, Taptic, Blueprint pack, Map view) from **cosmetic** ones (badges,
icons, wallpapers, Lifetime) via `functionalRewardKinds`. That distinction
is exactly the line to draw:

- Functional feature/reward gates → always unlocked, unconditionally.
- Cosmetic rewards → keep unlocking via SP milestones, unchanged. This is
  the "gamification stays" part of the requirement.
- The 30-memory free cap → removed; unlimited for everyone.

## Non-goals

- The "support the dev" one-time Play Billing purchase — separate spec.
- Any change to XP/SP earning, phases, or milestone thresholds.

## Design

### `ProgressionPlan` (single choke point)

- `isFeatureUnlocked(FeatureID feature, int currentSp)` — drop the
  `isPremium` parameter, always return `true`.
- `isRewardUnlocked(RewardKind kind, int currentSp)` — drop `isPremium`;
  return `true` unconditionally for `functionalRewardKinds`, otherwise
  keep the existing SP-milestone comparison for cosmetic kinds.
- `isMilestoneUnlocked`, `spRequiredForFeature`, `nextRewardTip`,
  `phaseForSp`, etc. — unchanged (they drive gamification display, not
  access).

### Downstream unlock checks

Because functional gates now always resolve `true`, every "locked" UI
branch becomes dead code. Rather than leave unreachable branches, remove
them:

- `showLevelUpUnlockSheet` (`level_up_unlock_sheet.dart`) is only ever
  invoked for FeatureID gates that are now always unlocked — delete the
  file and all call sites (`blueprints_card.dart`, `quick_message_card.dart`,
  `timeline_screen.dart` ×2, `level_screen.dart`, `app_router.dart` ×3).
  Each call site is replaced with the direct action it previously guarded
  (e.g. `context.push('/blueprints')` unconditionally).
- `taptic_touch_card.dart`: drop the `unlocked` check and the
  `context.push('/premium')` fallback; taps always send the touch.
- `timeline_screen.dart`: remove `_MemoriesLimitBar`, the free-limit
  snackbar + `/premium` push in the FAB handler, and the `mapViewUnlocked`
  / `memoriesUnlocked` reads (map + memories always accessible).
- `add_memory_screen.dart`: remove the free-limit check and `/premium`
  push before saving a new memory.
- `level_screen.dart`, `app_router.dart` (tab switch, swipe guard, quick-add
  sheet): remove `isPremiumProvider` reads and the now-always-true
  `isFeatureUnlocked` guards.

### Deleted entirely

- `lib/features/premium/` (whole directory): `purchase_service.dart`,
  `premium_provider.dart` (+`.g.dart`), `paywall_modal.dart`,
  `premium_landing_screen.dart`, `premium_copy.dart`.
- `lib/features/gamification/presentation/widgets/level_up_unlock_sheet.dart`.
- `/premium` route in `app_router.dart`.
- `test/security/purchase_sync_security_test.dart` (tests the deleted
  `PurchaseService`).

### Data model

- `CoupleModel`: remove `subscriptionTier`, `subscriptionExpiry`,
  `isPremium`, `premiumExpiration` (regenerate `.freezed.dart`/`.g.dart`).
- `firebase_service.dart` / `subscription_service.dart`: remove
  `updateCoupleSubscription`.
- `pairing_service.dart`: stop initializing subscription fields on couple
  creation.
- `functions/index.js`: remove the two `subscriptionTier: "free"` defaults
  on couple-doc creation.
- Existing Firestore documents keep their `subscriptionTier` /
  `subscriptionExpiry` fields (no migration) — they're simply never read
  or written again.

### RevenueCat removal

- `pubspec.yaml`: remove `purchases_flutter` dependency.
- `main.dart`: remove the `purchases_flutter` import, `_configureRevenueCat`,
  `_revenueCatApiKey`, and its call in `main()`.
- `.github/workflows/build-apk.yml`: remove `REVENUECAT_API_KEY` secret
  wiring and the `--dart-define=REVENUECAT_API_KEY=...` build arg.

### Localization

- `lib/l10n/app_en.arb`, `app_cs.arb`: remove now-unused keys (paywall,
  premium landing, level-up-unlock sheet, free-limit messages) and
  regenerate `lib/l10n/generated/`.

## Testing

- `flutter analyze` — zero new warnings/errors after removals.
- `flutter test` — full suite green; update
  `test/pairing/pairing_service_test.dart` and
  `pairing_integration_test.dart` to drop subscription-field assertions.
- Manual smoke check: dashboard cards (Blueprints, Quick Message, Taptic),
  Timeline (add memory past 30, map view), Level screen, tab switch/swipe
  to Memory tab — all accessible with no premium/paywall UI anywhere, and
  cosmetic badge unlocks at SP milestones still work as before.

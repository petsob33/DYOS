# Google Play Console — Health Apps Declaration

Reference answers for Play Console's health-apps declaration form, triggered because DYOS's
cycle tracker (`lib/features/cycle/`) collects menstrual/reproductive health data. This is
separate from and in addition to the general Data Safety form
(`docs/compliance/play-data-safety.md`).

## Does your app access, collect, use, or share personal or sensitive health information?

**Yes.**

## What health information does your app handle?

- **Menstrual/reproductive health data.** Users manually log period days, flow intensity
  (`FlowIntensity`: light/medium/heavy/spotting), mood (`Mood`: happy/sensitive/energetic/
  irritable), and free-text notes for a given day (`lib/features/cycle/domain/cycle_log_model.dart`).
  The app also computes predicted cycle phases/fertile windows from this logged history
  (`lib/features/cycle/domain/cycle_calculator.dart`) — these are estimates, not medical
  diagnoses.
- **Sexual activity data.** Users manually log intimacy events: date, a 1–5 rating, tags,
  positions, duration, protection used, and free-text notes
  (`lib/features/tracker/domain/intimacy_log_model.dart`). This is adjacent/related sensitive
  data collected by the same "couple health & relationship" feature set, not clinical health data,
  but should be disclosed alongside the cycle data for consistency and caution.

## Is this health data user-entered, or derived from a connected device/sensor?

**Entirely user-entered.** DYOS does not integrate with Health Connect, HealthKit, wearables, or
any device sensor for this data (confirmed: no `health`, `health_connect`, or platform Health
Connect API usage anywhere in `pubspec.yaml` or native code). All cycle and intimacy data comes
from manual form entry in the app (`add_intimacy_sheet.dart`, `cycle_settings_sheet.dart`,
`cycle_tracking_screen.dart`).

## How is the data stored and secured?

- Stored in Cloud Firestore under the couple's shared data space, scoped by `coupleId`.
- Encrypted in transit (TLS) and at rest (Google Cloud default encryption).
- Access restricted via Firestore security rules to the two paired accounts only — no other user
  or unauthenticated party can read it.

## Who can this data be shared with?

Only the user's paired partner, inside the app, as a core and disclosed feature of the product
(pairing is opt-in via invite code and explained in the Privacy Policy §1/§3). It is not sold,
not shared with advertisers, and not shared with any third party for marketing or analytics
purposes. It is shared with Google/Firebase strictly as the underlying cloud storage
infrastructure processor (service provider), not as an independent recipient.

## Is collection of this data optional?

**Yes.** Cycle tracking and intimacy tracking are both opt-in features; a user can use the rest
of the app (timeline, notes, events, chat) without ever logging cycle or intimacy data.

## Can users delete this data?

**Yes.** Individual log entries can be deleted from within the tracker screens, and full account
deletion (Settings → Delete Account) removes all cycle and intimacy data along with the rest of
the account's data (`lib/features/lists/settings_screen.dart`).

## Target audience

18+ / mature, adults only — consistent with `docs/compliance/play-data-safety.md`. This
declaration should not be filled out under a children's/Families Policy context.

# App Store Connect — App Privacy ("Nutrition Label") Answers

Reference answer sheet for App Store Connect's "App Privacy" questionnaire. Same underlying data
flows as `docs/compliance/play-data-safety.md`, mapped to Apple's categories.

**No data is used for tracking** (Apple's specific definition: linking data with third-party data
for advertising, or sharing with a data broker). There is no ad SDK and no cross-app/cross-site
identifier use, so answer **"No, we do not use data for tracking purposes"** — this also means no
App Tracking Transparency (ATT) prompt is required.

For every category below, "Linked to You" = **Yes**, because all data is tied to the user's
Firebase account (email/UID) and, for shared items, to the couple's `coupleId`.

## Contact Info

| Data type | Collected | Linked to user | Used for tracking |
|---|---|---|---|
| Name | Yes | Yes | No |
| Email address | Yes | Yes | No |

Purposes: App Functionality, Account creation.

## Health & Fitness

| Data type | Collected | Linked to user | Used for tracking |
|---|---|---|---|
| Health | Yes — menstrual cycle logs (date, flow, mood, notes) | Yes | No |
| Fitness | No | — | — |

Purpose: App Functionality only. Apple treats menstrual/reproductive health data as sensitive;
make sure the App Store listing's age rating and description are consistent with 18+ content
(see `docs/compliance/health-apps-declaration.md`).

Also disclose intimacy/sexual activity logs (`ratings`, `tags`, `positions`, `duration`,
`protectionUsed`, notes) under **Sensitive Info** (see below), since Apple doesn't have a
dedicated "sexual activity" bucket — Sensitive Info is the closest fit and matches the sensitivity
level.

## Sensitive Info

| Data type | Collected | Linked to user | Used for tracking |
|---|---|---|---|
| Sensitive Info (intimacy/relationship activity logs) | Yes | Yes | No |

Purpose: App Functionality only.

## Financial Info

| Data type | Collected | Linked to user | Used for tracking |
|---|---|---|---|
| Purchase History (subscription tier/status, via RevenueCat) | Yes | Yes | No |

Purpose: App Functionality. No payment card data collected by the app itself — Apple/Google
handle billing directly.

## Location

| Data type | Collected | Linked to user | Used for tracking |
|---|---|---|---|
| Precise Location | Yes (used only when tagging a memory with a place) | Yes | No |
| Coarse Location | Yes | Yes | No |

Purpose: App Functionality (Memories Map). Optional — only invoked when the user chooses to
attach a location to a memory.

## Photos or Videos

| Data type | Collected | Linked to user | Used for tracking |
|---|---|---|---|
| Photos or Videos | Yes | Yes | No |

Purpose: App Functionality (memory photos, profile picture).

## User Content

| Data type | Collected | Linked to user | Used for tracking |
|---|---|---|---|
| Other User Content (notes, timeline entries, lists, calendar events, chat/quick messages) | Yes | Yes | No |
| Customer Support | No (support is via email, not in-app) | — | — |

Purpose: App Functionality.

## Identifiers

| Data type | Collected | Linked to user | Used for tracking |
|---|---|---|---|
| User ID (Firebase UID, coupleId, inviteCode) | Yes | Yes | No |
| Device ID (device_info_plus, App Check attestation, FCM token) | Yes | Yes | No |

Purpose: App Functionality, Security (fraud prevention via App Check).

## Usage Data

| Data type | Collected | Linked to user | Used for tracking |
|---|---|---|---|
| Product Interaction (gamification XP/levels/unlocks, app activity) | Yes | Yes | No |

Purpose: App Functionality.

## Diagnostics

| Data type | Collected | Linked to user | Used for tracking |
|---|---|---|---|
| Crash Data (Firebase Crashlytics) | Yes | Yes (Crashlytics can associate with user identifiers) | No |
| Performance Data | Yes | Yes | No |

Purpose: App Functionality (Analytics/Diagnostics).

## Not collected

- **Contacts** — no contact list access.
- **Search History**, **Browsing History** — not collected.
- **Audio Data** — no microphone/voice features.
- **Advertising Data** — no ad SDK present (AdMob was removed).

## Note: Sign in with Apple

DYOS offers Google Sign-In on iOS but does not implement Sign in with Apple. Apple's App Store
Review Guideline 4.8 generally requires offering Sign in with Apple whenever another third-party
login option is offered (with some exemptions, e.g. education/enterprise apps). This is an App
Store approval risk independent of the privacy nutrition label — worth resolving (either add
Sign in with Apple, or confirm an applicable exemption) before submitting for iOS review.

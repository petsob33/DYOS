# Per-couple photo storage quota (150MB)

**Date:** 2026-08-10

## Problem

Couples' media uploads to `memories/{coupleId}/` in Firebase Storage are unbounded —
there is no per-couple ceiling, and no visibility into how much storage a given
couple is consuming. As the user base grows this is an open-ended Storage cost risk.
The goal is a hard per-couple cap of 150MB on `memories/` storage, enforced
server-side (client-side control alone can be bypassed by a modified build).

## Scope

**In scope:**
- A Firestore counter tracking bytes used per couple under `memories/{coupleId}/`.
- Cloud Functions Storage triggers that keep the counter accurate on upload/delete.
- A Storage Rules change enforcing the 150MB ceiling and a per-file 2MB cap on images
  (videos keep their existing 10MB cap).
- A one-time backfill script to seed the counter for couples that already have media.
- Client-side handling of the new "quota exceeded" upload failure.

**Out of scope:**
- Client-side image compression via `flutter_image_compress`. `image_picker` already
  downsizes to 1024px/quality 85 on pick (`add_memory_screen.dart`,
  `edit_profile_picture_screen.dart`, both already commented "with compression") —
  more aggressive than the 1600px/q80 originally considered. No client compression
  change is needed.
- The existing server-side `compressImage` Cloud Function (sharp, 2048px/q85) — kept
  as-is, unrelated to this change except that its two-finalize-events-per-photo
  behavior must be accounted for by the new tracking trigger (see below).
- `profile_pictures/{userId}/` — already capped at 2MB/file by existing rules, and two
  users' profile pictures are negligible next to a 150MB budget. Not included in the
  quota counter.
- Any change to allowed file types/extensions in `memories/`.

## Data model

New Firestore doc: `couples/{coupleId}/usage/current`
```
{ bytesUsed: number }
```

Represents total bytes currently stored under `memories/{coupleId}/` (photos +
videos, using each file's *final resting size* — see below).

## Lifecycle: doc creation (chicken-and-egg)

The Storage Rule (below) needs `usage/current` to already exist with a `bytesUsed`
field before a couple's *first* upload, but the tracking trigger only writes to it
*after* an upload finalizes. If the doc doesn't exist yet, `firestore.get()` in the
rule fails and the very first upload would be denied.

Fix: seed `couples/{coupleId}/usage/current` with `{ bytesUsed: 0 }` at couple-creation
time, inside `setCoupleClaims()` in `functions/index.js` (called from both
`pairWithInviteCode` and `pairWithEmail`), in the same write that sets the custom
claims.

## Cloud Function triggers

New triggers in `functions/index.js`, on the same bucket-wide
`functions.storage.object()` trigger type `compressImage` already uses (v1 Storage
triggers fire for every object in the bucket; there's no declarative path filter).
The handler filters to paths starting with `memories/` and returns early otherwise,
matching `compressImage`'s existing pattern. coupleId is parsed via
`object.name.split('/')[1]`.

### onFinalize — increment

The existing `compressImage` function re-encodes every image upload in place, which
fires a *second* `onFinalize` event for the same path (tagged
`object.metadata.compressed === 'true'`, which `compressImage` itself uses to avoid
re-processing its own output). Naively incrementing on every `onFinalize` would
double-count every photo.

Rule to avoid double-counting and count the real final size:
- If the object is an image **and** not yet tagged `compressed` → skip. This is the
  raw upload; wait for the compressed overwrite event, which carries the true
  resting size.
- Otherwise (the compressed-echo event, or a video — which `compressImage` never
  touches, so it only ever fires once) → increment `bytesUsed` by `object.size`.

**Known limitation:** if `sharp` compression throws inside `compressImage`, no
compressed-echo event ever fires, so that file's bytes are never added to the
counter. This is accepted as a rare, safe-direction failure (undercounts usage,
never overcounts) rather than adding cross-invocation state to close the gap.

### onDelete — decrement

Decrement `bytesUsed` by `object.size`, clamped so the counter never goes below 0.

Both handlers use `FieldValue.increment()` against
`couples/{coupleId}/usage/current` so concurrent uploads/deletes don't race.

## Storage Rules changes

In the existing `memories/{coupleId}/{fileName}` match block in `storage.rules`:

- Split the size cap by content type: images `< 2MB`, videos keep the current
  `< 10MB` (unchanged from today).
- Add a quota check: `bytesUsed < 150_000_000`, read via
  `firestore.get(/databases/(default)/documents/couples/$(coupleId)/usage/current)`.

This reuses the `firestore.get()` cross-service pattern that previously proved
unreliable in this project for couple-membership checks (see the comment at the top
of `storage.rules`, which is why membership now uses the `coupleId` custom claim
instead). We're trying it again here for a different field/purpose per explicit
decision, but it's the highest-risk part of this change — it needs real upload
testing at/near the 150MB boundary before being considered done, with a documented
fallback (moving enforcement into a callable Cloud Function) if it misbehaves the
same way.

## Backfill script

New one-off script, `functions/scripts/backfill-usage.js`, run manually
(`node functions/scripts/backfill-usage.js`) against production before the new rule
goes live:

- For every doc in `couples/`, list Storage objects with
  `bucket.getFiles({ prefix: 'memories/${coupleId}/' })` and sum their sizes.
- `set()` (not increment) `couples/{coupleId}/usage/current.bytesUsed` to that total,
  so it's idempotent and safe to re-run.
- Couples with no existing media get `bytesUsed: 0`.

## Client-side error handling

`MemoryRepository.createMemory()` currently wraps upload failures in a generic
`Exception('Failed to upload file ...')`. Add a check for the Storage
`unauthorized`/permission-denied failure mode specifically, so the UI can show a
"You've reached your couple's storage limit" message instead of a generic upload
error. Scope: `memory_repository.dart` only (the only place that uploads into
`memories/`).

## Rollout order

1. Deploy Cloud Functions changes (new triggers + `setCoupleClaims` doc-seeding).
2. Run the backfill script against production.
3. Deploy the updated `storage.rules`.

Running the rule change before backfill would measure existing heavy users against a
false `bytesUsed: 0` and let them upload well past 150MB before the counter catches
up.

## Testing

- `functions/security_helpers.test.js` pattern: add unit tests for the coupleId-path
  parsing and the skip/count decision logic (image-not-yet-compressed → skip;
  compressed-echo or video → count), independent of live Storage/Firestore.
- Manual verification (per the risk noted above): upload near and over the 150MB
  boundary against a real couple/emulator to confirm the `firestore.get()` rule
  check behaves correctly and consistently, not just on the first try.
- Manual verification that a quota-denied upload surfaces the friendly client-side
  message rather than a raw exception.

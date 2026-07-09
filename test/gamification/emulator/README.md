# Gamification XP transaction race-condition test

Proves `grantQuestXpIfEligible`'s transaction pattern (read grant state,
check, increment XP + set flag - all in one Firestore transaction) is safe
under real concurrency, against the Firestore emulator.

The Dart `fake_cloud_firestore` package (used in
`test/gamification/subscription_service_xp_test.dart`) does not serialize
concurrent `runTransaction()` calls - its `_DummyTransaction` has no locking
or retry - so it can't demonstrate the race is actually closed. Only the
real Firestore engine (via the emulator) does.

## Running

```sh
cd test/gamification/emulator
npm install
cd ../../..
firebase emulators:exec --project demo-dyos-gamification-test --only firestore \
  "cd test/gamification/emulator && npm test"
```

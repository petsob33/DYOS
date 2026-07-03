# Firestore rules emulator tests

Tests here exercise the real `firestore.rules` file against the local Firestore
emulator via `@firebase/rules-unit-testing`. This is separate from the Dart
`fake_cloud_firestore` tests in `test/security/*.dart`: that Dart package's
security-rules engine does not populate `resource`/`request.resource` or
support `get()`/`exists()`/custom `function`s (see
`fake_firebase_security_rules`'s README and
`FakeFirebaseFirestore.maybeThrowSecurityException`), so it can't evaluate
rules that depend on document data - which is exactly what this project's
notes access-control rules do.

## Running

```sh
cd test/security/rules
npm install
cd ../../..
firebase emulators:exec --project demo-dyos-rules-test --only firestore \
  "cd test/security/rules && npm test"
```

(`--only firestore` and the `demo-` project prefix run fully offline, no
Firebase login/billing project required.)

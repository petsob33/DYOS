# DYOS

Flutter app with Firebase (Firestore, Functions, Auth) backend. Cloud Functions live in `functions/` (Node.js).

## Repo search hygiene

`build/`, `.dart_tool/`, and `functions/node_modules/` are gitignored but **not** excluded from raw shell tools (`grep -r`, `find .`, etc.) — `.gitignore` only affects `git`. After a `flutter build`/`flutter run`, `build/` alone can contain 30k+ files (Android/Kotlin/dex intermediates, `.dill` caches) and multiple GB. A recursive search from the repo root that doesn't exclude these directories will flood context with irrelevant build-artifact output.

Always scope searches away from them, e.g.:

```
grep -rn "pattern" lib/ test/ functions/
find . -type f -not -path "./build/*" -not -path "./.dart_tool/*" -not -path "*/node_modules/*"
```

Run `flutter clean` occasionally if `build/` has grown large.

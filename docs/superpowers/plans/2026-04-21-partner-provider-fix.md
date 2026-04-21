# Partner Provider Fix Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix the partner info section on the home screen staying empty after pairing by converting `partnerProvider` from a one-shot `FutureProvider` to a reactive `StreamProvider` that watches the already-correct `coupleProvider` stream.

**Architecture:** `partnerProvider` is rewritten to watch `coupleProvider` (a `StreamProvider<CoupleModel?>` that already uses a real-time Firestore stream via `userProvider`). When the couple emits data, the new `partnerProvider` finds the partner UID from `couple.members` and fetches the partner's user document. The home screen uses `AsyncValue<UserModel?>` which is identical for both `FutureProvider` and `StreamProvider` — no UI changes needed.

**Tech Stack:** Flutter, Riverpod 2.x (`riverpod_annotation` + `riverpod_generator`), Cloud Firestore, `build_runner`

---

### Task 1: Convert `partnerProvider` to a `StreamProvider`

**Files:**
- Modify: `lib/features/auth/presentation/auth_providers.dart:63-86`

- [ ] **Step 1: Replace the `partnerProvider` implementation**

Open `lib/features/auth/presentation/auth_providers.dart` and replace lines 63–86:

**Before:**
```dart
@riverpod
Future<UserModel?> partner(PartnerRef ref) async {
  final firebaseService = ref.watch(firebaseServiceProvider);
  // Depend on both current user and couple providers
  final couple = await ref.watch(currentCoupleProvider.future);
  final user = ref.watch(currentUserProvider);

  if (user == null || couple == null) {
    return null;
  }
  
  final partnerUid = couple.members.firstWhere(
    (uid) => uid != user.uid,
    orElse: () => '',
  );

  if (partnerUid.isEmpty) {
    return null;
  }

  // Directly fetch the partner's user document
  final userRepository = ref.watch(userRepositoryProvider);
  return await userRepository.getUserById(partnerUid);
}
```

**After:**
```dart
@riverpod
Stream<UserModel?> partner(PartnerRef ref) async* {
  final coupleAsync = ref.watch(coupleProvider);

  final couple = coupleAsync.valueOrNull;
  if (couple == null) {
    yield null;
    return;
  }

  final user = ref.watch(currentUserProvider);
  if (user == null) {
    yield null;
    return;
  }

  final partnerUid = couple.members.firstWhere(
    (uid) => uid != user.uid,
    orElse: () => '',
  );

  if (partnerUid.isEmpty) {
    yield null;
    return;
  }

  final userRepository = ref.watch(userRepositoryProvider);
  yield await userRepository.getUserById(partnerUid);
}
```

- [ ] **Step 2: Verify no unused imports remain**

Check the top of `lib/features/auth/presentation/auth_providers.dart`. The import for `firebase_service.dart` was previously needed for `firebaseServiceProvider` inside `partnerProvider`. Confirm `firebaseServiceProvider` is still used elsewhere in the file (it is — in `isUserPaired`, `currentCouple`, `currentUserData`). No import changes needed.

---

### Task 2: Regenerate the Riverpod generated file

**Files:**
- Modify: `lib/features/auth/presentation/auth_providers.g.dart` (generated — do not edit manually)

- [ ] **Step 1: Run build_runner**

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected output: lines like `[INFO] Generating build script...` ending with `Succeeded after ...`. No errors.

- [ ] **Step 2: Verify the generated file changed**

```bash
git diff --stat lib/features/auth/presentation/auth_providers.g.dart
```

Expected: the file shows as modified. The generated provider class will change from `FutureProvider` internals to `StreamProvider` internals (look for `AsyncNotifierProvider` → `StreamProvider` or similar change in the diff).

---

### Task 3: Verify the fix works end-to-end

- [ ] **Step 1: Run the app and pair two accounts**

```bash
flutter run
```

Sign in with Account A. Note the invite code. On a second device (or emulator), sign in with Account B and enter Account A's code. After pairing, both devices should navigate to `/home` and the partner info widget should display Account A's (or B's) name and status — not a spinner and not an empty state.

- [ ] **Step 2: Verify reactivity on re-login**

Sign out of Account A and sign back in. The home screen should immediately show partner info without requiring a re-pair.

- [ ] **Step 3: Commit**

```bash
git add lib/features/auth/presentation/auth_providers.dart \
        lib/features/auth/presentation/auth_providers.g.dart
git commit -m "fix: convert partnerProvider to StreamProvider for reactive partner info"
```

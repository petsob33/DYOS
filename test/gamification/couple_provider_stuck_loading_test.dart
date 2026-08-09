import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// Reproduces the "stuck loading" bug that made displayed SP (XP) stay at 0
// (see currentXpProvider's `loading: () => 0` fallback in user_stats_provider.dart)
// even though the couple document already has a value in Firestore.
//
// Root cause: `couple` (auth_providers.dart) rebuilt its Stream by re-wrapping
// `currentCoupleProvider.stream`. That accessor exposes a broadcast stream that
// does not replay an already-emitted value to a listener that starts watching
// after the emission happened - exactly the pattern the `currentCouple`,
// `currentUserData`, and `partner` providers were already fixed to avoid (see
// the comment on `currentCouple` in auth_providers.dart). `couple` was missed,
// so anything built on top of it (like currentXpProvider) could get stuck on
// its AsyncLoading fallback until the *next* Firestore write happened to
// coincidentally produce a fresh emission.
void main() {
  test('re-wrapping an upstream provider.stream misses an already-emitted value', () async {
    final controller = StreamController<int>.broadcast();
    addTearDown(controller.close);

    final upstream = StreamProvider<int>((ref) => controller.stream);
    // Old (buggy) `couple` pattern: `ref.watch(currentCoupleProvider.stream)`.
    final stuck = StreamProvider<int>((ref) => ref.watch(upstream.stream));

    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Something reads the upstream value first (e.g. another widget), causing
    // `upstream` to emit before `stuck` ever starts listening.
    container.listen(upstream, (_, __) {}, fireImmediately: true);
    controller.add(42);
    await Future<void>.delayed(Duration.zero);
    expect(container.read(upstream).valueOrNull, 42);

    // `stuck` starts watching only now - after the emission it needed already happened.
    final stuckValues = <AsyncValue<int>>[];
    container.listen(stuck, (_, next) => stuckValues.add(next), fireImmediately: true);
    await Future<void>.delayed(Duration.zero);

    // Bug: stuck never receives 42, it stays on AsyncLoading forever unless
    // controller emits again.
    expect(container.read(stuck).isLoading, isTrue);
    expect(container.read(stuck).valueOrNull, isNull);
  });

  test('fix: deriving from upstream.valueOrNull sees the already-emitted value', () async {
    final controller = StreamController<int>.broadcast();
    addTearDown(controller.close);

    final upstream = StreamProvider<int>((ref) => controller.stream);
    // Fixed `couple` pattern: read the AsyncValue directly instead of re-wrapping `.stream`.
    final fixed = StreamProvider<int>((ref) => Stream.value(ref.watch(upstream).valueOrNull ?? -1));

    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.listen(upstream, (_, __) {}, fireImmediately: true);
    controller.add(42);
    await Future<void>.delayed(Duration.zero);
    expect(container.read(upstream).valueOrNull, 42);

    final fixedValues = <AsyncValue<int>>[];
    container.listen(fixed, (_, next) => fixedValues.add(next), fireImmediately: true);
    await Future<void>.delayed(Duration.zero);

    expect(container.read(fixed).valueOrNull, 42);
  });
}

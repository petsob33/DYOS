// Regression test for layout overflow on the Data screen: fixed-height stat
// cards and un-Expanded header rows previously overflowed once the Czech
// locale's strings were long enough to wrap, and the loading skeleton threw
// an unbounded-height error from being a bare ListView inside the screen's
// outer scroll view.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ouros_app/core/theme/app_theme.dart';
import 'package:ouros_app/features/auth/domain/user_model.dart';
import 'package:ouros_app/features/auth/domain/couple_model.dart';
import 'package:ouros_app/features/auth/presentation/auth_providers.dart';
import 'package:ouros_app/features/dashboard/presentation/hearts_streak_provider.dart';
import 'package:ouros_app/features/tracker/domain/intimacy_log_model.dart';
import 'package:ouros_app/features/tracker/presentation/intimacy_provider.dart';
import 'package:ouros_app/features/tracker/presentation/data_screen.dart';
import 'package:ouros_app/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('DataScreen renders without overflow under cs locale', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final now = DateTime.now();
    final logs = List<IntimacyLog>.generate(9, (i) {
      final date = now.subtract(Duration(days: i * 4));
      return IntimacyLog(
        id: 'log$i',
        date: date,
        initiatorId: i.isEven ? 'u1' : 'u2',
        rating: 3 + (i % 3),
        tags: const ['Romantic', 'Slow', 'Passionate'],
        positions: const ['Missionary'],
        userOrgasmCount: i % 3,
        partnerOrgasmCount: (i + 1) % 3,
        duration: 20 + i * 5,
        protectionUsed: true,
      );
    });

    final user = const UserModel(uid: 'u1', email: 'a@example.com', coupleId: 'c1');
    final couple = const CoupleModel(id: 'c1', members: ['u1', 'u2']);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          intimacyLogsStreamProvider.overrideWith((ref) => Stream.value(logs)),
          userProvider.overrideWith((ref) => Stream.value(user)),
          currentCoupleProvider.overrideWith((ref) => Stream.value(couple)),
          hapticSignalsHistoryProvider.overrideWith((ref) => Stream.value(const [])),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          locale: const Locale('cs'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const DataScreen(),
        ),
      ),
    );

    // Deliberately don't await the streams settling on the first pump: this
    // exercises the loading state (previously an unbounded-height ListView)
    // before the data-populated state (previously overflowing stat cards).
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    // No assertion needed: a RenderFlex/viewport layout error is reported
    // via FlutterError during pump and fails the test automatically.
  });
}

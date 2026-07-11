import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ouros_app/features/dashboard/presentation/widgets/haptic_notification_overlay.dart';
import 'package:ouros_app/features/dashboard/presentation/widgets/quick_message_notification_overlay.dart';

/// Regression coverage for the notification-overlay freeze: both overlays are
/// shown via showDialog() and auto-dismiss on a timer by removing their own
/// route (see haptic_notification_overlay.dart / quick_message_notification_overlay.dart).
/// Before that fix, the timer called Navigator.pop(), which closes whatever
/// route is topmost - if a second notification arrived before the first one's
/// timer fired, the first overlay's timer would pop the second (topmost)
/// overlay instead of itself, leaving the first stuck forever as an
/// invisible, full-screen, touch-blocking barrier.
void main() {
  Future<BuildContext> pumpHostApp(WidgetTester tester) async {
    late BuildContext capturedContext;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            capturedContext = context;
            return const Scaffold(body: SizedBox());
          },
        ),
      ),
    );
    return capturedContext;
  }

  Future<void> showHaptic(BuildContext context) => showDialog<void>(
        context: context,
        barrierColor: Colors.transparent,
        barrierDismissible: true,
        builder: (_) => HapticNotificationOverlay(),
      );

  Future<void> showQuickMessage(BuildContext context, String message) =>
      showDialog<void>(
        context: context,
        barrierColor: Colors.transparent,
        barrierDismissible: true,
        builder: (_) => QuickMessageNotificationOverlay(message: message),
      );

  group('HapticNotificationOverlay', () {
    testWidgets('renders and auto-dismisses on its own after ~1.5s', (
      tester,
    ) async {
      final context = await pumpHostApp(tester);

      showHaptic(context);
      await tester.pump();

      expect(find.byType(HapticNotificationOverlay), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 1600));
      await tester.pumpAndSettle();

      expect(find.byType(HapticNotificationOverlay), findsNothing);
    });

    testWidgets(
      'a second haptic notification arriving before the first dismisses does not leave a stuck invisible barrier',
      (tester) async {
        final context = await pumpHostApp(tester);

        // First notification arrives.
        showHaptic(context);
        await tester.pump();
        expect(find.byType(HapticNotificationOverlay), findsOneWidget);

        // Second notification arrives well before the first one's ~1.5s
        // timer, but with enough separation that each overlay's own timer
        // lands in its own pump() call - a single large pump can let both
        // timers fire before either route removal is actually processed,
        // masking the bug.
        await tester.pump(const Duration(milliseconds: 1000));
        showHaptic(context);
        await tester.pump();
        expect(find.byType(HapticNotificationOverlay), findsNWidgets(2));

        // Past the first overlay's own timer (fires ~1.5s after it was shown).
        await tester.pump(const Duration(milliseconds: 700));
        // Past the second overlay's own timer (fires ~1.5s after *it* was shown).
        await tester.pump(const Duration(milliseconds: 1000));
        await tester.pumpAndSettle();

        // Both must be gone - if either is still present, it is a permanent,
        // invisible, full-screen barrier silently swallowing all touch input.
        expect(find.byType(HapticNotificationOverlay), findsNothing);
      },
    );
  });

  group('QuickMessageNotificationOverlay', () {
    testWidgets('displays the message and auto-dismisses on its own after ~4s', (
      tester,
    ) async {
      final context = await pumpHostApp(tester);

      showQuickMessage(context, 'Thinking of you');
      await tester.pump();

      expect(find.text('Thinking of you'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 4500));
      await tester.pumpAndSettle();

      expect(find.byType(QuickMessageNotificationOverlay), findsNothing);
    });

    testWidgets(
      'a second quick message arriving before the first dismisses does not leave a stuck invisible barrier',
      (tester) async {
        final context = await pumpHostApp(tester);

        showQuickMessage(context, 'First message');
        await tester.pump();
        expect(find.byType(QuickMessageNotificationOverlay), findsOneWidget);

        await tester.pump(const Duration(milliseconds: 2000));
        showQuickMessage(context, 'Second message');
        await tester.pump();
        expect(find.byType(QuickMessageNotificationOverlay), findsNWidgets(2));

        // Past the first overlay's own timer + reverse animation (fires ~4s
        // after it was shown, see the comment in the haptic test above for
        // why the two overlays' timers need to land in separate pump calls).
        await tester.pump(const Duration(milliseconds: 2500));
        // Past the second overlay's own timer + reverse animation.
        await tester.pump(const Duration(milliseconds: 2000));
        await tester.pumpAndSettle();

        expect(find.byType(QuickMessageNotificationOverlay), findsNothing);
      },
    );
  });
}

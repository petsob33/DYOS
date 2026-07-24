import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ouros_app/core/theme/app_theme.dart';
import 'package:ouros_app/features/dashboard/presentation/widgets/haptic_notification_overlay.dart';
import 'package:ouros_app/features/dashboard/presentation/widgets/quick_message_notification_overlay.dart';

/// Regression coverage for the notification-overlay freeze: both overlays
/// used to be shown via showDialog(), which inserts a full-screen modal
/// barrier that blocks all touch input to the rest of the app for as long as
/// the notification is visible. They are now inserted directly into the
/// Overlay (non-modal, see haptic_notification_overlay.dart /
/// quick_message_notification_overlay.dart), so the app underneath stays
/// interactive, and each overlay removes itself via an onDismiss callback
/// instead of popping a route - avoiding the old bug where a second
/// notification's timer could pop the wrong (topmost) route and leave the
/// first one stuck forever as an invisible, full-screen, touch-blocking
/// barrier.
void main() {
  Future<BuildContext> pumpHostApp(WidgetTester tester) async {
    late BuildContext capturedContext;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
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

  OverlayEntry showHaptic(BuildContext context) {
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => HapticNotificationOverlay(
        onDismiss: () {
          if (entry.mounted) entry.remove();
        },
      ),
    );
    Overlay.of(context).insert(entry);
    return entry;
  }

  OverlayEntry showQuickMessage(BuildContext context, String message) {
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => QuickMessageNotificationOverlay(
        message: message,
        onDismiss: () {
          if (entry.mounted) entry.remove();
        },
      ),
    );
    Overlay.of(context).insert(entry);
    return entry;
  }

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
        // timers fire before either removal is actually processed, masking
        // the bug.
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

    testWidgets('does not block touches to widgets underneath it', (
      tester,
    ) async {
      var tapped = false;
      late BuildContext capturedContext;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Builder(
            builder: (context) {
              capturedContext = context;
              // Positioned away from the notification card (which renders
              // near the top of the screen) so this specifically verifies
              // that the rest of the app stays interactive, not just that
              // taps land on the card itself.
              return Scaffold(
                body: Align(
                  alignment: Alignment.bottomCenter,
                  child: ElevatedButton(
                    onPressed: () => tapped = true,
                    child: const Text('Underneath'),
                  ),
                ),
              );
            },
          ),
        ),
      );

      showHaptic(capturedContext);
      await tester.pump();

      await tester.tap(find.byType(ElevatedButton), warnIfMissed: false);
      await tester.pump();

      expect(tapped, isTrue);

      // Drain the overlay's own auto-dismiss timer so it doesn't trip the
      // test framework's "pending timer after dispose" leak check.
      await tester.pump(const Duration(milliseconds: 1600));
      await tester.pumpAndSettle();
    });
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

    testWidgets('does not block touches to widgets underneath it', (
      tester,
    ) async {
      var tapped = false;
      late BuildContext capturedContext;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Builder(
            builder: (context) {
              capturedContext = context;
              // Positioned away from the notification card (which renders
              // near the top of the screen) so this specifically verifies
              // that the rest of the app stays interactive, not just that
              // taps land on the card itself.
              return Scaffold(
                body: Align(
                  alignment: Alignment.bottomCenter,
                  child: ElevatedButton(
                    onPressed: () => tapped = true,
                    child: const Text('Underneath'),
                  ),
                ),
              );
            },
          ),
        ),
      );

      showQuickMessage(capturedContext, 'Hi there');
      await tester.pump();

      await tester.tap(find.byType(ElevatedButton), warnIfMissed: false);
      await tester.pump();

      expect(tapped, isTrue);

      // Drain the overlay's own auto-dismiss timer so it doesn't trip the
      // test framework's "pending timer after dispose" leak check.
      await tester.pump(const Duration(milliseconds: 4500));
      await tester.pumpAndSettle();
    });

    testWidgets('can be dismissed early by swiping it away', (tester) async {
      final context = await pumpHostApp(tester);

      final entry = showQuickMessage(context, 'Swipe me away');
      await tester.pump();
      // Let the entrance animation finish so the card is fully in place.
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(QuickMessageNotificationOverlay), findsOneWidget);
      expect(entry.mounted, isTrue);

      await tester.drag(find.byType(Dismissible), const Offset(0, -500));
      await tester.pumpAndSettle();

      expect(find.byType(QuickMessageNotificationOverlay), findsNothing);
      expect(entry.mounted, isFalse);
    });
  });
}

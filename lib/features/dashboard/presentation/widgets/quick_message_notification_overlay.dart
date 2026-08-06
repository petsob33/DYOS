import 'dart:async';

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/l10n/build_context_l10n_extension.dart';
import '../../../../core/widgets/bento_card.dart';

class QuickMessageNotificationOverlay extends StatefulWidget {
  final String message;

  /// Called exactly once, either when the auto-dismiss timer fires or when
  /// the user swipes the card away. The caller (whoever inserted this into
  /// an Overlay) is responsible for actually removing it from the tree.
  final VoidCallback onDismiss;

  const QuickMessageNotificationOverlay({
    required this.message,
    required this.onDismiss,
    super.key,
  });

  @override
  State<QuickMessageNotificationOverlay> createState() =>
      _QuickMessageNotificationOverlayState();
}

class _QuickMessageNotificationOverlayState
    extends State<QuickMessageNotificationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  // Swiping and the auto-dismiss timer can race to dismiss the same card;
  // this makes sure widget.onDismiss() is only ever invoked once.
  bool _dismissing = false;
  final Key _dismissibleKey = UniqueKey();
  Timer? _autoDismissTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    // Auto-dismiss after 4 seconds, unless the user swipes it away first.
    _autoDismissTimer = Timer(
      const Duration(milliseconds: 4000),
      _dismissViaTimer,
    );
  }

  void _dismissViaTimer() {
    if (_dismissing || !mounted) return;
    _dismissing = true;
    _controller.reverse().then((_) => widget.onDismiss());
  }

  void _dismissViaSwipe() {
    if (_dismissing) return;
    _dismissing = true;
    _autoDismissTimer?.cancel();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // MaterialType.transparency (not just a transparent color) is required
    // here: a plain Material(color: Colors.transparent) still defaults to
    // MaterialType.canvas, whose ink-features layer absorbs every hit test
    // over its whole bounds regardless of paint color - it doesn't merely
    // look invisible, it silently blocks all touches to whatever is behind
    // it. Since this widget is inserted directly into the Overlay (see
    // home_screen.dart), it is sized to fill the whole screen even though
    // only the card near the top is visible, so this was blocking input to
    // the entire app for as long as the notification was showing.
    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Align(
            alignment: Alignment.topCenter,
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _opacityAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Dismissible(
                    key: _dismissibleKey,
                    direction: DismissDirection.up,
                    onDismissed: (_) => _dismissViaSwipe(),
                    child: BentoCard(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: context.colors.primary.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              PhosphorIconsBold.chatCircle,
                              color: context.colors.primary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  context.l10n.quickMessageNotificationOverlayLabel,
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: context.colors.textSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  widget.message,
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        color: context.colors.text,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

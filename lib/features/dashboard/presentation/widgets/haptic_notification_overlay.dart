import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/theme/app_theme.dart';

/// Overlay widget for haptic signal notification
class HapticNotificationOverlay extends StatefulWidget {
  /// Called exactly once when the auto-dismiss timer fires. The caller
  /// (whoever inserted this into an Overlay) is responsible for actually
  /// removing it from the tree.
  final VoidCallback onDismiss;

  const HapticNotificationOverlay({required this.onDismiss, super.key});

  @override
  State<HapticNotificationOverlay> createState() =>
      _HapticNotificationOverlayState();
}

class _HapticNotificationOverlayState extends State<HapticNotificationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    // Auto-dismiss after animation
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      widget.onDismiss();
    });
  }

  @override
  void dispose() {
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
    // only the small heart icon in the middle is visible, so this was
    // blocking input to the entire app for as long as the notification was
    // showing. This overlay has no interactive content of its own, so
    // IgnorePointer belt-and-suspenders it too.
    return IgnorePointer(
      child: Material(
        type: MaterialType.transparency,
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _opacityAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppTheme.colors.love.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.colors.love.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(
                      PhosphorIconsBold.heart,
                      color: AppTheme.colors.love,
                      size: 64,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

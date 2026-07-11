import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/theme/app_theme.dart';

/// Overlay widget for haptic signal notification
class HapticNotificationOverlay extends StatefulWidget {
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
      final navigator = Navigator.of(context);
      final route = ModalRoute.of(context);
      // Remove this overlay's own route explicitly, rather than popping
      // whatever happens to be on top of the stack. Otherwise, if another
      // dialog was shown after this one, this timer would pop that other
      // dialog instead, leaving this overlay stuck forever as an invisible,
      // full-screen barrier that blocks all touch input.
      if (route != null && route.isActive) {
        navigator.removeRoute(route);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
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
    );
  }
}

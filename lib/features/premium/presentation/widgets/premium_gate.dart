import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../auth/presentation/auth_providers.dart';
import 'paywall_modal.dart';

/// Shows premium content or a locked (blurred + lock) state based on the
/// couple's real-time premium status from the Firestore stream.
class PremiumGate extends ConsumerWidget {
  const PremiumGate({
    super.key,
    required this.child,
    required this.lockedChild,
  });

  /// Content shown when the couple has premium.
  final Widget child;

  /// Content shown when the couple does not have premium (e.g. blurred + lock overlay).
  final Widget lockedChild;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coupleAsync = ref.watch(coupleProvider);
    return coupleAsync.when(
      data: (couple) {
        if (couple?.isPremium == true) {
          return child;
        }
        return lockedChild;
      },
      loading: () => lockedChild,
      error: (_, Object? st) => lockedChild,
    );
  }
}

/// A default locked child: blurred content with a lock icon and CTA to open the paywall.
class PremiumGateLockedOverlay extends ConsumerWidget {
  const PremiumGateLockedOverlay({
    super.key,
    required this.child,
    this.message = 'Unlock with DYOS+',
  });

  /// The premium content to blur (same layout as when unlocked).
  final Widget child;

  /// Short message shown above the unlock button.
  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: child,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF3A3A3C)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                PhosphorIconsBold.lock,
                color: Colors.white,
                size: 40,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => PaywallModal.show(context, ref),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF5E5CE6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Upgrade to DYOS+',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

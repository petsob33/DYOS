import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/l10n/build_context_l10n_extension.dart';
import '../../../../core/widgets/bento_card.dart';
import '../../../auth/presentation/auth_providers.dart';
import '../../../../core/services/firebase_service.dart';
import 'package:flutter/services.dart';
import '../../../gamification/presentation/user_stats_provider.dart';
import '../../../gamification/domain/progression_plan.dart';
import '../../../premium/presentation/premium_provider.dart';

class TapticTouchCard extends ConsumerStatefulWidget {
  const TapticTouchCard();

  @override
  ConsumerState<TapticTouchCard> createState() => _TapticTouchCardState();
}

class _TapticTouchCardState extends ConsumerState<TapticTouchCard> {
  DateTime? _pressStartTime;
  bool _isPressed = false;
  bool _justSent = false;

  @override
  Widget build(BuildContext context) {
    final currentSp = ref.watch(currentXpProvider);
    final isPremium = ref.watch(isPremiumProvider).valueOrNull ?? false;
    final unlocked = ProgressionPlan.isRewardUnlocked(
      RewardKind.taptic,
      currentSp,
      isPremium,
    );

    final coupleId = ref.watch(
      currentCoupleProvider.select((async) => async.valueOrNull?.id),
    );
    final currentUserId = ref.watch(
      currentUserDataProvider.select((async) => async.valueOrNull?.uid),
    );

    if (coupleId == null) {
      return BentoCard(
        child: Center(
          child: Icon(
            PhosphorIconsBold.heart,
            color: context.colors.love.withValues(alpha: 0.3),
            size: 56,
          ),
        ),
      );
    }

    final resolvedUserId = currentUserId ?? '';

    return BentoCard(
      child: GestureDetector(
        onTapDown: (_) {
          if (!unlocked) {
            HapticFeedback.selectionClick();
            return;
          }
          setState(() {
            _isPressed = true;
            _pressStartTime = DateTime.now();
          });
          HapticFeedback.mediumImpact();
        },
        onTapUp: (_) {
          if (!unlocked) {
            context.push('/premium');
          } else {
            _handleRelease(coupleId, resolvedUserId);
          }
        },
        onTapCancel: () {
          if (!unlocked) return;
          _handleRelease(coupleId, resolvedUserId);
        },
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: _isPressed
                ? context.colors.love.withValues(alpha: 0.1)
                : _justSent
                ? context.colors.success.withValues(alpha: 0.1)
                : context.colors.background,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  PhosphorIconsBold.heart,
                  color: _isPressed
                      ? context.colors.love
                      : _justSent
                      ? context.colors.success
                      : context.colors.love.withValues(alpha: 0.6),
                  size: 56,
                ),
                if (!unlocked) ...[
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.tapticTouchCardUnlockPrompt,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
                if (_justSent) ...[
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.tapticTouchCardSentLabel,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: context.colors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleRelease(String coupleId, String userId) {
    if (_pressStartTime == null) return;

    final duration = DateTime.now().difference(_pressStartTime!);
    final durationMs = duration.inMilliseconds.clamp(
      100,
      2000,
    ); // Min 100ms, max 2s

    setState(() {
      _isPressed = false;
    });

    HapticFeedback.lightImpact();

    final firebaseService = ref.read(firebaseServiceProvider);
    firebaseService
        .sendHapticTouch(
          coupleId: coupleId,
          fromUserId: userId,
          durationMs: durationMs,
        )
        .then((_) {
          if (!mounted) return;
          setState(() => _justSent = true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.tapticTouchCardSentToPartnerMessage),
              backgroundColor: context.colors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) setState(() => _justSent = false);
          });
        })
        .catchError((error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.l10n.tapticTouchCardSendErrorMessage(error.toString())),
                backgroundColor: context.colors.love,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        });

    _pressStartTime = null;
  }
}

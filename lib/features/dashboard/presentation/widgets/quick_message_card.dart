import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/bento_card.dart';
import '../../../auth/presentation/auth_providers.dart';
import '../../../gamification/presentation/user_stats_provider.dart';
import '../../../gamification/domain/progression_plan.dart';
import '../../../gamification/presentation/widgets/level_up_unlock_sheet.dart';
import '../../../premium/presentation/premium_provider.dart';

class QuickMessageCard extends ConsumerWidget {
  const QuickMessageCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coupleAsync = ref.watch(currentCoupleProvider);

    return coupleAsync.when(
      data: (couple) {
        if (couple == null) {
          final c = AppTheme.colors;
          return BentoCard(
            background: c.card,
            child: Center(
              child: Icon(
                PhosphorIconsBold.chatCircle,
                color: c.primary,
                size: 52,
              ),
            ),
          );
        }

        final currentSp = ref.watch(currentXpProvider);
        final isPremium = ref.watch(isPremiumProvider).valueOrNull ?? false;
        final quickMessagesUnlocked = ProgressionPlan.isFeatureUnlocked(
          FeatureID.quickMessages,
          currentSp,
          isPremium,
        );

        final c = AppTheme.colors;

        return BentoCard(
          onTap: () {
            if (quickMessagesUnlocked) {
              context.push('/chat');
            } else {
              showLevelUpUnlockSheet(context, ref, FeatureID.quickMessages);
            }
          },
          background: c.card,
          child: Center(
            child: Icon(
              PhosphorIconsBold.chatCircle,
              color: c.primary,
              size: 44,
            ),
          ),
        );
      },
      loading: () {
        final c = AppTheme.colors;
        return BentoCard(
          background: c.card,
          child: Center(
            child: Icon(
              PhosphorIconsBold.chatCircle,
              color: c.primary,
              size: 52,
            ),
          ),
        );
      },
      error: (_, __) {
        final c = AppTheme.colors;
        return BentoCard(
          background: c.card,
          child: Center(
            child: Icon(
              PhosphorIconsBold.chatCircle,
              color: c.primary,
              size: 52,
            ),
          ),
        );
      },
    );
  }
}

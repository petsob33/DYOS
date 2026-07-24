import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/bento_card.dart';
import '../../../gamification/presentation/user_stats_provider.dart';
import '../../../gamification/domain/progression_plan.dart';
import '../../../gamification/presentation/widgets/level_up_unlock_sheet.dart';
import '../../../premium/presentation/premium_provider.dart';

class BlueprintsCard extends ConsumerWidget {
  const BlueprintsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSp = ref.watch(currentXpProvider);
    final isPremium = ref.watch(isPremiumProvider).valueOrNull ?? false;
    final unlocked = ProgressionPlan.isFeatureUnlocked(
      FeatureID.blueprints,
      currentSp,
      isPremium,
    );

    final c = context.colors;

    return BentoCard(
      onTap: () => unlocked
          ? context.push('/blueprints')
          : showLevelUpUnlockSheet(context, ref, FeatureID.blueprints),
      background: c.card,
      child: Center(
        child: Icon(
          PhosphorIconsBold.clipboardText,
          color: c.primary,
          size: 52,
        ),
      ),
    );
  }
}

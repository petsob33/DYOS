import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/theme/app_theme.dart';
import 'package:flutter/services.dart';
import '../../../gamification/domain/level_manager.dart';
import '../../../gamification/presentation/user_stats_provider.dart';

/// Level strip in app bar (roztáhnutý): version, progress bar, XP. Tap opens Level page.
class AppBarLevelStrip extends ConsumerWidget {
  const AppBarLevelStrip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentXp = ref.watch(currentXpProvider);
    final version = LevelManager.currentVersionString(currentXp);
    final progress = LevelManager.calculateProgress(currentXp);
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(left: 0, right: 8, top: 8, bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/level'),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: c.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Text(
                  version,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: c.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      minHeight: 6,
                      backgroundColor: c.textSecondary.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(c.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$currentXp SP',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: c.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  PhosphorIconsBold.caretRight,
                  size: 16,
                  color: c.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

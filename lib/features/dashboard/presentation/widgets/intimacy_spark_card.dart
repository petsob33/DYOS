import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/bento_card.dart';
import '../../../tracker/presentation/intimacy_provider.dart';
import '../../../tracker/domain/intimacy_log_model.dart';
import 'package:flutter/services.dart';

class IntimacySparkCard extends ConsumerWidget {
  const IntimacySparkCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(intimacyLogsStreamProvider);

    return logsAsync.when(
      data: (logs) {
        if (logs.isEmpty) {
          return BentoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  PhosphorIconsBold.heart,
                  color: AppTheme.colors.love,
                  size: 24,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'No activity yet',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.colors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        }

        // Get the most recent log
        final sortedLogs = List<IntimacyLog>.from(logs)
          ..sort((a, b) => b.date.compareTo(a.date));
        final lastLog = sortedLogs.first;
        final daysSince = DateTime.now().difference(lastLog.date).inDays;

        String sparkText;
        String sparkEmoji;
        if (daysSince == 0) {
          sparkText = 'Today';
          sparkEmoji = '🔥';
        } else if (daysSince == 1) {
          sparkText = '1 day ago';
          sparkEmoji = '🔥';
        } else if (daysSince < 7) {
          sparkText = '$daysSince days ago';
          sparkEmoji = '🔥';
        } else if (daysSince < 14) {
          sparkText = '$daysSince days ago';
          sparkEmoji = '💫';
        } else {
          sparkText = '$daysSince days ago';
          sparkEmoji = '💭';
        }

        return BentoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    PhosphorIconsBold.heart,
                    color: AppTheme.colors.love,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.colors.textSecondary,
                        ),
                        children: [
                          const TextSpan(text: ''),
                          TextSpan(
                            text: sparkText,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppTheme.colors.text,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          TextSpan(
                            text: ' $sparkEmoji',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppTheme.colors.text,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => BentoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              PhosphorIconsBold.heart,
              color: AppTheme.colors.love,
              size: 24,
            ),
            const SizedBox(height: AppSpacing.sm),
            const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
      error: (_, __) => BentoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              PhosphorIconsBold.heart,
              color: AppTheme.colors.love,
              size: 24,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Error loading data',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/l10n/build_context_l10n_extension.dart';
import '../../../../core/widgets/bento_card.dart';
import '../../../events/presentation/event_provider.dart';
import 'package:flutter/services.dart';

class CountdownCard extends ConsumerWidget {
  const CountdownCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nextEventAsync = ref.watch(nextEventProvider);

    return nextEventAsync.when(
      data: (event) {
        if (event == null) {
          return BentoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.countdownCardTitle,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  context.l10n.countdownCardNoEvents,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.colors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        }

        final now = DateTime.now();
        final eventDate = DateTime(
          event.date.year,
          event.date.month,
          event.date.day,
        );
        final today = DateTime(now.year, now.month, now.day);
        final daysUntil = eventDate.difference(today).inDays;

        return BentoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.countdownCardTitle,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '$daysUntil',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: context.colors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                context.l10n.countdownCardDaysUntil(daysUntil, event.title),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.colors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
      loading: () => BentoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.countdownCardTitle,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
      error: (_, __) => BentoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.countdownCardTitle,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              context.l10n.countdownCardError,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

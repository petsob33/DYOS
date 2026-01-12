import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/bento_card.dart';
import '../../../auth/presentation/auth_providers.dart';
import '../../domain/intimacy_log_model.dart';
import '../intimacy_provider.dart';

/// Widget that displays a list of intimacy logs grouped by month
/// 
/// Features:
/// - Groups logs by month (e.g., "January 2026")
/// - Shows date, tags, rating, and initiator for each log
/// - Handles loading, error, and empty states
class IntimacyHistoryList extends ConsumerWidget {
  const IntimacyHistoryList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(intimacyLogsStreamProvider);
    final currentUserAsync = ref.watch(userProvider);

    return logsAsync.when(
      data: (logs) {
        if (logs.isEmpty) {
          return const _EmptyState();
        }

        // Group logs by month
        final groupedLogs = <String, List<IntimacyLog>>{};
        for (final log in logs) {
          final monthKey = _formatMonthYear(log.date);
          groupedLogs.putIfAbsent(monthKey, () => []).add(log);
        }

        // Sort months descending (newest first)
        final sortedMonths = groupedLogs.keys.toList()
          ..sort((a, b) {
            // Parse month strings to compare dates
            final aDate = _parseMonthYear(a);
            final bDate = _parseMonthYear(b);
            return bDate.compareTo(aDate);
          });

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          itemCount: sortedMonths.length,
          itemBuilder: (context, index) {
            final monthKey = sortedMonths[index];
            final monthLogs = groupedLogs[monthKey]!;

            return _IntimacyMonthSection(
              month: monthKey,
              logs: monthLogs,
              currentUserId: currentUserAsync.valueOrNull?.uid ?? '',
            );
          },
        );
      },
      loading: () => const _LoadingState(),
      error: (error, stack) => _ErrorState(error: error.toString()),
    );
  }

  String _formatMonthYear(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  DateTime _parseMonthYear(String monthYear) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    final parts = monthYear.split(' ');
    if (parts.length == 2) {
      final monthIndex = months.indexOf(parts[0]);
      final year = int.tryParse(parts[1]);
      if (monthIndex != -1 && year != null) {
        return DateTime(year, monthIndex + 1);
      }
    }
    return DateTime.now();
  }
}

/// Month section header with list of logs
class _IntimacyMonthSection extends StatelessWidget {
  const _IntimacyMonthSection({
    required this.month,
    required this.logs,
    required this.currentUserId,
  });

  final String month;
  final List<IntimacyLog> logs;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: AppSpacing.lg,
            bottom: AppSpacing.md,
          ),
          child: Text(
            month,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.colors.text,
                ),
          ),
        ),
        ...logs.map((log) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _IntimacyLogCard(
                log: log,
                isCurrentUser: log.initiatorId == currentUserId,
              ),
            )),
      ],
    );
  }
}

/// Card displaying a single intimacy log
class _IntimacyLogCard extends StatelessWidget {
  const _IntimacyLogCard({
    required this.log,
    required this.isCurrentUser,
  });

  final IntimacyLog log;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          // Left: Date
          _DateSection(date: log.date),
          const SizedBox(width: AppSpacing.md),
          // Center: Tags and Rating
          Expanded(
            child: _TagsAndRatingSection(
              tags: log.tags,
              rating: log.rating,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Right: Initiator indicator
          _InitiatorIndicator(isCurrentUser: isCurrentUser),
        ],
      ),
    );
  }
}

/// Date section showing day number (big) and month (small)
class _DateSection extends StatelessWidget {
  const _DateSection({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          date.day.toString(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppTheme.colors.text,
                height: 1.0,
              ),
        ),
        Text(
          months[date.month - 1],
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppTheme.colors.textSecondary,
                height: 1.0,
              ),
        ),
      ],
    );
  }
}

/// Tags and rating section
class _TagsAndRatingSection extends StatelessWidget {
  const _TagsAndRatingSection({
    required this.tags,
    required this.rating,
  });

  final List<String> tags;
  final int rating;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Tags as small chips
        if (tags.isNotEmpty)
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: tags.take(3).map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs + 2,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tag,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.colors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                ),
              );
            }).toList(),
          )
        else
          const SizedBox.shrink(),
        const SizedBox(height: AppSpacing.xs),
        // Rating as fire icons
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            final value = index + 1;
            final isFilled = value <= rating;
            return Padding(
              padding: const EdgeInsets.only(right: 2),
              child: Icon(
                PhosphorIconsBold.fire,
                size: 14,
                color: isFilled
                    ? AppTheme.colors.love
                    : AppTheme.colors.textSecondary.withValues(alpha: 0.3),
              ),
            );
          }),
        ),
      ],
    );
  }
}

/// Initiator indicator (mini avatar or icon)
class _InitiatorIndicator extends StatelessWidget {
  const _InitiatorIndicator({required this.isCurrentUser});

  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCurrentUser
            ? AppTheme.colors.primary.withValues(alpha: 0.12)
            : AppTheme.colors.textSecondary.withValues(alpha: 0.1),
      ),
      child: Icon(
        PhosphorIconsBold.user,
        size: 18,
        color: isCurrentUser
            ? AppTheme.colors.primary
            : AppTheme.colors.textSecondary,
      ),
    );
  }
}

/// Loading state with skeleton loaders
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: _LogCardSkeleton(),
        );
      },
    );
  }
}

/// Skeleton loader for log card
class _LogCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BentoCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          // Date skeleton
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.colors.textSecondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Container(
                width: 24,
                height: 12,
                decoration: BoxDecoration(
                  color: AppTheme.colors.textSecondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          // Content skeleton
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppTheme.colors.textSecondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Container(
                  width: 80,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppTheme.colors.textSecondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Avatar skeleton
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.colors.textSecondary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

/// Error state
class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIconsBold.warning,
              size: 64,
              color: AppTheme.colors.love,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Error loading logs',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.colors.text,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.colors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state when no logs exist
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIconsBold.heart,
              size: 64,
              color: AppTheme.colors.textSecondary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No memories yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.colors.text,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Time to change that? 😉',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.colors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

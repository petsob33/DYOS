import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/bento_card.dart';
import '../../../auth/presentation/auth_providers.dart';
import '../../domain/intimacy_log_model.dart';
import '../intimacy_provider.dart';
import 'intimacy_log_detail_sheet.dart';

/// Widget that displays a list of intimacy logs grouped by month
/// 
/// Features:
/// - Groups logs by month (e.g., "January 2026")
/// - Shows date, tags, rating, and initiator for each log
/// - Handles loading, error, and empty states
/// - Can limit the number of logs displayed
class IntimacyHistoryList extends ConsumerWidget {
  const IntimacyHistoryList({
    super.key,
    this.limit,
    this.showViewAllButton = false,
  });

  /// Maximum number of logs to display. If null, shows all logs.
  final int? limit;
  
  /// Whether to show "View All" button if there are more logs than limit
  final bool showViewAllButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(intimacyLogsStreamProvider);
    final currentUserAsync = ref.watch(userProvider);
    final currentUserDataAsync = ref.watch(currentUserDataProvider);
    final partnerAsync = ref.watch(partnerProvider);

    return logsAsync.when(
      data: (logs) {
        if (logs.isEmpty) {
          return const _EmptyState();
        }

        // Limit logs if specified
        final limitedLogs = limit != null && logs.length > limit!
            ? logs.take(limit!).toList()
            : logs;
        final hasMoreLogs = limit != null && logs.length > limit!;

        // Group logs by month
        final groupedLogs = <String, List<IntimacyLog>>{};
        for (final log in limitedLogs) {
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

        // Helper widget to build the list with optional "View All" button
        Widget buildListView({
          required String? currentUserPhotoUrl,
          required String? partnerPhotoUrl,
        }) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...sortedMonths.map((monthKey) {
                final monthLogs = groupedLogs[monthKey]!;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: _IntimacyMonthSection(
                    month: monthKey,
                    logs: monthLogs,
                    currentUserId: currentUserAsync.valueOrNull?.uid ?? '',
                    currentUserPhotoUrl: currentUserPhotoUrl,
                    partnerPhotoUrl: partnerPhotoUrl,
                  ),
                );
              }),
              if (hasMoreLogs && showViewAllButton)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.push('/intimacy-history');
                      },
                      icon: const Icon(PhosphorIconsBold.arrowRight),
                      label: const Text('View All'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.colors.primary,
                        side: BorderSide(
                          color: AppTheme.colors.primary,
                          width: 2,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        }

        return currentUserDataAsync.when(
          data: (currentUserData) => partnerAsync.when(
            data: (partnerData) => buildListView(
              currentUserPhotoUrl: currentUserData?.photoUrl,
              partnerPhotoUrl: partnerData?.photoUrl,
            ),
            loading: () => const _LoadingState(),
            error: (_, _) => buildListView(
              currentUserPhotoUrl: currentUserData?.photoUrl,
              partnerPhotoUrl: null,
            ),
          ),
          loading: () => const _LoadingState(),
          error: (_, __) => buildListView(
            currentUserPhotoUrl: null,
            partnerPhotoUrl: null,
          ),
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
    this.currentUserPhotoUrl,
    this.partnerPhotoUrl,
  });

  final String month;
  final List<IntimacyLog> logs;
  final String currentUserId;
  final String? currentUserPhotoUrl;
  final String? partnerPhotoUrl;

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
        ...logs.map((log) {
          final isCurrentUser = log.initiatorId == currentUserId;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _IntimacyLogCard(
              log: log,
              isCurrentUser: isCurrentUser,
              photoUrl: isCurrentUser ? currentUserPhotoUrl : partnerPhotoUrl,
              currentUserPhotoUrl: currentUserPhotoUrl,
              partnerPhotoUrl: partnerPhotoUrl,
            ),
          );
        }),
      ],
    );
  }
}

/// Card displaying a single intimacy log
class _IntimacyLogCard extends StatelessWidget {
  const _IntimacyLogCard({
    required this.log,
    required this.isCurrentUser,
    this.photoUrl,
    this.currentUserPhotoUrl,
    this.partnerPhotoUrl,
  });

  final IntimacyLog log;
  final bool isCurrentUser;
  final String? photoUrl;
  final String? currentUserPhotoUrl;
  final String? partnerPhotoUrl;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        IntimacyLogDetailSheet.show(
          context,
          log: log,
          currentUserPhotoUrl: currentUserPhotoUrl,
          partnerPhotoUrl: partnerPhotoUrl,
        );
      },
      child: BentoCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
              _InitiatorIndicator(
                isCurrentUser: isCurrentUser,
                photoUrl: photoUrl,
              ),
            ],
          ),
          // Orgasms, Duration and Location row
          if (log.orgasmsMe > 0 || log.orgasmsPartner > 0 || log.durationMinutes != null || (log.location != null && log.location!.isNotEmpty))
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.xs,
                children: [
                  if (log.orgasmsMe > 0 || log.orgasmsPartner > 0)
                    _OrgasmsDisplay(
                      orgasmsMe: log.orgasmsMe,
                      orgasmsPartner: log.orgasmsPartner,
                    ),
                  if (log.durationMinutes != null)
                    _DurationDisplay(durationMinutes: log.durationMinutes!),
                  if (log.location != null && log.location!.isNotEmpty)
                    _LocationDisplay(location: log.location!),
                ],
              ),
            ),
        ],
      ),
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
  const _InitiatorIndicator({
    required this.isCurrentUser,
    this.photoUrl,
  });

  final bool isCurrentUser;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: isCurrentUser
          ? AppTheme.colors.primary.withValues(alpha: 0.12)
          : AppTheme.colors.textSecondary.withValues(alpha: 0.1),
      backgroundImage: photoUrl != null && photoUrl!.isNotEmpty
          ? CachedNetworkImageProvider(photoUrl!)
          : null,
      child: photoUrl == null || photoUrl!.isEmpty
          ? Icon(
              PhosphorIconsBold.user,
              size: 18,
              color: isCurrentUser
                  ? AppTheme.colors.primary
                  : AppTheme.colors.textSecondary,
            )
          : null,
    );
  }
}

/// Orgasms display widget
class _OrgasmsDisplay extends StatelessWidget {
  const _OrgasmsDisplay({
    required this.orgasmsMe,
    required this.orgasmsPartner,
  });

  final int orgasmsMe;
  final int orgasmsPartner;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          PhosphorIconsBold.sparkle,
          size: 14,
          color: AppTheme.colors.love,
        ),
        const SizedBox(width: 4),
        Text(
          '$orgasmsMe / $orgasmsPartner',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

/// Duration display widget
class _DurationDisplay extends StatelessWidget {
  const _DurationDisplay({required this.durationMinutes});

  final int durationMinutes;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          PhosphorIconsBold.clock,
          size: 14,
          color: AppTheme.colors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          '$durationMinutes min',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

/// Location display widget
class _LocationDisplay extends StatelessWidget {
  const _LocationDisplay({required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          PhosphorIconsBold.mapPin,
          size: 14,
          color: AppTheme.colors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          location,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
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

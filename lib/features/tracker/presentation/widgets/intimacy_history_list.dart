import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/l10n/build_context_l10n_extension.dart';
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
    // limit == null means "show everything" (the full history screen) -
    // that's the case that benefits from real pagination against a bounded
    // Firestore read window. A small preview (limit != null, e.g. the
    // dashboard's last-5 widget) keeps using the existing unbounded stream,
    // since it's already a tiny slice and doesn't need its own paginated
    // data source.
    final isFullHistory = limit == null;
    final feedState = isFullHistory ? ref.watch(intimacyFeedControllerProvider) : null;
    final logsAsync = isFullHistory ? null : ref.watch(intimacyLogsStreamProvider);
    final currentUserAsync = ref.watch(userProvider);
    final currentUserDataAsync = ref.watch(currentUserDataProvider);
    final partnerAsync = ref.watch(partnerProvider);

    Widget buildBody(List<IntimacyLog> logs) {
      if (logs.isEmpty) {
        return const _EmptyState();
      }

      // Limit logs if specified
      final limitedLogs = limit != null && logs.length > limit!
          ? logs.take(limit!).toList()
          : logs;
      final hasMoreLogs = limit != null && logs.length > limit!;

      // Group logs by month (keyed by the month's first day so sorting stays
      // locale-independent; the display label is formatted separately below)
      final groupedLogs = <DateTime, List<IntimacyLog>>{};
      for (final log in limitedLogs) {
        final monthKey = DateTime(log.date.year, log.date.month);
        groupedLogs.putIfAbsent(monthKey, () => []).add(log);
      }

      // Sort months descending (newest first)
      final sortedMonths = groupedLogs.keys.toList()
        ..sort((a, b) => b.compareTo(a));

      // Helper widget to build the list with optional "View All"/"Load more" button
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
              final monthLabel = DateFormat.yMMMM(
                Localizations.localeOf(context).toString(),
              ).format(monthKey);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: _IntimacyMonthSection(
                  month: monthLabel,
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
                    label: Text(context.l10n.intimacyHistoryListViewAllButton),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.colors.primary,
                      side: BorderSide(
                        color: context.colors.primary,
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
            if (isFullHistory && (feedState?.hasMore ?? false))
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Center(
                  child: feedState!.isLoadingMore
                      ? const CircularProgressIndicator()
                      : OutlinedButton(
                          onPressed: () =>
                              ref.read(intimacyFeedControllerProvider.notifier).loadMore(),
                          child: Text(context.l10n.intimacyHistoryListLoadOlderButton),
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
    }

    if (isFullHistory) {
      return buildBody(feedState!.logs);
    }

    return logsAsync!.when(
      data: buildBody,
      loading: () => const _LoadingState(),
      error: (error, stack) => _ErrorState(error: error.toString()),
    );
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
                  color: context.colors.text,
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
          if (log.userOrgasmCount > 0 || log.partnerOrgasmCount > 0 || log.duration != null || (log.location != null && log.location!.isNotEmpty))
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.xs,
                children: [
                  if (log.userOrgasmCount > 0 || log.partnerOrgasmCount > 0)
                    _OrgasmsDisplay(
                      orgasmsMe: log.userOrgasmCount,
                      orgasmsPartner: log.partnerOrgasmCount,
                    ),
                  if (log.duration != null)
                    _DurationDisplay(durationMinutes: log.duration!),
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
    final monthLabel = DateFormat.MMM(
      Localizations.localeOf(context).toString(),
    ).format(date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          date.day.toString(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: context.colors.text,
                height: 1.0,
              ),
        ),
        Text(
          monthLabel,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: context.colors.textSecondary,
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
                  color: context.colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tag,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: context.colors.primary,
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
                    ? context.colors.love
                    : context.colors.textSecondary.withValues(alpha: 0.3),
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
          ? context.colors.primary.withValues(alpha: 0.12)
          : context.colors.textSecondary.withValues(alpha: 0.1),
      backgroundImage: photoUrl != null && photoUrl!.isNotEmpty
          ? CachedNetworkImageProvider(photoUrl!)
          : null,
      child: photoUrl == null || photoUrl!.isEmpty
          ? Icon(
              PhosphorIconsBold.user,
              size: 18,
              color: isCurrentUser
                  ? context.colors.primary
                  : context.colors.textSecondary,
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
          color: context.colors.love,
        ),
        const SizedBox(width: 4),
        Text(
          '$orgasmsMe / $orgasmsPartner',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.colors.textSecondary,
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
          color: context.colors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          context.l10n.intimacyHistoryListDurationMinutes(durationMinutes),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.colors.textSecondary,
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
          color: context.colors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          location,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.colors.textSecondary,
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
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: List.generate(
          5,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _LogCardSkeleton(),
          ),
        ),
      ),
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
                  color: context.colors.textSecondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Container(
                width: 24,
                height: 12,
                decoration: BoxDecoration(
                  color: context.colors.textSecondary.withValues(alpha: 0.1),
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
                    color: context.colors.textSecondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Container(
                  width: 80,
                  height: 14,
                  decoration: BoxDecoration(
                    color: context.colors.textSecondary.withValues(alpha: 0.1),
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
              color: context.colors.textSecondary.withValues(alpha: 0.1),
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
              color: context.colors.love,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              context.l10n.intimacyHistoryListErrorTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.colors.text,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.colors.textSecondary,
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
              color: context.colors.textSecondary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              context.l10n.intimacyHistoryListEmptyTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.colors.text,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              context.l10n.intimacyHistoryListEmptySubtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.colors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

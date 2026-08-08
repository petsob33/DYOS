import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/l10n/build_context_l10n_extension.dart';
import '../../../core/widgets/bento_card.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../dashboard/domain/haptic_signal_stats.dart';
import '../../dashboard/presentation/hearts_streak_provider.dart';
import 'intimacy_provider.dart';
import '../domain/intimacy_log_model.dart';
import '../domain/intimacy_stats.dart';
import 'widgets/data_screen_charts.dart';
import 'widgets/intimacy_history_list.dart';

class DataScreen extends ConsumerWidget {
  const DataScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(intimacyLogsStreamProvider);
    final currentUserId = ref.watch(
      userProvider.select((async) => async.valueOrNull?.uid),
    );

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(title: Text(context.l10n.dataScreenTitle)),
      body: SafeArea(
        child: logsAsync.when(
          data: (logs) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.dataScreenHeading,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: context.colors.text,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          context.l10n.dataScreenSubheading,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Stats Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: _StatsRow(logs: logs),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Best Of (swipeable highlights)
                  _BestOfCarousel(logs: logs),
                  const SizedBox(height: AppSpacing.lg),
                  // Current Month Stats
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: _CurrentMonthStats(logs: logs),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Frequency Chart
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: FrequencyChart(logs: logs),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Initiator Chart
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: InitiatorChart(
                      logs: logs,
                      currentUserId: currentUserId ?? '',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Orgasm Comparison Chart
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: OrgasmComparisonChart(logs: logs),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Tags Radar Chart
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: TagsRadarChart(logs: logs),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: AppSpacing.xl,
                      left: AppSpacing.lg,
                      right: AppSpacing.lg,
                      bottom: AppSpacing.md,
                    ),
                    child: Text(
                      context.l10n.dataScreenHistoryHeading,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: context.colors.text,
                          ),
                    ),
                  ),
                  // History list (not scrollable, just shows items)
                  const IntimacyHistoryList(
                    limit: 5,
                    showViewAllButton: true,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text(context.l10n.dataScreenError(error.toString())),
          ),
        ),
      ),
    );
  }
}

/// Stats Row with 3 cards: Total Count, Avg/Week, Favorite Day
class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.logs});

  final List<IntimacyLog> logs;

  @override
  Widget build(BuildContext context) {
    // Calculate stats
    final totalCount = logs.length;
    
    // Calculate average per week
    double avgPerWeek = 0;
    if (logs.isNotEmpty) {
      final oldestDate = logs.map((log) => log.date).reduce((a, b) => a.isBefore(b) ? a : b);
      final newestDate = logs.map((log) => log.date).reduce((a, b) => a.isAfter(b) ? a : b);
      final daysDiff = newestDate.difference(oldestDate).inDays;
      final weeks = daysDiff > 0 ? daysDiff / 7.0 : 1.0;
      avgPerWeek = totalCount / weeks;
    }

    // Calculate favorite day
    final dayCounts = <int, int>{};
    for (final log in logs) {
      final weekday = log.date.weekday;
      dayCounts[weekday] = (dayCounts[weekday] ?? 0) + 1;
    }
    final favoriteDayIndex = dayCounts.entries.isEmpty
        ? 1
        : dayCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    // DateTime(2024, 1, N) for N=1..7 lands on Mon..Sun respectively, so this
    // is a locale-agnostic way to format an arbitrary weekday index.
    final favoriteDay = DateFormat.E(Localizations.localeOf(context).toString())
        .format(DateTime(2024, 1, favoriteDayIndex));

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: PhosphorIconsBold.heart,
            title: context.l10n.dataScreenTotalCountTitle,
            value: totalCount.toString(),
            subtitle: context.l10n.dataScreenAllTime,
            color: context.colors.love,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _StatCard(
            icon: PhosphorIconsBold.calendar,
            title: context.l10n.dataScreenAvgPerWeekTitle,
            value: avgPerWeek.toStringAsFixed(1),
            subtitle: context.l10n.dataScreenAverage,
            color: context.colors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _StatCard(
            icon: PhosphorIconsBold.star,
            title: context.l10n.dataScreenFavoriteDayTitle,
            value: favoriteDay,
            subtitle: context.l10n.dataScreenMostActive,
            color: context.colors.warning,
          ),
        ),
      ],
    );
  }
}

/// Best Of: swipeable highlight cards (all-time/monthly records, streaks)
class _BestOfCarousel extends ConsumerWidget {
  const _BestOfCarousel({required this.logs});

  final List<IntimacyLog> logs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final couple = ref.watch(currentCoupleProvider).valueOrNull;
    final signals = ref.watch(hapticSignalsHistoryProvider).valueOrNull ?? [];
    final now = DateTime.now();

    final allTimeLongest = longestDuration(logs);
    final monthLongest = currentMonthStats(logs, now).longestDurationMinutes;
    final streak = couple == null
        ? 0
        : heartsStreak(signals, memberIds: couple.members, now: now);

    final cards = [
      _StatCard(
        icon: PhosphorIconsBold.trophy,
        title: context.l10n.dataScreenLongestSexTitle,
        value: allTimeLongest == null ? '–' : '${allTimeLongest}m',
        subtitle: context.l10n.dataScreenAllTime,
        color: context.colors.primary,
      ),
      _StatCard(
        icon: PhosphorIconsBold.clock,
        title: context.l10n.dataScreenLongestSexTitle,
        value: monthLongest == null ? '–' : '${monthLongest}m',
        subtitle: context.l10n.dataScreenThisMonthSubtitle,
        color: context.colors.warning,
      ),
      _StatCard(
        icon: PhosphorIconsBold.fire,
        title: context.l10n.dataScreenHeartsStreakTitle,
        value: streak.toString(),
        subtitle: context.l10n.dataScreenStreakDaySubtitle(streak),
        color: context.colors.love,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              Icon(
                PhosphorIconsBold.sparkle,
                color: context.colors.primary,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  context.l10n.dataScreenBestOfHeading,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.colors.text,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: MediaQuery.textScalerOf(context).scale(152).clamp(152.0, 260.0),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: cards.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) => SizedBox(width: 160, child: cards[index]),
          ),
        ),
      ],
    );
  }
}

/// Current Month Stats: 4 cards summarizing this calendar month
class _CurrentMonthStats extends StatelessWidget {
  const _CurrentMonthStats({required this.logs});

  final List<IntimacyLog> logs;

  @override
  Widget build(BuildContext context) {
    final stats = currentMonthStats(logs, DateTime.now());

    return BentoCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIconsBold.calendarCheck,
                color: context.colors.primary,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  context.l10n.dataScreenCurrentMonthHeading,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.colors.text,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: MediaQuery.textScalerOf(context).scale(152).clamp(152.0, 260.0),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
              itemBuilder: (context, index) {
                final cards = [
                  _StatCard(
                    icon: PhosphorIconsBold.heart,
                    title: context.l10n.dataScreenTotalTitle,
                    value: stats.count.toString(),
                    subtitle: context.l10n.dataScreenThisMonthSubtitle,
                    color: context.colors.love,
                  ),
                  _StatCard(
                    icon: PhosphorIconsBold.timer,
                    title: context.l10n.dataScreenAvgDurationTitle,
                    value: stats.avgDurationMinutes == null
                        ? '–'
                        : '${stats.avgDurationMinutes!.toStringAsFixed(1)}m',
                    subtitle: context.l10n.dataScreenThisMonthSubtitle,
                    color: context.colors.warning,
                  ),
                  _StatCard(
                    icon: PhosphorIconsBold.fire,
                    title: context.l10n.dataScreenAvgOrgasmsTitle,
                    value: stats.avgOrgasms.toStringAsFixed(1),
                    subtitle: context.l10n.dataScreenThisMonthSubtitle,
                    color: context.colors.love,
                  ),
                ];
                return SizedBox(width: 160, child: cards[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Stat Card widget
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: context.colors.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: context.colors.text,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: context.colors.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
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
import 'widgets/intimacy_history_list.dart';

class DataScreen extends ConsumerWidget {
  const DataScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(intimacyLogsStreamProvider);
    final currentUserAsync = ref.watch(userProvider);

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
                    child: _FrequencyChart(logs: logs),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Initiator Chart
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: _InitiatorChart(
                      logs: logs,
                      currentUserId: currentUserAsync.valueOrNull?.uid ?? '',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Orgasm Comparison Chart
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: _OrgasmComparisonChart(logs: logs),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Tags Radar Chart
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: _TagsRadarChart(logs: logs),
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

/// Frequency Chart: BarChart showing intimacy count per month for last 6 months
class _FrequencyChart extends StatelessWidget {
  const _FrequencyChart({required this.logs});

  final List<IntimacyLog> logs;

  @override
  Widget build(BuildContext context) {
    // Get last 6 months
    final now = DateTime.now();
    final months = <DateTime>[];
    for (int i = 5; i >= 0; i--) {
      months.add(DateTime(now.year, now.month - i, 1));
    }

    // Count logs per month
    final monthCounts = <int, int>{};
    for (final log in logs) {
      final monthKey = log.date.year * 12 + log.date.month;
      monthCounts[monthKey] = (monthCounts[monthKey] ?? 0) + 1;
    }

    // Prepare data for chart
    final barGroups = months.asMap().entries.map((entry) {
      final index = entry.key;
      final month = entry.value;
      final monthKey = month.year * 12 + month.month;
      final count = monthCounts[monthKey] ?? 0;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: count.toDouble(),
            gradient: const LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Color(0xFF5E5CE6), // Purple
                Color(0xFFFF375F), // Red
              ],
            ),
            width: 20,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(4),
            ),
          ),
        ],
      );
    }).toList();

    final localeName = Localizations.localeOf(context).toString();
    final monthLabels = months.map((m) => DateFormat.MMM(localeName).format(m)).toList();

    return BentoCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIconsBold.chartBar,
                color: context.colors.primary,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  context.l10n.dataScreenFrequencyChartHeading,
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
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: monthCounts.values.isEmpty ? 10.0 : (monthCounts.values.reduce(math.max).toDouble() * 1.2),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => context.colors.card,
                    tooltipBorderRadius: BorderRadius.circular(8),
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < monthLabels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              monthLabels[value.toInt()],
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: context.colors.textSecondary,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        if (value % 1 == 0) {
                          return Text(
                            value.toInt().toString(),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: context.colors.textSecondary,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: context.colors.textSecondary.withValues(alpha: 0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: barGroups,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Initiator Chart: PieChart/DonutChart showing ratio between two user IDs
class _InitiatorChart extends StatelessWidget {
  const _InitiatorChart({
    required this.logs,
    required this.currentUserId,
  });

  final List<IntimacyLog> logs;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    // Count initiations by user
    int currentUserCount = 0;
    int partnerCount = 0;

    for (final log in logs) {
      if (log.initiatorId == currentUserId) {
        currentUserCount++;
      } else {
        partnerCount++;
      }
    }

    final total = currentUserCount + partnerCount;
    final currentUserPercent = total > 0 ? (currentUserCount / total * 100).round() : 0;
    final partnerPercent = total > 0 ? (partnerCount / total * 100).round() : 0;

    return BentoCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIconsBold.chartPieSlice,
                color: context.colors.primary,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  context.l10n.dataScreenInitiatorChartHeading,
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
            height: 200,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 60,
                      sections: [
                        PieChartSectionData(
                          value: currentUserCount.toDouble(),
                          title: '$currentUserPercent%',
                          color: context.colors.primary,
                          radius: 60,
                          titleStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        PieChartSectionData(
                          value: partnerCount.toDouble(),
                          title: '$partnerPercent%',
                          color: context.colors.love,
                          radius: 60,
                          titleStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LegendItem(
                      color: context.colors.primary,
                      label: context.l10n.dataScreenYouLabel,
                      count: currentUserCount,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _LegendItem(
                      color: context.colors.love,
                      label: context.l10n.dataScreenPartnerLabel,
                      count: partnerCount,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Orgasm Comparison Chart: PieChart/DonutChart showing orgasm totals for both partners
class _OrgasmComparisonChart extends StatelessWidget {
  const _OrgasmComparisonChart({required this.logs});

  final List<IntimacyLog> logs;

  @override
  Widget build(BuildContext context) {
    final totals = totalOrgasms(logs);
    final total = totals.user + totals.partner;

    if (total == 0) {
      return BentoCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  PhosphorIconsBold.chartPieSlice,
                  color: context.colors.primary,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    context.l10n.dataScreenOrgasmComparisonHeading,
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
            Center(
              child: Text(
                context.l10n.dataScreenNoDataYet,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final userPercent = (totals.user / total * 100).round();
    final partnerPercent = (totals.partner / total * 100).round();

    return BentoCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIconsBold.chartPieSlice,
                color: context.colors.primary,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  context.l10n.dataScreenOrgasmComparisonHeading,
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
            height: 200,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 60,
                      sections: [
                        PieChartSectionData(
                          value: totals.user.toDouble(),
                          title: '$userPercent%',
                          color: context.colors.primary,
                          radius: 60,
                          titleStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        PieChartSectionData(
                          value: totals.partner.toDouble(),
                          title: '$partnerPercent%',
                          color: context.colors.love,
                          radius: 60,
                          titleStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LegendItem(
                      color: context.colors.primary,
                      label: context.l10n.dataScreenYouLabel,
                      count: totals.user,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _LegendItem(
                      color: context.colors.love,
                      label: context.l10n.dataScreenPartnerLabel,
                      count: totals.partner,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Legend item for pie chart
class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    required this.count,
  });

  final Color color;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '$label ($count)',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: context.colors.text,
          ),
        ),
      ],
    );
  }
}

/// Tags Radar Chart: RadarChart showing distribution of tags
class _TagsRadarChart extends StatelessWidget {
  const _TagsRadarChart({required this.logs});

  final List<IntimacyLog> logs;

  @override
  Widget build(BuildContext context) {
    // Count tag occurrences
    final tagCounts = <String, int>{};
    for (final log in logs) {
      for (final tag in log.tags) {
        tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
      }
    }

    // Get top 6 tags
    final sortedTags = tagCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topTags = sortedTags.take(6).toList();

    if (topTags.isEmpty) {
      return BentoCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  PhosphorIconsBold.chartPolar,
                  color: context.colors.primary,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    context.l10n.dataScreenTagsRadarHeading,
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
            Center(
              child: Text(
                context.l10n.dataScreenNoTagsYet,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final maxCount = topTags.isEmpty ? 1 : topTags.map((e) => e.value).reduce(math.max);
    final radarData = topTags.map((tag) {
      return tag.value / maxCount * 100;
    }).toList();

    return BentoCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIconsBold.chartPolar,
                color: context.colors.primary,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  context.l10n.dataScreenTagsRadarHeading,
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
            height: 200,
            child: RadarChart(
              RadarChartData(
                dataSets: [
                  RadarDataSet(
                    fillColor: context.colors.primary.withValues(alpha: 0.2),
                    borderColor: context.colors.primary,
                    borderWidth: 2,
                    dataEntries: radarData.map((value) => RadarEntry(value: value)).toList(),
                  ),
                ],
                tickCount: 4,
                ticksTextStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: context.colors.textSecondary,
                ),
                radarBorderData: BorderSide(
                  color: context.colors.textSecondary.withValues(alpha: 0.2),
                  width: 1,
                ),
                getTitle: (index, angle) {
                  if (index < topTags.length) {
                    return RadarChartTitle(
                      text: topTags[index].key,
                      angle: angle,
                    );
                  }
                  return const RadarChartTitle(text: '');
                },
              ),
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

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/bento_card.dart';
import '../../auth/presentation/auth_providers.dart';
import 'intimacy_provider.dart';
import '../domain/intimacy_log_model.dart';
import 'widgets/intimacy_history_list.dart';

class DataScreen extends ConsumerWidget {
  const DataScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(intimacyLogsStreamProvider);
    final currentUserAsync = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      appBar: AppBar(title: const Text('Data & Analytics')),
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
                          'Relationship Insights',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.colors.text,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Track patterns and trends in your relationship',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.colors.textSecondary,
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
                      'History',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.colors.text,
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
            child: Text('Error: ${error.toString()}'),
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
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final favoriteDay = weekdays[favoriteDayIndex - 1];

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: PhosphorIconsBold.heart,
            title: 'Total Count',
            value: totalCount.toString(),
            subtitle: 'All time',
            color: AppTheme.colors.love,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _StatCard(
            icon: PhosphorIconsBold.calendar,
            title: 'Avg/Week',
            value: avgPerWeek.toStringAsFixed(1),
            subtitle: 'Average',
            color: AppTheme.colors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _StatCard(
            icon: PhosphorIconsBold.star,
            title: 'Favorite Day',
            value: favoriteDay,
            subtitle: 'Most active',
            color: AppTheme.colors.warning,
          ),
        ),
      ],
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
      final maxCount = monthCounts.values.isEmpty ? 1 : (monthCounts.values.reduce(math.max));
      final normalizedHeight = maxCount > 0 ? count / maxCount : 0.0;

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

    final monthLabels = months.map((m) {
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return months[m.month - 1];
    }).toList();

    return BentoCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIconsBold.chartBar,
                color: AppTheme.colors.primary,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Frequency Chart',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.colors.text,
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
                    getTooltipColor: (_) => AppTheme.colors.card,
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
                                color: AppTheme.colors.textSecondary,
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
                              color: AppTheme.colors.textSecondary,
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
                      color: AppTheme.colors.textSecondary.withValues(alpha: 0.1),
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
                color: AppTheme.colors.primary,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Initiator Chart',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.colors.text,
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
                          color: AppTheme.colors.primary,
                          radius: 60,
                          titleStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        PieChartSectionData(
                          value: partnerCount.toDouble(),
                          title: '$partnerPercent%',
                          color: AppTheme.colors.love,
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
                      color: AppTheme.colors.primary,
                      label: 'You',
                      count: currentUserCount,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _LegendItem(
                      color: AppTheme.colors.love,
                      label: 'Partner',
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
            color: AppTheme.colors.text,
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
                  color: AppTheme.colors.primary,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Tags Radar',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.colors.text,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: Text(
                'No tags yet',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.colors.textSecondary,
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
                color: AppTheme.colors.primary,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Tags Radar',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.colors.text,
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
                    fillColor: AppTheme.colors.primary.withValues(alpha: 0.2),
                    borderColor: AppTheme.colors.primary,
                    borderWidth: 2,
                    dataEntries: radarData.map((value) => RadarEntry(value: value)).toList(),
                  ),
                ],
                tickCount: 4,
                ticksTextStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.colors.textSecondary,
                ),
                radarBorderData: BorderSide(
                  color: AppTheme.colors.textSecondary.withValues(alpha: 0.2),
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
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme.colors.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppTheme.colors.text,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme.colors.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

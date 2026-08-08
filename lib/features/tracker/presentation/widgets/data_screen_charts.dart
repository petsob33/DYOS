import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/l10n/build_context_l10n_extension.dart';
import '../../../../core/widgets/bento_card.dart';
import '../../domain/intimacy_log_model.dart';
import '../../domain/intimacy_stats.dart';

/// Frequency Chart: BarChart showing intimacy count per month for last 6 months
class FrequencyChart extends StatelessWidget {
  const FrequencyChart({super.key, required this.logs});

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
class InitiatorChart extends StatelessWidget {
  const InitiatorChart({
    super.key,
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
class OrgasmComparisonChart extends StatelessWidget {
  const OrgasmComparisonChart({super.key, required this.logs});

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
class TagsRadarChart extends StatelessWidget {
  const TagsRadarChart({super.key, required this.logs});

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

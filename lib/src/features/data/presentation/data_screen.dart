import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/bento_card.dart';

class DataScreen extends StatelessWidget {
  const DataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      appBar: AppBar(title: const Text('Data & Analytics')),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              sliver: SliverToBoxAdapter(
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
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              sliver: SliverToBoxAdapter(
                child: _IntimacyChart(),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSpacing.lg,
                  mainAxisSpacing: AppSpacing.lg,
                  childAspectRatio: 1.2,
                ),
                delegate: SliverChildListDelegate([
                  _StatCard(
                    icon: PhosphorIconsBold.heart,
                    title: 'This Month',
                    value: '12',
                    subtitle: 'Intimate moments',
                    color: AppTheme.colors.love,
                  ),
                  _StatCard(
                    icon: PhosphorIconsBold.calendar,
                    title: 'Cycle Sync',
                    value: '85%',
                    subtitle: 'Aligned this week',
                    color: AppTheme.colors.primary,
                  ),
                  _StatCard(
                    icon: PhosphorIconsBold.smiley,
                    title: 'Avg Mood',
                    value: '8.2',
                    subtitle: 'Out of 10',
                    color: AppTheme.colors.success,
                  ),
                  _StatCard(
                    icon: PhosphorIconsBold.chartLine,
                    title: 'Trend',
                    value: '+15%',
                    subtitle: 'vs last month',
                    color: AppTheme.colors.warning,
                  ),
                ]),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              sliver: SliverToBoxAdapter(
                child: _WeeklyPattern(),
              ),
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: AppSpacing.xl)),
          ],
        ),
      ),
    );
  }
}

class _IntimacyChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                'Intimacy Frequency',
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
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _BarChartBar(height: 0.3, label: 'Mon'),
                _BarChartBar(height: 0.6, label: 'Tue'),
                _BarChartBar(height: 0.4, label: 'Wed'),
                _BarChartBar(height: 0.8, label: 'Thu'),
                _BarChartBar(height: 0.5, label: 'Fri'),
                _BarChartBar(height: 0.9, label: 'Sat'),
                _BarChartBar(height: 0.7, label: 'Sun'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BarChartBar extends StatelessWidget {
  const _BarChartBar({required this.height, required this.label});

  final double height;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: FractionallySizedBox(
                heightFactor: height,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.colors.primary,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppTheme.colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppTheme.colors.text,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyPattern extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BentoCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIconsBold.calendarCheck,
                color: AppTheme.colors.primary,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Weekly Pattern',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.colors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ...['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']
              .asMap()
              .entries
              .map((entry) {
            final index = entry.key;
            final day = entry.value;
            final intensity = [0.6, 0.8, 0.4, 0.9, 0.7][index];
            
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        day,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.colors.text,
                        ),
                      ),
                      Text(
                        '${(intensity * 100).toInt()}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  LinearProgressIndicator(
                    value: intensity,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                    backgroundColor: AppTheme.colors.background,
                    color: AppTheme.colors.primary,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

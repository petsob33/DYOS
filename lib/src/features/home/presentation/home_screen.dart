import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/bento_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.lg,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Home',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.colors.text,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Widgety pro váš život',
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
              sliver: SliverToBoxAdapter(child: _StatusHeader()),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 600;
                    final crossAxisCount = isWide ? 3 : 2;
                    return MasonryGridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: AppSpacing.lg,
                      crossAxisSpacing: AppSpacing.lg,
                      itemCount: _cards.length,
                      itemBuilder: (context, index) => _cards[index],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final _cards = <Widget>[  
  const _DaysTogetherCard(),
  const _CountdownCard(),
  const _QuickNoteCard(),
  const _IntimacySparkCard(),
  const _AnalyticsCard(),
];

class _StatusHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BentoCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [ 
          const _AvatarStatus(name: 'You', emoji: '🚀', status: 'Focus mode'),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Divider(
              color: AppTheme.colors.textSecondary.withOpacity(0.1),
              thickness: 1,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          const _AvatarStatus(
            name: 'Partner',
            emoji: '🌿',
            status: 'Deep work',
          ),
        ],
      ),
    );
  }
}

class _AvatarStatus extends StatelessWidget {
  const _AvatarStatus({
    required this.name,
    required this.emoji,
    required this.status,
  });

  final String name;
  final String emoji;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppTheme.colors.background,
          child: Text(emoji, style: const TextStyle(fontSize: 24)),
        ),
        const SizedBox(width: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.colors.text,
              ),
            ),
            Text(
              status,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.colors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DaysTogetherCard extends StatelessWidget {
  const _DaysTogetherCard();

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Days Together',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppTheme.colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '842',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppTheme.colors.text,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Stronger every day.',
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
}

class _CountdownCard extends StatelessWidget {
  const _CountdownCard();

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Next event',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppTheme.colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '14 days',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppTheme.colors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Anniversary dinner',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.colors.text,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _QuickNoteCard extends StatelessWidget {
  const _QuickNoteCard();

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      background: AppTheme.colors.primary.withOpacity(0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick note',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(color: AppTheme.colors.primary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Shared note:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Koupit víno 🍷',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.colors.text,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _IntimacySparkCard extends StatelessWidget {
  const _IntimacySparkCard();

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppTheme.colors.love.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.local_fire_department_rounded,
              color: AppTheme.colors.love,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               const SizedBox(height: AppSpacing.xs),
                Text(
                  'Last sync: 2 days ago 🔥',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.colors.text,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),               
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  const _AnalyticsCard();

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DYOS Analytics',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppTheme.colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _Chip(
                  label: 'Peak day',
                  value: 'Tuesday',
                  color: AppTheme.colors.success,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _Chip(
                  label: 'Mood',
                  value: 'Stay gentle 💚',
                  color: AppTheme.colors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          LinearProgressIndicator(
            value: 0.72,
            minHeight: 10,
            borderRadius: BorderRadius.circular(8),
            backgroundColor: AppTheme.colors.background,
            color: AppTheme.colors.primary,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '72% aligned',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.colors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppTheme.colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.colors.text,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

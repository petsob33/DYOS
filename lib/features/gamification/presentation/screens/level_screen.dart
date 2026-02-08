import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/bento_card.dart';
import '../../../tracker/presentation/widgets/add_intimacy_sheet.dart';
import '../../domain/level_manager.dart';
import '../../domain/level_tier.dart';
import '../../../auth/presentation/auth_providers.dart';
import '../user_stats_provider.dart';

/// Level / rewards screen in loyalty-style layout. Uses app template: Inter, primary #5E5CE6, Bento cards.
class LevelScreen extends ConsumerWidget {
  const LevelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = AppTheme.colors;
    final currentXp = ref.watch(currentXpProvider);
    final couple = ref.watch(coupleProvider).when(
          data: (x) => x,
          loading: () => null,
          error: (_, __) => null,
        );
    final currentTier = LevelManager.tiers
        .lastWhere((t) => currentXp >= t.minXp, orElse: () => LevelManager.tiers.first);
    final nextTier = LevelManager.nextTierVersionLabel(currentXp);
    final xpToNext = LevelManager.xpToNextTier(currentXp);
    final progress = LevelManager.calculateProgress(currentXp);

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        foregroundColor: c.text,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(PhosphorIconsBold.caretLeft),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Your Level',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: c.text,
          ),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Hero: gradient + tier badge + "Collect X XP to get to next"
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xl),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      c.primary.withOpacity(0.25),
                      c.primary.withOpacity(0.08),
                      c.background,
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: c.card,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: c.shadow,
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            PhosphorIconsBold.star,
                            size: 40,
                            color: c.primary,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            currentTier.versionShort,
                            style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: c.primary,
                            ),
                          ),
                          Text(
                            currentTier.rewardName != '—' ? currentTier.rewardName : 'Starter',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: c.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          if (nextTier != null && xpToNext != null)
                            Text(
                              'Collect $xpToNext XP to get to $nextTier',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: c.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            '$currentXp points',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: c.text,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _TierStepper(currentXp: currentXp, progress: progress),
                  ],
                ),
              ),
            ),
            // Your Rewards
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
                child: Text(
                  'Your Rewards',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: c.text,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _RewardCard(
                            icon: PhosphorIconsBold.gift,
                            label: 'Unlocked',
                            subtitle: currentTier.rewardName != '—' ? currentTier.rewardName : 'Keep going',
                            isUnlocked: true,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _RewardCard(
                            icon: PhosphorIconsBold.rocket,
                            label: nextTier ?? 'Max',
                            subtitle: nextTier != null ? 'Next tier' : 'Top level',
                            isUnlocked: false,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _RewardsList(currentXp: currentXp),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
            // Complete tasks & win rewards
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
                child: Text(
                  'Complete tasks & win rewards',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: c.text,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: BentoCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      _QuestRow(
                        questId: 'blueprint',
                        title: 'Complete a Blueprint section',
                        xp: 100,
                        icon: PhosphorIconsBold.clipboardText,
                        completedToday: isQuestCompletedToday(couple, 'blueprint'),
                        onTap: () => context.push('/blueprints'),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _QuestRow(
                        questId: 'memory',
                        title: 'Add a memory',
                        xp: 25,
                        icon: PhosphorIconsBold.image,
                        completedToday: isQuestCompletedToday(couple, 'memory'),
                        onTap: () => context.push('/add-memory'),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _QuestRow(
                        questId: 'event',
                        title: 'Add an event',
                        xp: 15,
                        icon: PhosphorIconsBold.calendar,
                        completedToday: isQuestCompletedToday(couple, 'event'),
                        onTap: () => context.push('/events'),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _QuestRow(
                        questId: 'intimacy',
                        title: 'Log intimacy',
                        xp: 20,
                        icon: PhosphorIconsBold.heart,
                        completedToday: isQuestCompletedToday(couple, 'intimacy'),
                        onTap: () => AddIntimacySheet.show(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: FilledButton.icon(
                  onPressed: () => context.push('/blueprints'),
                  icon: const Icon(PhosphorIconsBold.clipboardText, size: 22),
                  label: const Text('Open Blueprints'),
                  style: FilledButton.styleFrom(
                    backgroundColor: c.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
          ],
        ),
      ),
    );
  }
}

class _TierStepper extends StatelessWidget {
  const _TierStepper({required this.currentXp, required this.progress});

  final int currentXp;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final c = AppTheme.colors;
    final tiers = LevelManager.tiers;
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: c.textSecondary.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(c.primary),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: tiers.map((tier) {
            final isReached = currentXp >= tier.minXp;
            return Text(
              tier.versionShort,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: isReached ? FontWeight.w700 : FontWeight.w500,
                color: isReached ? c.primary : c.textSecondary,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _RewardCard extends StatelessWidget {
  const _RewardCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.isUnlocked,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final bool isUnlocked;

  @override
  Widget build(BuildContext context) {
    final c = AppTheme.colors;
    return BentoCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isUnlocked ? c.primary.withOpacity(0.12) : c.background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 28, color: isUnlocked ? c.primary : c.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isUnlocked ? c.text : c.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: c.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _RewardsList extends StatelessWidget {
  const _RewardsList({required this.currentXp});

  final int currentXp;

  @override
  Widget build(BuildContext context) {
    final c = AppTheme.colors;
    final tiers = LevelManager.tiers;
    return Column(
      children: [
        for (var i = 0; i < tiers.length; i++) ...[
          _RewardListTile(
            tier: tiers[i],
            unlocked: currentXp >= tiers[i].minXp,
          ),
          if (i < tiers.length - 1) const SizedBox(height: AppSpacing.xs),
        ],
      ],
    );
  }
}

class _RewardListTile extends StatelessWidget {
  const _RewardListTile({required this.tier, required this.unlocked});

  final LevelTier tier;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final c = AppTheme.colors;
    return BentoCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(
            unlocked ? PhosphorIconsBold.checkCircle : PhosphorIconsBold.circle,
            size: 22,
            color: unlocked ? c.success : c.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tier.versionShort,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: unlocked ? c.text : c.textSecondary,
                  ),
                ),
                Text(
                  tier.rewardName,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: c.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (!unlocked)
            Text(
              '${tier.minXp} XP',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: c.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}

class _QuestRow extends StatelessWidget {
  const _QuestRow({
    required this.questId,
    required this.title,
    required this.xp,
    required this.icon,
    required this.completedToday,
    this.onTap,
  });

  final String questId;
  final String title;
  final int xp;
  final IconData icon;
  final bool completedToday;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppTheme.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            Icon(
              completedToday ? PhosphorIconsBold.checkCircle : icon,
              size: 20,
              color: completedToday ? c.success : c.primary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: completedToday ? c.textSecondary : c.text,
                    ),
                  ),
                  if (completedToday)
                    Text(
                      'Splněno dnes',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: c.success,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
            if (!completedToday)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                decoration: BoxDecoration(
                  color: c.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+$xp XP',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: c.primary,
                  ),
                ),
              )
            else
              Icon(PhosphorIconsBold.check, size: 18, color: c.success),
          ],
        ),
      ),
    );
  }
}

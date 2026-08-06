import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/l10n/build_context_l10n_extension.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/bento_card.dart';
import '../../../tracker/presentation/widgets/add_intimacy_sheet.dart';
import '../../../premium/presentation/premium_provider.dart';
import '../../domain/level_manager.dart';
import '../../domain/progression_plan.dart';
import '../../../auth/presentation/auth_providers.dart';
import '../user_stats_provider.dart';
import '../widgets/level_up_unlock_sheet.dart';

/// Level / rewards screen in loyalty-style layout. Uses app template: Inter, primary #5E5CE6, Bento cards.
class LevelScreen extends ConsumerStatefulWidget {
  const LevelScreen({super.key});

  @override
  ConsumerState<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends ConsumerState<LevelScreen> {
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final currentSp = ref.watch(currentXpProvider); // SP stored as xp in Firestore
    final isPremium = ref.watch(isPremiumProvider).valueOrNull ?? false;
    final memoriesUnlocked = ProgressionPlan.isFeatureUnlocked(
      FeatureID.memories,
      currentSp,
      isPremium,
    );
    final couple = ref.watch(coupleProvider).when(
          data: (x) => x,
          loading: () => null,
          error: (_, __) => null,
        );
    final currentPhase = ProgressionPlan.phaseForSp(currentSp);
    final nextTier = LevelManager.nextTierVersionLabel(currentSp);
    final spToNext = LevelManager.xpToNextTier(currentSp);
    final progress = LevelManager.calculateProgress(currentSp);

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
          context.l10n.levelScreenTitle,
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
                          Text(
                            currentPhase?.emoji ?? '🏁',
                            style: const TextStyle(fontSize: 40),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            currentPhase?.name ?? context.l10n.levelScreenBootSequence,
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: c.text,
                            ),
                          ),
                          Text(
                            LevelManager.currentVersionString(currentSp),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: c.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          if (nextTier != null && spToNext != null)
                            Text(
                              context.l10n.levelScreenCollectSpToNextTier(spToNext, nextTier),
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: c.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            context.l10n.levelScreenSpValue(currentSp),
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
                    _TierStepper(currentXp: currentSp, progress: progress),
                  ],
                ),
              ),
            ),
            // All milestones (rewards + level ups)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
                child: Text(
                  context.l10n.levelScreenProgressionRewardsHeading,
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
                child: _MilestonesList(currentSp: currentSp),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
            // Complete tasks & win rewards
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
                child: Text(
                  context.l10n.levelScreenCompleteTasksHeading,
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
                        title: context.l10n.levelScreenQuestBlueprintTitle,
                        sp: 100,
                        icon: PhosphorIconsBold.clipboardText,
                        completedToday: isQuestCompletedToday(couple, 'blueprint'),
                        onTap: () => context.push('/blueprints'),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _QuestRow(
                        questId: 'memory',
                        title: context.l10n.levelScreenQuestMemoryTitle,
                        sp: 25,
                        icon: PhosphorIconsBold.image,
                        completedToday: isQuestCompletedToday(couple, 'memory'),
                        onTap: () {
                          if (memoriesUnlocked) {
                            context.push('/add-memory');
                          } else {
                            showLevelUpUnlockSheet(context, ref, FeatureID.memories);
                          }
                        },
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _QuestRow(
                        questId: 'event',
                        title: context.l10n.levelScreenQuestEventTitle,
                        sp: 15,
                        icon: PhosphorIconsBold.calendar,
                        completedToday: isQuestCompletedToday(couple, 'event'),
                        onTap: () => context.push('/events'),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _QuestRow(
                        questId: 'intimacy',
                        title: context.l10n.levelScreenQuestIntimacyTitle,
                        sp: 20,
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
                child: FilledButton(
                  onPressed: () => context.push('/blueprints'),
                  style: FilledButton.styleFrom(
                    backgroundColor: c.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Icon(PhosphorIconsBold.clipboardText, size: 22),
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
    final c = context.colors;
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

/// Full list of progression milestones with a vertical progress line.
class _MilestonesList extends StatelessWidget {
  const _MilestonesList({required this.currentSp});

  final int currentSp;

  static const double _dotSize = 24.0;
  static const double _lineWidth = 2.0;
  static const double _trackWidth = 40.0;

  @override
  Widget build(BuildContext context) {
    final milestones = ProgressionPlan.milestones;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < milestones.length; i++) ...[
          _MilestoneRow(
            milestone: milestones[i],
            unlocked: ProgressionPlan.isMilestoneUnlocked(currentSp, milestones[i].spRequired),
            isFirst: i == 0,
            isLast: i == milestones.length - 1,
            lineAboveUnlocked: i > 0 && ProgressionPlan.isMilestoneUnlocked(currentSp, milestones[i - 1].spRequired),
            dotSize: _dotSize,
            lineWidth: _lineWidth,
            trackWidth: _trackWidth,
          ),
        ],
      ],
    );
  }
}

class _MilestoneRow extends StatelessWidget {
  const _MilestoneRow({
    required this.milestone,
    required this.unlocked,
    required this.isFirst,
    required this.isLast,
    required this.lineAboveUnlocked,
    required this.dotSize,
    required this.lineWidth,
    required this.trackWidth,
  });

  final ProgressionMilestone milestone;
  final bool unlocked;
  final bool isFirst;
  final bool isLast;
  final bool lineAboveUnlocked;
  final double dotSize;
  final double lineWidth;
  final double trackWidth;

  /// Version string for level-up milestones (e.g. "v2.0" from "Upgrade to v2.0").
  String get _versionShort {
    final d = milestone.description;
    final match = RegExp(r'v\d+\.\d+').firstMatch(d);
    return match?.group(0) ?? milestone.title;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isLevelUp = milestone.type == MilestoneType.levelUp;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Progress line: segment above + node (dot or version gate) + segment below
          SizedBox(
            width: trackWidth,
            child: Column(
              children: [
                if (isFirst) SizedBox(height: dotSize / 2) else Expanded(
                  child: Container(
                    width: lineWidth,
                    margin: EdgeInsets.only(left: (trackWidth - lineWidth) / 2),
                    decoration: BoxDecoration(
                      color: lineAboveUnlocked ? c.primary : c.textSecondary.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(lineWidth / 2),
                    ),
                  ),
                ),
                // Node: version gate (pill) for level-up, round dot for rewards
                if (isLevelUp)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: unlocked ? c.primary : c.textSecondary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: unlocked ? c.primary : c.textSecondary.withOpacity(0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      _versionShort,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: unlocked ? Colors.white : c.textSecondary,
                      ),
                    ),
                  )
                else
                  Container(
                    width: dotSize,
                    height: dotSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: unlocked ? c.primary : c.background,
                      border: Border.all(
                        color: unlocked ? c.primary : c.textSecondary.withOpacity(0.4),
                        width: 2,
                      ),
                      boxShadow: unlocked
                          ? [
                              BoxShadow(
                                color: c.primary.withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        milestone.emoji ?? (unlocked ? '✓' : ''),
                        style: TextStyle(fontSize: dotSize * 0.5),
                      ),
                    ),
                  ),
                if (isLast) SizedBox(height: dotSize / 2) else Expanded(
                  child: Container(
                    width: lineWidth,
                    margin: EdgeInsets.only(left: (trackWidth - lineWidth) / 2),
                    decoration: BoxDecoration(
                      color: unlocked ? c.primary : c.textSecondary.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(lineWidth / 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Content card
          Expanded(
            child: BentoCard(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          milestone.title,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: unlocked ? c.text : c.textSecondary,
                          ),
                        ),
                        Text(
                          milestone.description,
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
                      context.l10n.levelScreenSpValue(milestone.spRequired),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: c.textSecondary,
                      ),
                    )
                  else
                    Icon(
                      PhosphorIconsBold.checkCircle,
                      size: 20,
                      color: c.success,
                    ),
                ],
              ),
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
    required this.sp,
    required this.icon,
    required this.completedToday,
    this.onTap,
  });

  final String questId;
  final String title;
  final int sp;
  final IconData icon;
  final bool completedToday;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
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
                      context.l10n.levelScreenCompletedToday,
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
                  context.l10n.levelScreenQuestRewardBadge(sp),
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

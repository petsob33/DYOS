import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/bento_card.dart';
import '../../domain/level_manager.dart';

/// iOS System Update–style Bento card showing current "OS Version" and XP progress.
class SystemStatusCard extends StatefulWidget {
  const SystemStatusCard({
    super.key,
    required this.currentXp,
  });

  final int currentXp;

  @override
  State<SystemStatusCard> createState() => _SystemStatusCardState();
}

class _SystemStatusCardState extends State<SystemStatusCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    final targetProgress =
        LevelManager.calculateProgress(widget.currentXp).clamp(0.0, 1.0);
    _progressAnimation = Tween<double>(begin: 0, end: targetProgress).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeOutCubic,
      ),
    );
    _progressController.forward();
  }

  @override
  void didUpdateWidget(SystemStatusCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentXp != widget.currentXp) {
      final targetProgress =
          LevelManager.calculateProgress(widget.currentXp).clamp(0.0, 1.0);
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: targetProgress,
      ).animate(
        CurvedAnimation(
          parent: _progressController,
          curve: Curves.easeOutCubic,
        ),
      );
      _progressController
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppTheme.colors;
    final versionStr = LevelManager.currentVersionString(widget.currentXp);
    final tierMax = LevelManager.currentTierMaxXp(widget.currentXp);
    final nextLabel = LevelManager.nextTierVersionLabel(widget.currentXp);
    final xpToNext = LevelManager.xpToNextTier(widget.currentXp);
    final nextReward = LevelManager.nextRewardTip(widget.currentXp);

    return BentoCard(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.lg,
        horizontal: AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top: Current Version chip
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: c.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Current Version: $versionStr',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: c.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Progress bar (thick, rounded)
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, _) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LinearProgressIndicator(
                  value: _progressAnimation.value,
                  minHeight: 14,
                  backgroundColor: c.background,
                  valueColor: AlwaysStoppedAnimation<Color>(c.primary),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          // XP text: "750 / 2000 XP to v3.0"
          Center(
            child: Text(
              nextLabel != null && xpToNext != null
                  ? '${widget.currentXp} / $tierMax XP to $nextLabel'
                  : '${widget.currentXp} XP · Max level',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: c.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Bottom: Next reward tip
          Center(
            child: Text(
              nextReward,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: c.textSecondary,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

import 'level_tier.dart';
import 'progression_plan.dart';

/// Manages SP-based "OS Version" levels and progress (Soul Points = XP in Firestore).
/// Delegates to [ProgressionPlan] for phases and milestones.
class LevelManager {
  LevelManager._();

  /// Legacy tiers: derived from [ProgressionPlan.phases] for backward compatibility.
  /// Used by widgets that still expect LevelTier (e.g. stepper). Version labels match plan.
  static const List<LevelTier> tiers = [
    LevelTier(
      versionLabel: 'v1.0 (Start)',
      minXp: 0,
      maxXp: 1000,
      rewardName: '—',
    ),
    LevelTier(
      versionLabel: 'v2.0 (Connected)',
      minXp: 1000,
      maxXp: 5000,
      rewardName: 'Local Network',
    ),
    LevelTier(
      versionLabel: 'v3.0 (Synchronized)',
      minXp: 5000,
      maxXp: 20000,
      rewardName: 'Cloud Sync',
    ),
    LevelTier(
      versionLabel: 'v4.0 (Mainframe)',
      minXp: 20000,
      maxXp: 100000,
      rewardName: 'Mainframe',
    ),
    LevelTier(
      versionLabel: 'Singularity',
      minXp: 100000,
      maxXp: 100000,
      rewardName: 'Lifetime DYOS+',
    ),
  ];

  /// Progress within the current phase: 0.0 at phase start, 1.0 at phase end.
  /// [currentXp] is SP (stored as xp in Firestore).
  static double calculateProgress(int currentXp) {
    return ProgressionPlan.progressInPhase(currentXp);
  }

  /// Current version string e.g. "v2.0" (from current phase).
  static String currentVersionString(int currentXp) {
    return ProgressionPlan.versionStringForSp(currentXp);
  }

  /// SP required to reach the next phase (null if at max).
  static int? xpToNextTier(int currentXp) {
    return ProgressionPlan.spToNextPhase(currentXp);
  }

  /// Min SP of current phase (for display "current / target").
  static int currentTierMinXp(int currentXp) {
    return ProgressionPlan.phaseForSp(currentXp)?.minSp ?? 0;
  }

  /// Max SP of current phase (target for progress line).
  static int currentTierMaxXp(int currentXp) {
    return ProgressionPlan.currentPhaseMaxSp(currentXp);
  }

  /// Label of the next phase e.g. "v2.0".
  static String? nextTierVersionLabel(int currentXp) {
    return ProgressionPlan.nextPhaseVersionLabel(currentXp);
  }

  /// Next reward description for UI.
  static String nextRewardTip(int currentXp) {
    return ProgressionPlan.nextRewardTip(currentXp);
  }
}

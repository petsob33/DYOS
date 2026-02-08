/// Defines one "OS Version" tier in the gamification system.
class LevelTier {
  const LevelTier({
    required this.versionLabel,
    required this.minXp,
    required this.maxXp,
    required this.rewardName,
  });

  /// Display label e.g. "v2.0 (Stable)".
  final String versionLabel;

  /// Short version for progress e.g. "v2.0".
  String get versionShort =>
      versionLabel.split(' ').first; // "v2.0 (Stable)" -> "v2.0"

  /// Inclusive min XP for this tier.
  final int minXp;

  /// Exclusive max XP for this tier (XP >= maxXp moves to next tier).
  final int maxXp;

  /// Reward unlocked at this tier e.g. "Dark Mode".
  final String rewardName;
}

import 'level_tier.dart';

/// Manages XP-based "OS Version" levels and progress for gamification.
class LevelManager {
  LevelManager._();

  static const List<LevelTier> tiers = [
    LevelTier(
      versionLabel: 'v1.0 (Start)',
      minXp: 0,
      maxXp: 500,
      rewardName: '—',
    ),
    LevelTier(
      versionLabel: 'v2.0 (Stable)',
      minXp: 500,
      maxXp: 2000,
      rewardName: 'Dark Mode',
    ),
    LevelTier(
      versionLabel: 'v3.0 (High Perf)',
      minXp: 2000,
      maxXp: 5000,
      rewardName: 'The Vault',
    ),
    LevelTier(
      versionLabel: 'v4.0 (Deep Sync)',
      minXp: 5000,
      maxXp: 10000,
      rewardName: 'Analytics',
    ),
    LevelTier(
      versionLabel: 'v5.0 (Prime)',
      minXp: 10000,
      maxXp: 100000,
      rewardName: 'Lifetime Premium',
    ),
  ];

  /// Progress within the current tier: 0.0 at tier start, 1.0 at tier end (or max level).
  static double calculateProgress(int currentXp) {
    final tier = _tierForXp(currentXp);
    if (tier == null) return 0.0;
    final isMaxTier = tier == tiers.last;
    if (isMaxTier) {
      if (currentXp >= tier.maxXp) return 1.0;
      return (currentXp - tier.minXp) / (tier.maxXp - tier.minXp).clamp(0.0, 1.0);
    }
    final range = tier.maxXp - tier.minXp;
    return ((currentXp - tier.minXp) / range).clamp(0.0, 1.0);
  }

  /// Current version string e.g. "v2.4" (interpolated within tier).
  static String currentVersionString(int currentXp) {
    final tier = _tierForXp(currentXp);
    if (tier == null) return 'v1.0';
    final isMaxTier = tier == tiers.last;
    if (isMaxTier && currentXp >= tier.maxXp) {
      return tier.versionShort;
    }
    final progress = (currentXp - tier.minXp) / (tier.maxXp - tier.minXp).clamp(0.0, 1.0);
    final major = tier.versionShort.replaceFirst('v', '').split('.').first;
    final minor = (progress * 10).floor().clamp(0, 9);
    return 'v$major.$minor';
  }

  /// XP required to reach the next tier (null if at max tier).
  static int? xpToNextTier(int currentXp) {
    final tier = _tierForXp(currentXp);
    if (tier == null || tier == tiers.last) return null;
    return tier.maxXp - currentXp;
  }

  /// Total XP of the current tier start (for display "current / target").
  static int currentTierMinXp(int currentXp) {
    final tier = _tierForXp(currentXp);
    return tier?.minXp ?? 0;
  }

  /// Total XP needed to reach next tier (target for progress line).
  static int currentTierMaxXp(int currentXp) {
    final tier = _tierForXp(currentXp);
    if (tier == null) return 500;
    return tier.maxXp;
  }

  /// Label of the next tier e.g. "v3.0".
  static String? nextTierVersionLabel(int currentXp) {
    final idx = _tierIndexForXp(currentXp);
    if (idx == null || idx >= tiers.length - 1) return null;
    return tiers[idx + 1].versionShort;
  }

  /// Next reward description for UI e.g. "Next Unlock: The Vault Feature 🔐".
  static String nextRewardTip(int currentXp) {
    final idx = _tierIndexForXp(currentXp);
    if (idx == null) return 'Earn XP to unlock rewards.';
    if (idx >= tiers.length - 1) {
      return 'You have unlocked all rewards.';
    }
    final next = tiers[idx + 1];
    return 'Next Unlock: ${next.rewardName} Feature 🔐';
  }

  static LevelTier? _tierForXp(int xp) {
    for (var i = tiers.length - 1; i >= 0; i--) {
      if (xp >= tiers[i].minXp) return tiers[i];
    }
    return tiers.first;
  }

  static int? _tierIndexForXp(int xp) {
    for (var i = tiers.length - 1; i >= 0; i--) {
      if (xp >= tiers[i].minXp) return i;
    }
    return 0;
  }
}

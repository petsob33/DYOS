/// Soul Points (SP) progression plan: phases and milestones.
/// SP is stored as [CoupleModel.xp] in Firestore; we display it as "SP" in UI.

enum MilestoneType {
  /// Level up to next OS version (e.g. v2.0 Connected).
  levelUp,

  /// Unlockable reward (badge, widget, feature, etc.).
  reward,
}

/// Feature gates for UI locking (Memories, Blueprints, Quick Messages, Map View).
enum FeatureID {
  memories,
  blueprints,
  quickMessages,
  mapView,
}

enum RewardKind {
  badge,
  widget,
  iconPack,
  taptic,
  blueprintPack,
  premiumTrial,
  chatWallpapers,
  mapView,
  lifetimeLicense,
}

/// One phase in the progression (e.g. Boot Sequence, Local Network).
class ProgressionPhase {
  const ProgressionPhase({
    required this.id,
    required this.name,
    required this.emoji,
    required this.minSp,
    required this.maxSp,
    required this.versionLabel,
  });

  final String id;
  final String name;
  final String emoji;
  final int minSp;
  final int maxSp;
  /// e.g. "v1.0", "v2.0 (Connected)"
  final String versionLabel;
}

/// A single milestone (reward or level-up) at a given SP threshold.
class ProgressionMilestone {
  const ProgressionMilestone({
    required this.spRequired,
    required this.type,
    required this.title,
    required this.description,
    this.rewardKind,
    this.emoji,
    this.subscriptionReward = false,
  });

  final int spRequired;
  final MilestoneType type;
  final String title;
  final String description;
  final RewardKind? rewardKind;
  final String? emoji;
  /// True for milestones that grant subscription credit (1 Month Free / 1 Year Free).
  final bool subscriptionReward;
}

/// Full progression plan: phases and milestones. SP = XP in backend.
class ProgressionPlan {
  ProgressionPlan._();

  static const List<ProgressionPhase> phases = [
    ProgressionPhase(
      id: 'boot',
      name: 'Boot Sequence',
      emoji: '🏁',
      minSp: 0,
      maxSp: 1000,
      versionLabel: 'v1.0',
    ),
    ProgressionPhase(
      id: 'local',
      name: 'Local Network',
      emoji: '🔌',
      minSp: 1000,
      maxSp: 5000,
      versionLabel: 'v2.0 (Connected)',
    ),
    ProgressionPhase(
      id: 'cloud',
      name: 'Cloud Sync',
      emoji: '☁️',
      minSp: 5000,
      maxSp: 20000,
      versionLabel: 'v3.0 (Synchronized)',
    ),
    ProgressionPhase(
      id: 'mainframe',
      name: 'Mainframe',
      emoji: '🖥️',
      minSp: 20000,
      maxSp: 100000,
      versionLabel: 'v4.0 (Mainframe)',
    ),
    ProgressionPhase(
      id: 'singularity',
      name: 'Singularity',
      emoji: '🌌',
      minSp: 100000,
      maxSp: 100000,
      versionLabel: 'Endgame',
    ),
  ];

  /// All milestones in SP order.
  static const List<ProgressionMilestone> milestones = [
    ProgressionMilestone(
      spRequired: 25,
      type: MilestoneType.reward,
      title: 'Memory Core',
      description: 'Unlock Memories',
      rewardKind: RewardKind.badge,
      emoji: '🔓',
    ),
    ProgressionMilestone(
      spRequired: 50,
      type: MilestoneType.reward,
      title: 'Blueprint Protocol',
      description: 'Unlock Blueprints',
      rewardKind: RewardKind.blueprintPack,
      emoji: '🔓',
    ),
    ProgressionMilestone(
      spRequired: 100,
      type: MilestoneType.reward,
      title: 'Badge: Initiate',
      description: 'First milestone badge',
      rewardKind: RewardKind.badge,
      emoji: '🏅',
    ),
    ProgressionMilestone(
      spRequired: 200,
      type: MilestoneType.reward,
      title: 'Quick Link',
      description: 'Unlock Quick Messages',
      rewardKind: RewardKind.badge,
      emoji: '🔓',
    ),
    ProgressionMilestone(
      spRequired: 300,
      type: MilestoneType.reward,
      title: 'Badge: Data Miner',
      description: 'Earned at 300 SP',
      rewardKind: RewardKind.badge,
      emoji: '🏅',
    ),
    ProgressionMilestone(
      spRequired: 500,
      type: MilestoneType.reward,
      title: 'Badge: Synchronized',
      description: 'Earned at 500 SP',
      rewardKind: RewardKind.badge,
      emoji: '🏅',
    ),
    ProgressionMilestone(
      spRequired: 750,
      type: MilestoneType.reward,
      title: 'BP Expansion I',
      description: 'Blueprint expansion pack',
      rewardKind: RewardKind.blueprintPack,
      emoji: '📦',
    ),
    ProgressionMilestone(
      spRequired: 1000,
      type: MilestoneType.reward,
      title: 'Badge: Verified Couple',
      description: '1 Month Free',
      rewardKind: RewardKind.premiumTrial,
      emoji: '🎁',
      subscriptionReward: true,
    ),
    ProgressionMilestone(
      spRequired: 2000,
      type: MilestoneType.reward,
      title: 'BP Expansion II',
      description: 'Blueprint expansion pack',
      rewardKind: RewardKind.blueprintPack,
      emoji: '📦',
    ),
    ProgressionMilestone(
      spRequired: 3000,
      type: MilestoneType.reward,
      title: 'Badge: System Architect',
      description: 'Earned at 3000 SP',
      rewardKind: RewardKind.badge,
      emoji: '🏅',
    ),
    ProgressionMilestone(
      spRequired: 5000,
      type: MilestoneType.reward,
      title: 'Map View',
      description: 'Unlock Memory Map',
      rewardKind: RewardKind.mapView,
      emoji: '🔓',
    ),
    ProgressionMilestone(
      spRequired: 7500,
      type: MilestoneType.reward,
      title: 'Badge: Global Explorer',
      description: 'Earned at 7500 SP',
      rewardKind: RewardKind.badge,
      emoji: '🏅',
    ),
    ProgressionMilestone(
      spRequired: 10000,
      type: MilestoneType.reward,
      title: 'Golden Frame',
      description: '1 Month Free',
      rewardKind: RewardKind.premiumTrial,
      emoji: '🎁',
      subscriptionReward: true,
    ),
    ProgressionMilestone(
      spRequired: 20000,
      type: MilestoneType.reward,
      title: 'Badge: 20k SP',
      description: '1 Month Free',
      rewardKind: RewardKind.premiumTrial,
      emoji: '🏅',
      subscriptionReward: true,
    ),
    ProgressionMilestone(
      spRequired: 30000,
      type: MilestoneType.reward,
      title: 'Badge: 30k SP',
      description: '1 Month Free',
      rewardKind: RewardKind.premiumTrial,
      emoji: '🏅',
      subscriptionReward: true,
    ),
    ProgressionMilestone(
      spRequired: 40000,
      type: MilestoneType.reward,
      title: 'Badge: 40k SP',
      description: '1 Month Free',
      rewardKind: RewardKind.premiumTrial,
      emoji: '🏅',
      subscriptionReward: true,
    ),
    ProgressionMilestone(
      spRequired: 50000,
      type: MilestoneType.reward,
      title: 'Badge: 50k SP',
      description: '1 Month Free',
      rewardKind: RewardKind.premiumTrial,
      emoji: '🏅',
      subscriptionReward: true,
    ),
    ProgressionMilestone(
      spRequired: 60000,
      type: MilestoneType.reward,
      title: 'Badge: 60k SP',
      description: '1 Month Free',
      rewardKind: RewardKind.premiumTrial,
      emoji: '🏅',
      subscriptionReward: true,
    ),
    ProgressionMilestone(
      spRequired: 70000,
      type: MilestoneType.reward,
      title: 'Badge: 70k SP',
      description: '1 Month Free',
      rewardKind: RewardKind.premiumTrial,
      emoji: '🏅',
      subscriptionReward: true,
    ),
    ProgressionMilestone(
      spRequired: 80000,
      type: MilestoneType.reward,
      title: 'Badge: 80k SP',
      description: '1 Month Free',
      rewardKind: RewardKind.premiumTrial,
      emoji: '🏅',
      subscriptionReward: true,
    ),
    ProgressionMilestone(
      spRequired: 90000,
      type: MilestoneType.reward,
      title: 'Badge: 90k SP',
      description: '1 Month Free',
      rewardKind: RewardKind.premiumTrial,
      emoji: '🏅',
      subscriptionReward: true,
    ),
    ProgressionMilestone(
      spRequired: 100000,
      type: MilestoneType.reward,
      title: 'Singularity Frame',
      description: '1 Year Free',
      rewardKind: RewardKind.lifetimeLicense,
      emoji: '🏆',
      subscriptionReward: true,
    ),
  ];

  static ProgressionPhase? phaseForSp(int sp) {
    for (var i = phases.length - 1; i >= 0; i--) {
      if (sp >= phases[i].minSp) return phases[i];
    }
    return phases.first;
  }

  static int phaseIndexForSp(int sp) {
    for (var i = phases.length - 1; i >= 0; i--) {
      if (sp >= phases[i].minSp) return i;
    }
    return 0;
  }

  /// Progress within current phase: 0.0 at phase start, 1.0 at phase end (or max).
  static double progressInPhase(int sp) {
    final phase = phaseForSp(sp);
    if (phase == null) return 0.0;
    if (phase.minSp >= phase.maxSp) return 1.0; // Singularity
    final range = phase.maxSp - phase.minSp;
    final progress = (sp - phase.minSp) / range;
    return progress.clamp(0.0, 1.0);
  }

  /// Version string for current SP (e.g. v1.0, v2.0, v4.0).
  static String versionStringForSp(int sp) {
    final phase = phaseForSp(sp);
    if (phase == null) return 'v1.0';
    if (phase.versionLabel == 'Endgame') return 'v4.0';
    return phase.versionLabel.split(' ').first; // "v2.0 (Connected)" -> "v2.0"
  }

  /// SP needed to reach next phase (null if at last phase).
  static int? spToNextPhase(int sp) {
    final idx = phaseIndexForSp(sp);
    if (idx >= phases.length - 1) return null;
    return phases[idx].maxSp - sp;
  }

  /// Max SP of current phase (for progress bar target).
  static int currentPhaseMaxSp(int sp) {
    final phase = phaseForSp(sp);
    return phase?.maxSp ?? 1000;
  }

  /// Next phase version label (e.g. "v2.0").
  static String? nextPhaseVersionLabel(int sp) {
    final idx = phaseIndexForSp(sp);
    if (idx >= phases.length - 1) return null;
    final next = phases[idx + 1];
    return next.versionLabel.split(' ').first;
  }

  /// Next milestone not yet reached (null if all unlocked).
  static ProgressionMilestone? nextMilestone(int sp) {
    for (final m in milestones) {
      if (sp < m.spRequired) return m;
    }
    return null;
  }

  /// Whether the milestone at [spRequired] is unlocked for given [sp].
  static bool isMilestoneUnlocked(int sp, int spRequired) => sp >= spRequired;

  /// Functional unlocks (Map, Blueprints pack, Taptic, Widget) are
  /// unlocked immediately with DYOS+; otherwise they follow SP milestones.
  /// Cosmetic rewards (badges, icons, wallpapers) and Lifetime are SP-only.
  static const Set<RewardKind> functionalRewardKinds = {
    RewardKind.widget,
    RewardKind.taptic,
    RewardKind.blueprintPack,
    RewardKind.mapView,
  };

  /// True if the reward for [kind] is unlocked: premium unlocks all functional
  /// features; otherwise uses [currentSp] vs milestone threshold.
  /// For feature gates (Memories, Blueprints, Quick Messages, Map View) use [isFeatureUnlocked] with [FeatureID].
  static bool isRewardUnlocked(RewardKind kind, int currentSp, bool isPremium) {
    if (isPremium && functionalRewardKinds.contains(kind)) return true;
    final list = milestones.where((m) => m.rewardKind == kind).toList();
    if (list.isEmpty) return false;
    return currentSp >= list.first.spRequired;
  }

  /// SP required to unlock [feature] via progression (premium unlocks regardless).
  static int spRequiredForFeature(FeatureID feature) {
    switch (feature) {
      case FeatureID.memories:
        return 25;
      case FeatureID.blueprints:
        return 50;
      case FeatureID.quickMessages:
        return 200;
      case FeatureID.mapView:
        return 5000;
    }
  }

  /// True if [feature] is unlocked: user has active premium or has reached the required SP.
  static bool isFeatureUnlocked(FeatureID feature, int currentSp, bool isPremium) {
    if (isPremium) return true;
    return currentSp >= spRequiredForFeature(feature);
  }

  /// Short tip for "next reward" in UI.
  static String nextRewardTip(int sp) {
    final next = nextMilestone(sp);
    if (next == null) return 'You have unlocked all rewards.';
    return 'Next: ${next.title} at ${next.spRequired} SP';
  }
}

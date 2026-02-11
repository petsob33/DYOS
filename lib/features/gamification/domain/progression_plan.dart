/// Soul Points (SP) progression plan: phases and milestones.
/// SP is stored as [CoupleModel.xp] in Firestore; we display it as "SP" in UI.

enum MilestoneType {
  /// Level up to next OS version (e.g. v2.0 Connected).
  levelUp,

  /// Unlockable reward (badge, widget, feature, etc.).
  reward,
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
  timeCapsule,
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
  });

  final int spRequired;
  final MilestoneType type;
  final String title;
  final String description;
  final RewardKind? rewardKind;
  final String? emoji;
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

  /// All milestones in SP order (0, 250, 500, 1000, ...).
  static const List<ProgressionMilestone> milestones = [
    ProgressionMilestone(
      spRequired: 0,
      type: MilestoneType.levelUp,
      title: 'Start',
      description: 'v1.0',
      emoji: '🚀',
    ),
    ProgressionMilestone(
      spRequired: 250,
      type: MilestoneType.reward,
      title: 'Hello World',
      description: 'První odznak na profil',
      rewardKind: RewardKind.badge,
      emoji: '🏅',
    ),
    ProgressionMilestone(
      spRequired: 500,
      type: MilestoneType.reward,
      title: 'Sticky Note Widget',
      description: 'Odemkne widget na plochu',
      rewardKind: RewardKind.widget,
      emoji: '🔓',
    ),
    ProgressionMilestone(
      spRequired: 1000,
      type: MilestoneType.levelUp,
      title: 'Connected',
      description: 'Přechod na v2.0',
      emoji: '⬆️',
    ),
    ProgressionMilestone(
      spRequired: 1500,
      type: MilestoneType.reward,
      title: 'Dark Mode',
      description: 'Změna ikony aplikace na černou',
      rewardKind: RewardKind.iconPack,
      emoji: '🎨',
    ),
    ProgressionMilestone(
      spRequired: 2500,
      type: MilestoneType.reward,
      title: 'Taptic Touch',
      description: 'Haptická komunikace',
      rewardKind: RewardKind.taptic,
      emoji: '🔓',
    ),
    ProgressionMilestone(
      spRequired: 3500,
      type: MilestoneType.reward,
      title: 'Streak Master',
      description: 'Za udržení aktivity',
      rewardKind: RewardKind.badge,
      emoji: '🏅',
    ),
    ProgressionMilestone(
      spRequired: 5000,
      type: MilestoneType.levelUp,
      title: 'Synchronized',
      description: 'Přechod na v3.0',
      emoji: '⬆️',
    ),
    ProgressionMilestone(
      spRequired: 7500,
      type: MilestoneType.reward,
      title: 'Sex & Intimacy Pack',
      description: 'Odemkne speciální sadu otázek v Blueprints',
      rewardKind: RewardKind.blueprintPack,
      emoji: '🔓',
    ),
    ProgressionMilestone(
      spRequired: 10000,
      type: MilestoneType.reward,
      title: '1 Month Premium Trial',
      description: 'Ochutnávka Premium funkcí na měsíc zdarma',
      rewardKind: RewardKind.premiumTrial,
      emoji: '🎁',
    ),
    ProgressionMilestone(
      spRequired: 15000,
      type: MilestoneType.reward,
      title: 'Chat Wallpapers',
      description: 'Vlastní pozadí v chatu',
      rewardKind: RewardKind.chatWallpapers,
      emoji: '🎨',
    ),
    ProgressionMilestone(
      spRequired: 20000,
      type: MilestoneType.levelUp,
      title: 'Mainframe',
      description: 'Přechod na v4.0',
      emoji: '⬆️',
    ),
    ProgressionMilestone(
      spRequired: 30000,
      type: MilestoneType.reward,
      title: 'Map View',
      description: 'Odemkne mapu vzpomínek',
      rewardKind: RewardKind.mapView,
      emoji: '🔓',
    ),
    ProgressionMilestone(
      spRequired: 50000,
      type: MilestoneType.reward,
      title: 'Time Capsule',
      description: 'Odemkne zprávy do budoucnosti',
      rewardKind: RewardKind.timeCapsule,
      emoji: '🔓',
    ),
    ProgressionMilestone(
      spRequired: 75000,
      type: MilestoneType.reward,
      title: 'System Architect',
      description: 'Zlatý profilový rámeček',
      rewardKind: RewardKind.badge,
      emoji: '🏅',
    ),
    ProgressionMilestone(
      spRequired: 100000,
      type: MilestoneType.reward,
      title: 'Lifetime DYOS+ License',
      description: 'Ultimate reward',
      rewardKind: RewardKind.lifetimeLicense,
      emoji: '🏆',
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

  /// Short tip for "next reward" in UI.
  static String nextRewardTip(int sp) {
    final next = nextMilestone(sp);
    if (next == null) return 'You have unlocked all rewards.';
    return 'Next: ${next.title} at ${next.spRequired} SP';
  }
}

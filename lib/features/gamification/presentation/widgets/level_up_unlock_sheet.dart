import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/l10n/build_context_l10n_extension.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/progression_plan.dart';
import '../../../premium/presentation/widgets/paywall_modal.dart';
import '../user_stats_provider.dart';

/// Shows a bottom sheet when a feature is locked: required SP, current SP, and actions to level up or get DYOS+.
void showLevelUpUnlockSheet(
  BuildContext context,
  WidgetRef ref,
  FeatureID feature,
) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _LevelUpUnlockSheet(feature: feature),
  );
}

String _featureDisplayName(BuildContext context, FeatureID feature) {
  switch (feature) {
    case FeatureID.memories:
      return context.l10n.levelUpUnlockSheetFeatureMemories;
    case FeatureID.blueprints:
      return context.l10n.levelUpUnlockSheetFeatureBlueprints;
    case FeatureID.quickMessages:
      return context.l10n.levelUpUnlockSheetFeatureQuickMessages;
    case FeatureID.mapView:
      return context.l10n.levelUpUnlockSheetFeatureMapView;
  }
}

class _LevelUpUnlockSheet extends ConsumerWidget {
  const _LevelUpUnlockSheet({required this.feature});

  final FeatureID feature;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSp = ref.watch(currentXpProvider);
    final requiredSp = ProgressionPlan.spRequiredForFeature(feature);
    final featureName = _featureDisplayName(context, feature);
    final c = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: c.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: c.shadow.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 6,
              decoration: BoxDecoration(
                color: c.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            context.l10n.levelUpUnlockSheetTitle,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: c.text,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            featureName,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: c.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            context.l10n.levelUpUnlockSheetRequirementBody(requiredSp, featureName, currentSp),
            style: GoogleFonts.inter(
              fontSize: 14,
              color: c.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Future.delayed(const Duration(milliseconds: 200), () {
                      if (context.mounted) context.push('/level');
                    });
                  },
                  icon: const Icon(PhosphorIconsBold.mapTrifold, size: 20),
                  label: Text(context.l10n.levelUpUnlockSheetViewRoadmap),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Future.delayed(const Duration(milliseconds: 200), () {
                      if (context.mounted) PaywallModal.show(context, ref);
                    });
                  },
                  icon: const Icon(PhosphorIconsBold.crown, size: 20),
                  label: Text(context.l10n.levelUpUnlockSheetGetPremium),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

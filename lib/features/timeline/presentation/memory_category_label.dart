import 'package:flutter/widgets.dart';

import '../../../core/l10n/build_context_l10n_extension.dart';
import '../domain/memory_model.dart';

/// Localized label for a [MemoryCategory] (the model's `displayName` is English-only).
extension MemoryCategoryLabel on MemoryCategory {
  String label(BuildContext context) {
    final l10n = context.l10n;
    switch (this) {
      case MemoryCategory.dateNight:
        return l10n.memoryCategoryDateNight;
      case MemoryCategory.trip:
        return l10n.memoryCategoryTrip;
      case MemoryCategory.milestone:
        return l10n.memoryCategoryMilestone;
      case MemoryCategory.dailyLife:
        return l10n.memoryCategoryDailyLife;
      case MemoryCategory.food:
        return l10n.memoryCategoryFood;
      case MemoryCategory.party:
        return l10n.memoryCategoryParty;
      case MemoryCategory.funny:
        return l10n.memoryCategoryFunny;
      case MemoryCategory.intimacy:
        return l10n.memoryCategoryIntimacy;
      case MemoryCategory.nature:
        return l10n.memoryCategoryNature;
      case MemoryCategory.other:
        return l10n.memoryCategoryOther;
    }
  }
}

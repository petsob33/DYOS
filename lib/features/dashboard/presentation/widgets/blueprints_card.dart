import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/l10n/build_context_l10n_extension.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/bento_card.dart';
import '../../../../core/widgets/icon_label.dart';

class BlueprintsCard extends StatelessWidget {
  const BlueprintsCard();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return BentoCard(
      onTap: () => context.push('/blueprints'),
      background: c.card,
      child: IconLabel(
            icon: PhosphorIconsBold.clipboardText,
            color: c.primary,
            label: context.l10n.dashCardQuestions,
          )
    );
  }
}

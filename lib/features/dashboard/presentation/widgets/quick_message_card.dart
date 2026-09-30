import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/l10n/build_context_l10n_extension.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/bento_card.dart';
import '../../../../core/widgets/icon_label.dart';
import '../../../auth/presentation/auth_providers.dart';

class QuickMessageCard extends ConsumerWidget {
  const QuickMessageCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coupleAsync = ref.watch(currentCoupleProvider);

    return coupleAsync.when(
      data: (couple) {
        if (couple == null) {
          final c = context.colors;
          return BentoCard(
            background: c.card,
            child: IconLabel(
            icon: PhosphorIconsBold.chatCircle,
            color: c.primary,
            label: context.l10n.dashCardChat,
          )
          );
        }

        final c = context.colors;

        return BentoCard(
          onTap: () => context.push('/chat'),
          background: c.card,
          child: IconLabel(
            icon: PhosphorIconsBold.chatCircle,
            color: c.primary,
            label: context.l10n.dashCardChat,
          )
        );
      },
      loading: () {
        final c = context.colors;
        return BentoCard(
          background: c.card,
          child: IconLabel(
            icon: PhosphorIconsBold.chatCircle,
            color: c.primary,
            label: context.l10n.dashCardChat,
          )
        );
      },
      error: (_, __) {
        final c = context.colors;
        return BentoCard(
          background: c.card,
          child: IconLabel(
            icon: PhosphorIconsBold.chatCircle,
            color: c.primary,
            label: context.l10n.dashCardChat,
          )
        );
      },
    );
  }
}

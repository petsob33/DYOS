import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/l10n/build_context_l10n_extension.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/bento_card.dart';
import '../../../../core/widgets/icon_label.dart';
import '../../../notes/domain/note_item.dart';
import '../../../notes/presentation/notes_provider.dart';

class ListsCard extends ConsumerWidget {
  const ListsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bucketListNotesAsync = ref.watch(
      coupleNotesProvider(type: NoteType.bucketList),
    );

    return bucketListNotesAsync.when(
      data: (notes) {
        final c = context.colors;

        return BentoCard(
          onTap: () {
            context.push('/lists');
          },
          background: c.card,
          child: IconLabel(
            icon: PhosphorIconsBold.listChecks,
            color: c.warning,
            label: context.l10n.dashCardLists,
          )
        );
      },
      loading: () {
        final c = context.colors;
        return BentoCard(
          onTap: () {
            context.push('/lists');
          },
          background: c.card,
          child: IconLabel(
            icon: PhosphorIconsBold.listChecks,
            color: c.warning,
            label: context.l10n.dashCardLists,
          )
        );
      },
      error: (error, stackTrace) {
        final c = context.colors;
        return BentoCard(
          onTap: () {
            context.push('/lists');
          },
          background: c.card,
          child: IconLabel(
            icon: PhosphorIconsBold.listChecks,
            color: c.warning,
            label: context.l10n.dashCardLists,
          )
        );
      },
    );
  }
}

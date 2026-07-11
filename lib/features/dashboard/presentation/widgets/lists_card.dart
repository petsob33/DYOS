import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/bento_card.dart';
import '../../../../models/note_item.dart';
import '../../../../models/notes_provider.dart';

class ListsCard extends ConsumerWidget {
  const ListsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bucketListNotesAsync = ref.watch(
      coupleNotesProvider(type: NoteType.bucketList),
    );

    return bucketListNotesAsync.when(
      data: (notes) {
        final c = AppTheme.colors;

        return BentoCard(
          onTap: () {
            context.push('/lists');
          },
          background: c.card,
          child: Center(
            child: Icon(
              PhosphorIconsBold.listChecks,
              color: c.warning,
              size: 52,
            ),
          ),
        );
      },
      loading: () {
        final c = AppTheme.colors;
        return BentoCard(
          onTap: () {
            context.push('/lists');
          },
          background: c.card,
          child: Center(
            child: Icon(
              PhosphorIconsBold.listChecks,
              color: c.warning,
              size: 52,
            ),
          ),
        );
      },
      error: (error, stackTrace) {
        final c = AppTheme.colors;
        return BentoCard(
          onTap: () {
            context.push('/lists');
          },
          background: c.card,
          child: Center(
            child: Icon(
              PhosphorIconsBold.listChecks,
              color: c.warning,
              size: 52,
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/bento_card.dart';
import '../../core/l10n/build_context_l10n_extension.dart';
import '../notes/domain/note_item.dart';
import '../notes/presentation/notes_provider.dart';

class ListsScreen extends ConsumerWidget {
  const ListsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bucketListNotesAsync = ref.watch(
      coupleNotesProvider(type: NoteType.bucketList),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(context.l10n.listsScreenTitle),
        actions: [
          IconButton(
            icon: Icon(
              PhosphorIconsBold.plus,
              color: context.colors.text,
            ),
            onPressed: () => context.push('/add-note?type=bucketList'),
            tooltip: context.l10n.listsScreenAddNoteTooltip,
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.lg,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.listsScreenBucketListHeading,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: context.colors.text,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      context.l10n.listsScreenBucketListSubheading,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: context.colors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            bucketListNotesAsync.when(
              data: (notes) {
                if (notes.isEmpty) {
                  return SliverPadding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    sliver: SliverToBoxAdapter(
                      child: BentoCard(
                        child: Column(
                          children: [
                            Icon(
                              PhosphorIconsBold.listChecks,
                              size: 48,
                              color: context.colors.textSecondary,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              context.l10n.listsScreenEmptyTitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: context.colors.textSecondary,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              context.l10n.listsScreenEmptySubtitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: context.colors.textSecondary,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final note = notes[index];
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppSpacing.md,
                          ),
                          child: _BucketListItem(note: note),
                        );
                      },
                      childCount: notes.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverPadding(
                padding: EdgeInsets.all(AppSpacing.lg),
                sliver: SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (error, stackTrace) {
                debugPrint('Error loading bucket list: $error');
                return SliverPadding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  sliver: SliverToBoxAdapter(
                    child: BentoCard(
                      child: Column(
                        children: [
                          Icon(
                            PhosphorIconsBold.warning,
                            size: 48,
                            color: context.colors.warning,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            context.l10n.listsScreenErrorTitle,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: context.colors.text,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            error.toString(),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: context.colors.textSecondary,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BucketListItem extends StatelessWidget {
  const _BucketListItem({required this.note});

  final NoteItem note;

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (note.title != null && note.title!.isNotEmpty) ...[
            Text(
              note.title!,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.colors.text,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          Text(
            note.content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.colors.text,
                  height: 1.5,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(
                PhosphorIconsBold.calendar,
                size: 14,
                color: context.colors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                _formatDate(context, note.createdAt),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.colors.textSecondary,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays == 0) return context.l10n.listsScreenToday;
    if (difference.inDays == 1) return context.l10n.listsScreenYesterday;
    if (difference.inDays < 7) return context.l10n.listsScreenDaysAgo(difference.inDays);
    return '${date.day}/${date.month}/${date.year}';
  }
}

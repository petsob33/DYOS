import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/bento_card.dart';
import '../auth/presentation/auth_providers.dart';
import '../../../models/note_item.dart';
import '../../../models/notes_provider.dart';

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
        title: const Text('Lists'),
        actions: [
          IconButton(
            icon: Icon(
              PhosphorIconsBold.plus,
              color: AppTheme.colors.text,
            ),
            onPressed: () => context.push('/add-note?type=bucketList'),
            tooltip: 'Add note',
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
                      'Bucket List',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.colors.text,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Things you want to do together',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.colors.textSecondary,
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
                              color: AppTheme.colors.textSecondary,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'No bucket list items yet',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: AppTheme.colors.textSecondary,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Tap the + button to add your first item',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppTheme.colors.textSecondary,
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
                            color: AppTheme.colors.warning,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Error loading bucket list',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: AppTheme.colors.text,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            error.toString(),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: AppTheme.colors.textSecondary,
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
                    color: AppTheme.colors.text,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          Text(
            note.content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.colors.text,
                  height: 1.5,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(
                PhosphorIconsBold.calendar,
                size: 14,
                color: AppTheme.colors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                _formatDate(note.createdAt),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.colors.textSecondary,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}

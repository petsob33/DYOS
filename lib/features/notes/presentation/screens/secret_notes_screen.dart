import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/bento_card.dart';
import '../../../../models/note_item.dart';
import '../../../../models/notes_provider.dart';

class SecretNotesScreen extends ConsumerWidget {
  const SecretNotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final secretGiftNotesAsync = ref.watch(
      coupleNotesProvider(type: NoteType.secretGift),
    );
    final privateNotesAsync = ref.watch(
      coupleNotesProvider(type: NoteType.private),
    );

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.colors.background,
        appBar: AppBar(
          title: const Text('Secret Notes'),
          bottom: TabBar(
            labelColor: AppTheme.colors.primary,
            unselectedLabelColor: AppTheme.colors.textSecondary,
            indicatorColor: AppTheme.colors.primary,
            tabs: const [
              Tab(text: 'Secret Gift'),
              Tab(text: 'Private'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Secret Gift Tab
            _buildNotesList(
              context: context,
              notesAsync: secretGiftNotesAsync,
              emptyMessage: 'No secret gift ideas yet',
              emptyDescription: 'Tap the + button to add your first secret gift idea',
              emptyIcon: PhosphorIconsBold.gift,
            ),
            // Private Tab
            _buildNotesList(
              context: context,
              notesAsync: privateNotesAsync,
              emptyMessage: 'No private notes yet',
              emptyDescription: 'Tap the + button to add your first private note',
              emptyIcon: PhosphorIconsBold.lock,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesList({
    required BuildContext context,
    required AsyncValue<List<NoteItem>> notesAsync,
    required String emptyMessage,
    required String emptyDescription,
    required IconData emptyIcon,
  }) {
    return SafeArea(
      child: notesAsync.when(
        data: (notes) {
          if (notes.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: BentoCard(
                child: Column(
                  children: [
                    Icon(
                      emptyIcon,
                      size: 48,
                      color: AppTheme.colors.textSecondary,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      emptyMessage,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.colors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      emptyDescription,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.colors.textSecondary,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final note = notes[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _NoteItemCard(note: note),
                      );
                    },
                    childCount: notes.length,
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) {
          debugPrint('Error loading notes: $error');
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
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
                    'Error loading notes',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.colors.text,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    error.toString(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.colors.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NoteItemCard extends StatelessWidget {
  const _NoteItemCard({required this.note});

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

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

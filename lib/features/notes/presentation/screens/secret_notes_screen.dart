import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/l10n/build_context_l10n_extension.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/bento_card.dart';
import '../../domain/note_item.dart';
import '../notes_provider.dart';

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
        backgroundColor: context.colors.background,
        appBar: AppBar(
          title: Text(context.l10n.secretNotesScreenTitle),
          bottom: TabBar(
            labelColor: context.colors.primary,
            unselectedLabelColor: context.colors.textSecondary,
            indicatorColor: context.colors.primary,
            tabs: [
              Tab(text: context.l10n.secretNotesScreenTabSecretGift),
              Tab(text: context.l10n.secretNotesScreenTabPrivate),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Secret Gift Tab
            _buildNotesList(
              context: context,
              notesAsync: secretGiftNotesAsync,
              emptyMessage: context.l10n.secretNotesScreenEmptySecretGiftTitle,
              emptyDescription: context.l10n.secretNotesScreenEmptySecretGiftSubtitle,
              emptyIcon: PhosphorIconsBold.gift,
            ),
            // Private Tab
            _buildNotesList(
              context: context,
              notesAsync: privateNotesAsync,
              emptyMessage: context.l10n.secretNotesScreenEmptyPrivateTitle,
              emptyDescription: context.l10n.secretNotesScreenEmptyPrivateSubtitle,
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
                      color: context.colors.textSecondary,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      emptyMessage,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: context.colors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      emptyDescription,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.colors.textSecondary,
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
                    color: context.colors.warning,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    context.l10n.secretNotesScreenErrorTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: context.colors.text,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    error.toString(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.colors.textSecondary,
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

    if (difference.inDays == 0) {
      return context.l10n.secretNotesScreenToday;
    } else if (difference.inDays == 1) {
      return context.l10n.secretNotesScreenYesterday;
    } else if (difference.inDays < 7) {
      return context.l10n.secretNotesScreenDaysAgo(difference.inDays);
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

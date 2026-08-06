import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/l10n/build_context_l10n_extension.dart';
import '../../../../core/widgets/bento_card.dart';
import '../blueprint_provider.dart';

/// Lists Blueprint (preference questionnaire) categories. Tap to open a section.
class BlueprintsListScreen extends ConsumerWidget {
  const BlueprintsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final sectionsAsync = ref.watch(blueprintSectionsProvider);

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        foregroundColor: c.text,
        elevation: 0,
        title: Text(
          context.l10n.blueprintsListScreenTitle,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: c.text,
          ),
        ),
      ),
      body: SafeArea(
        child: sectionsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text(
              context.l10n.blueprintsListScreenLoadError,
              style: GoogleFonts.inter(color: c.textSecondary),
            ),
          ),
          data: (sections) => CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Text(
                    context.l10n.blueprintsListScreenIntro,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: c.textSecondary,
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final section = sections[index];
                  return Padding(
                    padding: const EdgeInsets.only(
                      left: AppSpacing.lg,
                      right: AppSpacing.lg,
                      bottom: AppSpacing.md,
                    ),
                    child: BentoCard(
                      onTap: () {
                        context.push('/blueprint/${section.id}');
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: c.primary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                section.emoji,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    section.title,
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: c.text,
                                    ),
                                  ),
                                  Text(
                                    context.l10n.blueprintsListScreenQuestionsCount(
                                      section.questions.length,
                                    ),
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: c.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              PhosphorIconsBold.caretRight,
                              color: c.textSecondary,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }, childCount: sections.length),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

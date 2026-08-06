import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/l10n/build_context_l10n_extension.dart';

class QuickNoteCard extends StatelessWidget {
  const QuickNoteCard({
    super.key,
    required this.content,
    this.onTap,
  });

  final String content;
  final VoidCallback? onTap;

  List<String> _placeholderPrompts(BuildContext context) => [
        context.l10n.quickNoteCardPromptWriteSomethingNice,
        context.l10n.quickNoteCardPromptDontForget,
        context.l10n.quickNoteCardPromptDoorCode,
        context.l10n.quickNoteCardPromptSecretPhrase,
      ];

  String _getDisplayText(BuildContext context) {
    if (content.isEmpty) {
      final random = Random();
      final prompts = _placeholderPrompts(context);
      return prompts[random.nextInt(prompts.length)];
    }
    return content;
  }

  Color _getTextColor(BuildContext context) {
    return content.isEmpty
        ? context.colors.textSecondary
        : context.colors.text;
  }

  @override
  Widget build(BuildContext context) {
    final displayText = _getDisplayText(context);
    final textColor = _getTextColor(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(
          minHeight: 150,
        ),
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: context.colors.shadow,
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header: "Sticky Note" label + Pin icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.quickNoteCardHeaderLabel,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: context.colors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                Icon(
                  PhosphorIconsBold.pushPin,
                  size: 16,
                  color: context.colors.primary,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Body: Text content
            Text(
              displayText,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: textColor,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

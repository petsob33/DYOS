import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_theme.dart';

class QuickNoteCard extends StatelessWidget {
  const QuickNoteCard({
    super.key,
    required this.content,
    this.onTap,
  });

  final String content;
  final VoidCallback? onTap;

  static const List<String> _placeholderPrompts = [
    'Write me something nice...',
    'Don\'t forget...',
    'The door code is...',
    'Today\'s secret phrase?',
  ];

  String _getDisplayText() {
    if (content.isEmpty) {
      final random = Random();
      return _placeholderPrompts[random.nextInt(_placeholderPrompts.length)];
    }
    return content;
  }

  Color _getTextColor() {
    return content.isEmpty
        ? AppTheme.colors.textSecondary
        : AppTheme.colors.text;
  }

  @override
  Widget build(BuildContext context) {
    final displayText = _getDisplayText();
    final textColor = _getTextColor();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(
          minHeight: 150,
        ),
        decoration: BoxDecoration(
          color: AppTheme.colors.card,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.colors.shadow,
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
                  'STICKY NOTE',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.colors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                Icon(
                  PhosphorIconsBold.pushPin,
                  size: 16,
                  color: AppTheme.colors.primary,
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

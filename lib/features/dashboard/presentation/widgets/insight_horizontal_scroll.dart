import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/insight_item.dart';
import '../insight_provider.dart';

/// Full-width horizontal scroll strip of insight cards (memories, moments, cycle, events, days together).
class InsightHorizontalScroll extends ConsumerWidget {
  const InsightHorizontalScroll({super.key});

  static const double _cardWidth = 160;
  static const double _stripHeight = 100;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const c = AppTheme.colors;
    final insightsAsync = ref.watch(insightItemsProvider);

    return insightsAsync.when(
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();
        return SizedBox(
          height: _stripHeight + AppSpacing.md * 2,
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(
                  'Insights',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: c.text,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                height: _stripHeight,
                width: double.infinity,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _InsightCard(item: item, width: _cardWidth);
                  },
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.item, required this.width});

  final InsightItem item;
  final double width;

  @override
  Widget build(BuildContext context) {
    const c = AppTheme.colors;
    return Container(
      width: width,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: c.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.icon != null)
            Icon(
              item.icon,
              size: 22,
              color: c.primary,
            ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            item.title,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: c.text,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (item.subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              item.subtitle!,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: c.textSecondary,
                height: 1.25,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

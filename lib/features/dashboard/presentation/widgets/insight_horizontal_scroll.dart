import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/bento_card.dart';
import '../../domain/insight_item.dart';
import '../insight_provider.dart';

/// One full-width Bento widget; one insight at a time, swipe to next/previous, loops.
class InsightHorizontalScroll extends ConsumerStatefulWidget {
  const InsightHorizontalScroll({super.key});

  @override
  ConsumerState<InsightHorizontalScroll> createState() =>
      _InsightHorizontalScrollState();
}

class _InsightHorizontalScrollState extends ConsumerState<InsightHorizontalScroll> {
  PageController? _pageController;
  static const int _loopMultiplier = 128;

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final insightsAsync = ref.watch(insightItemsProvider);

    return insightsAsync.when(
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();
        _pageController ??= PageController(
          initialPage: items.length * (_loopMultiplier ~/ 2),
        );
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: BentoCard(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.lg,
              horizontal: AppSpacing.md,
            ),
            child: SizedBox(
              height: 110,
              width: double.infinity,
              child: PageView.builder(
                controller: _pageController,
                physics: const _SlowerPageScrollPhysics(),
                itemCount: items.length * _loopMultiplier,
                itemBuilder: (context, index) {
                  final item = items[index % items.length];
                  return _InsightSlide(item: item);
                },
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _InsightSlide extends StatelessWidget {
  const _InsightSlide({required this.item});

  final InsightItem item;

  @override
  Widget build(BuildContext context) {
    const c = AppTheme.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Row(
        children: [
          if (item.icon != null) ...[
            Icon(
              item.icon,
              size: 28,
              color: c.primary,
            ),
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle!,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: c.textSecondary,
                      height: 1.25,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Slower page transition: drag follows finger at ~55% speed for a calmer feel.
class _SlowerPageScrollPhysics extends PageScrollPhysics {
  const _SlowerPageScrollPhysics({super.parent});

  static const double _dragFactor = 0.55;

  @override
  _SlowerPageScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _SlowerPageScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    return super.applyPhysicsToUserOffset(position, offset * _dragFactor);
  }
}

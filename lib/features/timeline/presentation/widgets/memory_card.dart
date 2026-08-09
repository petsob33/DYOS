import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/l10n/build_context_l10n_extension.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/memory_model.dart';
import 'memory_detail_dialog.dart';

/// Memory card widget with Apple-style design
class MemoryCard extends StatefulWidget {
  const MemoryCard({super.key, required this.memory});

  final Memory memory;

  @override
  State<MemoryCard> createState() => _MemoryCardState();
}

class _MemoryCardState extends State<MemoryCard> {
  final PageController _pageController = PageController();
  final ValueNotifier<int> _currentPageNotifier = ValueNotifier<int>(0);

  @override
  void dispose() {
    _pageController.dispose();
    _currentPageNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasMultipleImages = widget.memory.mediaUrls.length > 1;
    final hasImages = widget.memory.mediaUrls.isNotEmpty;
    final locationName = widget.memory.location?['name'] as String?;

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Caption (title) with Category Chip, then Date
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.xs,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Caption (title) and Category Chip on same row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Caption (title) - large, on the left
                    if (widget.memory.caption.isNotEmpty)
                      Expanded(
                        child: Text(
                          widget.memory.caption,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: context.colors.text,
                                fontWeight: FontWeight.w600,
                                height: 1.5,
                              ),
                        ),
                      ),
                    // Category Chip - on the right
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: context.colors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.memory.category.emoji,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            widget.memory.category.displayName,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: context.colors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Date - small, right below caption
                Padding(
                  padding: const EdgeInsets.only(
                    top: 2,
                    bottom: AppSpacing.md,
                  ),
                  child: Text(
                    _formatDate(context, widget.memory.date),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: context.colors.textSecondary,
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                  ),
                ),
              ],
            ),
          ),

          // Body: Images
          if (hasImages)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      MemoryDetailDialog.show(
                        context,
                        memory: widget.memory,
                        initialImageIndex: _currentPageNotifier.value,
                      );
                    },
                    child: SizedBox(
                      height: 300,
                      width: double.infinity,
                      child: hasMultipleImages
                          ? PageView.builder(
                              controller: _pageController,
                              onPageChanged: (index) {
                                _currentPageNotifier.value = index;
                              },
                              itemCount: widget.memory.mediaUrls.length,
                              itemBuilder: (context, index) {
                                return _MemoryImage(
                                  imageUrl: widget.memory.mediaUrls[index],
                                );
                              },
                            )
                          : _MemoryImage(
                              imageUrl: widget.memory.mediaUrls.first,
                            ),
                    ),
                  ),
                  // Location badge (if available)
                  if (locationName != null)
                    Positioned(
                      top: AppSpacing.md,
                      right: AppSpacing.md,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.card.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              PhosphorIconsBold.mapPin,
                              size: 14,
                              color: context.colors.primary,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              locationName,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: context.colors.text,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Page indicator dots (only for multiple images)
                  if (hasMultipleImages)
                    Positioned(
                      bottom: AppSpacing.md,
                      left: 0,
                      right: 0,
                      child: ValueListenableBuilder<int>(
                        valueListenable: _currentPageNotifier,
                        builder: (context, currentPage, _) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              widget.memory.mediaUrls.length,
                              (index) => _PageIndicator(
                                isActive: index == currentPage,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            )
          else
            // Placeholder when no images
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: context.colors.textSecondary.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
              ),
              child: Center(
                child: Icon(
                  PhosphorIconsBold.image,
                  size: 48,
                  color: context.colors.textSecondary.withValues(alpha: 0.4),
                ),
              ),
            ),

          // Footer: Location (if not shown as badge and no images)
          if (locationName != null && !hasImages)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Icon(
                    PhosphorIconsBold.mapPin,
                    size: 16,
                    color: context.colors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    locationName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.colors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime date) {
    final localeName = Localizations.localeOf(context).toString();
    return DateFormat('d. MMM', localeName).format(date);
  }
}

/// Individual memory image widget with loading and error states
class _MemoryImage extends StatelessWidget {
  const _MemoryImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: context.colors.textSecondary.withValues(alpha: 0.1),
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: context.colors.primary,
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: context.colors.textSecondary.withValues(alpha: 0.1),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                PhosphorIconsBold.image,
                size: 32,
                color: context.colors.textSecondary.withValues(alpha: 0.4),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                context.l10n.timelineScreenFailedToLoad,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: context.colors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Page indicator dot for PageView
class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? Colors.white
            : Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}

/// Skeleton loader for memory card
class MemoryCardSkeleton extends StatelessWidget {
  const MemoryCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header skeleton
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 16,
                    decoration: BoxDecoration(
                      color: context.colors.textSecondary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Container(
                  width: 80,
                  height: 24,
                  decoration: BoxDecoration(
                    color: context.colors.textSecondary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
          ),
          // Image skeleton
          Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              color: context.colors.textSecondary.withValues(alpha: 0.1),
            ),
          ),
          // Footer skeleton
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: context.colors.textSecondary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  height: 16,
                  width: 200,
                  decoration: BoxDecoration(
                    color: context.colors.textSecondary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

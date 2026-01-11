import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/memory_model.dart';
import '../memory_provider.dart';

/// Timeline screen displaying all memories in chronological order
/// 
/// Features:
/// - Real-time updates via memoriesStreamProvider
/// - Loading skeleton/spinner
/// - Error handling
/// - Grouped by month
/// - Beautiful MemoryCard widgets
class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memoriesAsync = ref.watch(memoriesStreamProvider);

    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      appBar: AppBar(
        title: const Text('Timeline'),
        actions: [
          IconButton(
            icon: const Icon(PhosphorIconsBold.mapPin),
            onPressed: () {
              // TODO: Navigate to map view
            },
            tooltip: 'Map view',
          ),
        ],
      ),
      body: memoriesAsync.when(
        data: (memories) {
          if (memories.isEmpty) {
            return _EmptyState();
          }

          // Group memories by month/year
          final groupedMemories = <String, List<Memory>>{};
          for (final memory in memories) {
            final monthKey = _formatMonthYear(memory.date);
            groupedMemories.putIfAbsent(monthKey, () => []).add(memory);
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: groupedMemories.length,
            itemBuilder: (context, index) {
              final monthKey = groupedMemories.keys.elementAt(index);
              final monthMemories = groupedMemories[monthKey]!;

              return _TimelineMonthSection(
                month: monthKey,
                memories: monthMemories,
              );
            },
          );
        },
        loading: () => const _LoadingState(),
        error: (error, stack) => _ErrorState(error: error.toString()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/add-memory');
        },
        backgroundColor: AppTheme.colors.primary,
        child: const Icon(
          PhosphorIconsBold.plus,
          color: Colors.white,
        ),
      ),
    );
  }

  String _formatMonthYear(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

/// Loading state with skeleton loader
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          child: _MemoryCardSkeleton(),
        );
      },
    );
  }
}

/// Error state
class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIconsBold.warning,
              size: 64,
              color: AppTheme.colors.love,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Error loading memories',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.colors.text,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.colors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state when no memories exist
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIconsBold.images,
              size: 64,
              color: AppTheme.colors.textSecondary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No memories yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.colors.text,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Start creating memories with your partner!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.colors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Month section header with list of memories
class _TimelineMonthSection extends StatelessWidget {
  const _TimelineMonthSection({
    required this.month,
    required this.memories,
  });

  final String month;
  final List<Memory> memories;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Text(
            month,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.colors.text,
                ),
          ),
        ),
        ...memories.map((memory) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: MemoryCard(memory: memory),
            )),
      ],
    );
  }
}

/// Memory card widget with Apple-style design
/// 
/// Features:
/// - Clean, rounded corners (24px)
/// - Header: Date and Category Chip
/// - Body: PageView for multiple images with dots, single image display
/// - Footer: Caption and location
class MemoryCard extends StatefulWidget {
  const MemoryCard({super.key, required this.memory});

  final Memory memory;

  @override
  State<MemoryCard> createState() => _MemoryCardState();
}

class _MemoryCardState extends State<MemoryCard> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasMultipleImages = widget.memory.mediaUrls.length > 1;
    final hasImages = widget.memory.mediaUrls.isNotEmpty;
    final locationName = widget.memory.location?['name'] as String?;

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Date and Category Chip
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                // Date
                Expanded(
                  child: Text(
                    _formatDate(widget.memory.date),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppTheme.colors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
                // Category Chip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.colors.primary.withValues(alpha: 0.12),
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
                              color: AppTheme.colors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                      ),
                    ],
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
                  SizedBox(
                    height: 300,
                    width: double.infinity,
                    child: hasMultipleImages
                        ? PageView.builder(
                            controller: _pageController,
                            onPageChanged: (index) {
                              setState(() {
                                _currentPage = index;
                              });
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
                          color: AppTheme.colors.card.withValues(alpha: 0.95),
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
                              color: AppTheme.colors.primary,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              locationName,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: AppTheme.colors.text,
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          widget.memory.mediaUrls.length,
                          (index) => _PageIndicator(
                            isActive: index == _currentPage,
                          ),
                        ).toList(),
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
                color: AppTheme.colors.textSecondary.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
              ),
              child: Center(
                child: Icon(
                  PhosphorIconsBold.image,
                  size: 48,
                  color: AppTheme.colors.textSecondary.withValues(alpha: 0.4),
                ),
              ),
            ),

          // Footer: Caption and location (if not shown as badge)
          if (widget.memory.caption.isNotEmpty ||
              (locationName != null && !hasImages))
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Caption
                  if (widget.memory.caption.isNotEmpty)
                    Text(
                      widget.memory.caption,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.colors.text,
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                          ),
                    ),
                  // Location in footer (if not shown as badge on image)
                  if (locationName != null && !hasImages) ...[
                    if (widget.memory.caption.isNotEmpty)
                      const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Icon(
                          PhosphorIconsBold.mapPin,
                          size: 16,
                          color: AppTheme.colors.textSecondary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          locationName,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.colors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day}. ${months[date.month - 1]}';
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
        color: AppTheme.colors.textSecondary.withValues(alpha: 0.1),
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppTheme.colors.primary,
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: AppTheme.colors.textSecondary.withValues(alpha: 0.1),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                PhosphorIconsBold.image,
                size: 32,
                color: AppTheme.colors.textSecondary.withValues(alpha: 0.4),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Failed to load',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.colors.textSecondary,
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
class _MemoryCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.colors.card,
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
                      color: AppTheme.colors.textSecondary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Container(
                  width: 80,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppTheme.colors.textSecondary.withValues(alpha: 0.2),
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
              color: AppTheme.colors.textSecondary.withValues(alpha: 0.1),
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
                    color: AppTheme.colors.textSecondary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  height: 16,
                  width: 200,
                  decoration: BoxDecoration(
                    color: AppTheme.colors.textSecondary.withValues(alpha: 0.2),
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

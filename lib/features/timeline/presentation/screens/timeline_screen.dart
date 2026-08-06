import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/l10n/build_context_l10n_extension.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../gamification/domain/progression_plan.dart';
import '../../../gamification/presentation/user_stats_provider.dart';
import '../../../gamification/presentation/widgets/level_up_unlock_sheet.dart';
import '../../../premium/presentation/premium_provider.dart';
import '../../domain/memory_model.dart';
import '../memory_provider.dart';
import '../widgets/memory_detail_dialog.dart';

/// Timeline screen displaying all memories in chronological order
class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    // The unfiltered feed is paginated (see TimelineFeedController); a
    // category filter falls back to the existing unbounded stream, since
    // couples rarely have enough memories in a single category for
    // pagination to matter, and it avoids needing a composite Firestore
    // index for category + date range queries.
    final isFiltered = selectedCategory != null;
    final filteredAsync = isFiltered ? ref.watch(memoriesStreamProvider) : null;
    final feedState = ref.watch(timelineFeedControllerProvider);
    final memories = isFiltered ? (filteredAsync?.valueOrNull ?? const []) : feedState.memories;
    final isLoading = isFiltered && (filteredAsync?.isLoading ?? false);
    final loadError = isFiltered ? filteredAsync?.error : null;
    final memoriesCount = memories.length;
    final currentSp = ref.watch(currentXpProvider);
    final isPremium = ref.watch(isPremiumProvider).valueOrNull ?? false;
    final memoriesUnlocked = ProgressionPlan.isFeatureUnlocked(
      FeatureID.memories,
      currentSp,
      isPremium,
    );
    final mapViewUnlocked = ProgressionPlan.isFeatureUnlocked(
      FeatureID.mapView,
      currentSp,
      isPremium,
    );

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(context.l10n.timelineScreenTitle),
        actions: [
          IconButton(
            icon: const Icon(PhosphorIconsBold.mapTrifold),
            onPressed: () {
              if (mapViewUnlocked) {
                context.push('/memory/map');
              } else {
                showLevelUpUnlockSheet(context, ref, FeatureID.mapView);
              }
            },
            tooltip: context.l10n.timelineScreenMemoriesMapTooltip,
          ),
        ],
      ),
      body: Column(
        children: [
          const _CategoryFilter(),
          if (!isPremium)
            _MemoriesLimitBar(
              currentCount: memoriesCount,
              limit: 30,
            ),
          Expanded(
            child: loadError != null
                ? _ErrorState(error: loadError.toString())
                : isLoading
                    ? const _LoadingState()
                    : memories.isEmpty
                        ? _EmptyState()
                        : _TimelineList(
                            memories: memories,
                            formatMonthYear: (date) => _formatMonthYear(context, date),
                            showLoadMore: !isFiltered && feedState.hasMore,
                            isLoadingMore: feedState.isLoadingMore,
                            onLoadMore: () =>
                                ref.read(timelineFeedControllerProvider.notifier).loadMore(),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (!memoriesUnlocked) {
            showLevelUpUnlockSheet(context, ref, FeatureID.memories);
            return;
          }

          const freeLimit = 30;
          if (!isPremium && memoriesCount >= freeLimit) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.l10n.timelineScreenFreeLimitMessage),
                backgroundColor: context.colors.warning,
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.push('/premium');
            return;
          }

          context.push('/add-memory');
        },
        backgroundColor: context.colors.primary,
        child: const Icon(
          PhosphorIconsBold.plus,
          color: Colors.white,
        ),
      ),
    );
  }

  static String _formatMonthYear(BuildContext context, DateTime date) {
    final localeName = Localizations.localeOf(context).toString();
    return DateFormat.yMMMM(localeName).format(date);
  }
}

/// Groups [memories] by month and renders them, with an optional "load
/// older memories" button/spinner appended at the end.
class _TimelineList extends StatelessWidget {
  const _TimelineList({
    required this.memories,
    required this.formatMonthYear,
    required this.showLoadMore,
    required this.isLoadingMore,
    required this.onLoadMore,
  });

  final List<Memory> memories;
  final String Function(DateTime) formatMonthYear;
  final bool showLoadMore;
  final bool isLoadingMore;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    final groupedMemories = <String, List<Memory>>{};
    for (final memory in memories) {
      final monthKey = formatMonthYear(memory.date);
      groupedMemories.putIfAbsent(monthKey, () => []).add(memory);
    }
    final monthKeys = groupedMemories.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      itemCount: monthKeys.length + (showLoadMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == monthKeys.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Center(
              child: isLoadingMore
                  ? const CircularProgressIndicator()
                  : OutlinedButton(
                      onPressed: onLoadMore,
                      child: Text(context.l10n.timelineScreenLoadOlderMemories),
                    ),
            ),
          );
        }

        final monthKey = monthKeys[index];
        return _TimelineMonthSection(
          month: monthKey,
          memories: groupedMemories[monthKey]!,
        );
      },
    );
  }
}

class _CategoryFilter extends ConsumerWidget {
  const _CategoryFilter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final allCategories = [null, ...MemoryCategory.values];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: Row(
        children: allCategories.map((category) {
          final isSelected = category == selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: ChoiceChip(
              label: Text(category?.displayName ?? context.l10n.timelineScreenAllCategoriesLabel),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  ref.read(selectedCategoryProvider.notifier).state = category;
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _MemoriesLimitBar extends StatelessWidget {
  const _MemoriesLimitBar({
    required this.currentCount,
    required this.limit,
  });

  final int currentCount;
  final int limit;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final progress = (currentCount / limit).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.timelineScreenMemoriesLimitFreeLabel,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: c.text,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppSpacing.xs),
            LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: c.textSecondary.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(c.primary),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              context.l10n.timelineScreenMemoriesLimitSubtitle(currentCount, limit),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: c.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
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
              color: context.colors.love,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              context.l10n.timelineScreenErrorLoadingMemories,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.colors.text,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.colors.textSecondary,
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
              color: context.colors.textSecondary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              context.l10n.timelineScreenNoMemoriesYet,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.colors.text,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              context.l10n.timelineScreenStartCreatingMemories,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.colors.textSecondary,
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
                  color: context.colors.text,
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
                        initialImageIndex: _currentPage,
                      );
                    },
                    child: SizedBox(
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
class _MemoryCardSkeleton extends StatelessWidget {
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

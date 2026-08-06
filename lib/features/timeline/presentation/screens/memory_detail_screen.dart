import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/l10n/build_context_l10n_extension.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/memory_repository.dart';
import '../../domain/memory_model.dart';

/// Full-screen page showing memory details (used when navigating from map or timeline).
class MemoryDetailScreen extends ConsumerStatefulWidget {
  const MemoryDetailScreen({
    super.key,
    required this.memory,
    this.initialImageIndex = 0,
  });

  final Memory memory;
  final int initialImageIndex;

  @override
  ConsumerState<MemoryDetailScreen> createState() => _MemoryDetailScreenState();
}

class _MemoryDetailScreenState extends ConsumerState<MemoryDetailScreen> {
  late PageController _pageController;
  late int _currentPage;
  bool _isDeleting = false;

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(context.l10n.memoryDetailScreenDeleteMemoryTitle),
        content: Text(context.l10n.memoryDetailScreenDeleteMemoryContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.l10n.commonCancel, style: TextStyle(color: context.colors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(context.l10n.commonDelete, style: TextStyle(color: context.colors.love, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    setState(() => _isDeleting = true);
    try {
      final repo = ref.read(memoryRepositoryProvider);
      await repo.deleteMemory(widget.memory);
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.memoryDetailScreenMemoryDeleted),
            backgroundColor: context.colors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDeleting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.memoryDetailScreenFailedToDelete(e.toString())),
            backgroundColor: context.colors.love,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialImageIndex;
    _pageController = PageController(initialPage: widget.initialImageIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasMultipleImages = widget.memory.mediaUrls.length > 1;
    final locationName = widget.memory.location?['name'] as String?;
    final captionOrLocation = widget.memory.caption.isNotEmpty 
        ? widget.memory.caption 
        : locationName ?? '';

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.card,
        elevation: 0,
        leading: IconButton(
          icon: Icon(PhosphorIconsBold.arrowLeft, color: context.colors.text),
          onPressed: () => context.pop(),
          tooltip: context.l10n.memoryDetailScreenBackTooltip,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatFullDate(context, widget.memory.date),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: context.colors.text,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  widget.memory.category == MemoryCategory.trip
                      ? PhosphorIconsBold.airplane
                      : PhosphorIconsBold.circle,
                  size: 14,
                  color: context.colors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  widget.memory.category.displayName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.colors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(PhosphorIconsBold.x, color: context.colors.text),
            onPressed: () => context.pop(),
            tooltip: context.l10n.memoryDetailScreenCloseTooltip,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: context.colors.card,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: context.colors.shadow.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title (caption or location name) - large heading
                  if (captionOrLocation.isNotEmpty) ...[
                    Text(
                      captionOrLocation,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: context.colors.text,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  // Location chip
                  if (locationName != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: context.colors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            PhosphorIconsBold.mapPin,
                            size: 16,
                            color: context.colors.primary,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Flexible(
                            child: Text(
                              locationName,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: context.colors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  // Date and page indicator
                  Row(
                    children: [
                      Icon(
                        PhosphorIconsBold.calendarBlank,
                        size: 14,
                        color: context.colors.textSecondary.withValues(alpha: 0.9),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          _formatDateTime(context, widget.memory.date),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: context.colors.textSecondary,
                              ),
                        ),
                      ),
                      if (widget.memory.mediaUrls.length > 1)
                        Text(
                          context.l10n.memoryDetailScreenPageCounter(
                            _currentPage + 1,
                            widget.memory.mediaUrls.length,
                          ),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: context.colors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Edit and Delete buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isDeleting
                              ? null
                              : () => context.push('/memory/edit', extra: widget.memory),
                          icon: const Icon(PhosphorIconsBold.pencilSimple, size: 18),
                          label: Text(context.l10n.commonEdit),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: context.colors.primary,
                            side: BorderSide(color: context.colors.primary.withValues(alpha: 0.5)),
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isDeleting ? null : _confirmDelete,
                          icon: _isDeleting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(PhosphorIconsBold.trash, size: 18),
                          label: Text(
                            _isDeleting
                                ? context.l10n.memoryDetailScreenDeletingLabel
                                : context.l10n.commonDelete,
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: context.colors.love,
                            side: BorderSide(color: context.colors.love.withValues(alpha: 0.5)),
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(AppSpacing.lg),
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      if (widget.memory.mediaUrls.isNotEmpty)
                        PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() => _currentPage = index);
                          },
                          itemCount: widget.memory.mediaUrls.length,
                          itemBuilder: (context, index) {
                            return InteractiveViewer(
                              minScale: 0.5,
                              maxScale: 3.0,
                              child: Center(
                                child: CachedNetworkImage(
                                  imageUrl: widget.memory.mediaUrls[index],
                                  fit: BoxFit.contain,
                                  placeholder: (context, url) => Container(
                                    color: context.colors.background,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: context.colors.primary,
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    color: context.colors.background,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            PhosphorIconsBold.image,
                                            size: 48,
                                            color: context.colors.textSecondary
                                                .withValues(alpha: 0.4),
                                          ),
                                          const SizedBox(height: AppSpacing.sm),
                                          Text(
                                            context.l10n.memoryDetailScreenFailedToLoadImage,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: context.colors.textSecondary,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      else
                        Center(
                          child: Icon(
                            PhosphorIconsBold.image,
                            size: 64,
                            color: context.colors.textSecondary
                                .withValues(alpha: 0.4),
                          ),
                        ),
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
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatFullDate(BuildContext context, DateTime date) {
    final localeName = Localizations.localeOf(context).toString();
    return DateFormat.yMMMMEEEEd(localeName).format(date);
  }

  String _formatDateTime(BuildContext context, DateTime date) {
    final localeName = Localizations.localeOf(context).toString();
    final datePart = DateFormat('d MMM y', localeName).format(date);
    final timePart = DateFormat.Hm(localeName).format(date);
    return context.l10n.memoryDetailScreenDateAtTime(datePart, timePart);
  }
}

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
            ? context.colors.primary
            : context.colors.textSecondary.withValues(alpha: 0.5),
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

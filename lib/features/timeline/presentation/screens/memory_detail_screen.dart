import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/constants/app_spacing.dart';
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
        title: const Text('Delete memory?'),
        content: const Text(
          'This memory will be removed. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel', style: TextStyle(color: AppTheme.colors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Delete', style: TextStyle(color: AppTheme.colors.love, fontWeight: FontWeight.w600)),
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
            content: const Text('Memory deleted'),
            backgroundColor: AppTheme.colors.success,
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
            content: Text('Failed to delete: ${e.toString()}'),
            backgroundColor: AppTheme.colors.love,
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

    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      appBar: AppBar(
        backgroundColor: AppTheme.colors.card,
        elevation: 0,
        leading: IconButton(
          icon: Icon(PhosphorIconsBold.arrowLeft, color: AppTheme.colors.text),
          onPressed: () => context.pop(),
          tooltip: 'Back',
        ),
        title: Text(
          _formatFullDate(widget.memory.date),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.colors.text,
                fontWeight: FontWeight.w700,
              ),
        ),
        actions: [
          IconButton(
            icon: Icon(PhosphorIconsBold.pencilSimple, color: AppTheme.colors.primary),
            onPressed: _isDeleting ? null : () => context.push('/memory/edit', extra: widget.memory),
            tooltip: 'Edit',
          ),
          IconButton(
            icon: _isDeleting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(PhosphorIconsBold.trash, color: AppTheme.colors.love),
            onPressed: _isDeleting ? null : _confirmDelete,
            tooltip: 'Delete',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(36),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Row(
                children: [
                  Text(
                    widget.memory.category.emoji,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    widget.memory.category.displayName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.colors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(AppSpacing.lg),
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
                                    color: AppTheme.colors.background,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppTheme.colors.primary,
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    color: AppTheme.colors.background,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            PhosphorIconsBold.image,
                                            size: 48,
                                            color: AppTheme.colors.textSecondary
                                                .withValues(alpha: 0.4),
                                          ),
                                          const SizedBox(height: AppSpacing.sm),
                                          Text(
                                            'Failed to load image',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: AppTheme.colors.textSecondary,
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
                            color: AppTheme.colors.textSecondary
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
            Container(
              margin: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppTheme.colors.card,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.colors.shadow.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.memory.caption.isNotEmpty) ...[
                    Text(
                      widget.memory.caption,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.colors.text,
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  if (locationName != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.colors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            PhosphorIconsBold.mapPin,
                            size: 16,
                            color: AppTheme.colors.primary,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Flexible(
                            child: Text(
                              locationName,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppTheme.colors.primary,
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
                  Row(
                    children: [
                      Icon(
                        PhosphorIconsBold.calendarBlank,
                        size: 14,
                        color: AppTheme.colors.textSecondary.withValues(alpha: 0.9),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          _formatDateTime(widget.memory.date),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.colors.textSecondary,
                              ),
                        ),
                      ),
                      if (widget.memory.mediaUrls.length > 1)
                        Text(
                          '${_currentPage + 1} / ${widget.memory.mediaUrls.length}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: AppTheme.colors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatFullDate(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatDateTime(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
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
            ? AppTheme.colors.primary
            : AppTheme.colors.textSecondary.withValues(alpha: 0.5),
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

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

class MemoryDetailDialog extends ConsumerStatefulWidget {
  const MemoryDetailDialog({
    super.key,
    required this.memory,
    this.initialImageIndex = 0,
  });

  final Memory memory;
  final int initialImageIndex;

  static Future<void> show(
    BuildContext context, {
    required Memory memory,
    int initialImageIndex = 0,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true, // Důležité: Kliknutí mimo zavře dialog
      barrierColor: context.colors.shadow.withValues(alpha: 0.5),
      builder: (context) => MemoryDetailDialog(
        memory: memory,
        initialImageIndex: initialImageIndex,
      ),
    );
  }

  @override
  ConsumerState<MemoryDetailDialog> createState() => _MemoryDetailDialogState();
}

class _MemoryDetailDialogState extends ConsumerState<MemoryDetailDialog> {
  bool _isDeleting = false;
  late PageController _pageController;
  late int _currentPage;

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(context.l10n.memoryDetailDialogDeleteMemoryTitle),
        content: Text(context.l10n.memoryDetailDialogDeleteMemoryContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.l10n.commonCancel,
                style: TextStyle(color: context.colors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(context.l10n.commonDelete,
                style: TextStyle(
                    color: context.colors.love, fontWeight: FontWeight.w600)),
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
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.memoryDetailDialogMemoryDeleted),
            backgroundColor: context.colors.success,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDeleting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.memoryDetailDialogFailedToDelete(e.toString())),
            backgroundColor: context.colors.love,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

    return Dialog(
      backgroundColor: Colors.transparent, 
      insetPadding: const EdgeInsets.all(AppSpacing.md),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
          maxWidth: 400,
        ),
        decoration: BoxDecoration(
          color: context.colors.card, 
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: context.colors.shadow.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- 1. ČÁST: FOTKY ---
              Flexible(
                flex: 3,
                child: Stack(
                  children: [
                    if (widget.memory.mediaUrls.isNotEmpty)
                      Container(
                        color: Colors.black,
                        height: 400,
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                            });
                          },
                          itemCount: widget.memory.mediaUrls.length,
                          itemBuilder: (context, index) {
                            return CachedNetworkImage(
                              imageUrl: widget.memory.mediaUrls[index],
                              fit: BoxFit.cover,
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
                                child: const Center(
                                  child: Icon(
                                    PhosphorIconsBold.image,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    else
                      Container(
                        height: 200,
                        color: context.colors.background,
                        child: Center(
                          child: Text(
                            context.l10n.memoryDetailDialogNoPhotos,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: context.colors.textSecondary,
                                ),
                          ),
                        ),
                      ),
                      
                    // Tlačítko Zavřít (X)
                    Positioned(
                      top: AppSpacing.sm,
                      right: AppSpacing.sm,
                      child: IconButton(
                        icon: const Icon(
                          PhosphorIconsBold.x,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black.withValues(alpha: 0.4),
                          padding: const EdgeInsets.all(8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),

                    // Indikátor stránek (Tečky)
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

              // --- 2. ČÁST: INFO (Bílý obdélník dole) ---
              Flexible(
                flex: 2,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Titulek a Ozubené kolo
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                widget.memory.caption.isNotEmpty
                                    ? widget.memory.caption
                                    : locationName ?? context.l10n.memoryDetailDialogMemoryFallback,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      // Oprava: Použití standardní černé/šedé místo textPrimary
                                      color: Colors.black87, 
                                    ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                PhosphorIconsBold.gear,
                                size: 24,
                                color: context.colors.textSecondary,
                              ),
                              onPressed: _isDeleting
                                  ? null
                                  : () {
                                showModalBottomSheet(
                                  context: context,
                                  backgroundColor: Colors.transparent,
                                  builder: (ctx) => Container(
                                    padding: const EdgeInsets.all(AppSpacing.lg),
                                    decoration: BoxDecoration(
                                      color: context.colors.card,
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(24),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          leading: Icon(
                                            PhosphorIconsBold.pencilSimple,
                                            color: context.colors.primary,
                                          ),
                                          title: Text(context.l10n.commonEdit),
                                          onTap: () {
                                            Navigator.of(ctx).pop();
                                            Navigator.of(context).pop();
                                            context.push('/memory/edit',
                                                extra: widget.memory);
                                          },
                                        ),
                                        ListTile(
                                          leading: Icon(
                                            PhosphorIconsBold.trash,
                                            color: context.colors.love,
                                          ),
                                          title: Text(
                                            context.l10n.commonDelete,
                                            style: TextStyle(
                                              color: context.colors.love,
                                            ),
                                          ),
                                          onTap: () {
                                            Navigator.of(ctx).pop();
                                            _confirmDelete();
                                          },
                                        ),
                                        SizedBox(
                                            height: MediaQuery.of(context)
                                                .padding
                                                .bottom),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              style: IconButton.styleFrom(
                                backgroundColor: context.colors.background,
                                padding: const EdgeInsets.all(8),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: AppSpacing.md),
                        
                        // Datum
                        Row(
                          children: [
                            Icon(
                              PhosphorIconsBold.calendarBlank,
                              size: 16,
                              color: context.colors.textSecondary,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              _formatDateTime(context, widget.memory.date),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: context.colors.textSecondary,
                                  ),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.md),

                        // Tagy
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: [
                            if (locationName != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: 8,
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
                                      size: 14,
                                      color: context.colors.primary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      locationName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: context.colors.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            // Kategorie
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: context.colors.background,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  // Oprava: Použití standardní šedé místo context.colors.border
                                  color: Colors.black12, 
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    widget.memory.category.emoji,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    widget.memory.category.displayName,
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
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
            ),
            if (_isDeleting)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.35),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(BuildContext context, DateTime date) {
    final localeName = Localizations.localeOf(context).toString();
    final datePart = DateFormat('d MMM y', localeName).format(date);
    final timePart = DateFormat.Hm(localeName).format(date);
    return context.l10n.memoryDetailDialogDateAtTime(datePart, timePart);
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
      width: isActive ? 20 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: isActive
            ? Colors.white
            : Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }
}
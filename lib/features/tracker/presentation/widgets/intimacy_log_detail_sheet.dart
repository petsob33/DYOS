import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/bento_card.dart';
import '../../../auth/presentation/auth_providers.dart';
import '../../data/intimacy_repository.dart';
import '../../domain/intimacy_log_model.dart';
import 'add_intimacy_sheet.dart';

/// Modal bottom sheet for viewing intimacy log details
/// 
/// Features:
/// - Display all log details (date, rating, tags, orgasms, duration, location, note)
/// - Edit button to modify the log
class IntimacyLogDetailSheet extends ConsumerWidget {
  const IntimacyLogDetailSheet({
    super.key,
    required this.log,
    this.currentUserPhotoUrl,
    this.partnerPhotoUrl,
  });

  final IntimacyLog log;
  final String? currentUserPhotoUrl;
  final String? partnerPhotoUrl;

  /// Show the detail sheet
  static Future<void> show(
    BuildContext context, {
    required IntimacyLog log,
    String? currentUserPhotoUrl,
    String? partnerPhotoUrl,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) => IntimacyLogDetailSheet(
        log: log,
        currentUserPhotoUrl: currentUserPhotoUrl,
        partnerPhotoUrl: partnerPhotoUrl,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(userProvider);
    final currentUserDataAsync = ref.watch(currentUserDataProvider);
    final partnerAsync = ref.watch(partnerProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: AppTheme.colors.background,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: AppSpacing.sm),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.colors.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Text(
                    'Intimacy Log Details',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.colors.text,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(PhosphorIconsBold.x),
                    color: AppTheme.colors.textSecondary,
                  ),
                ],
              ),
            ),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date & Time
                    _DetailSection(
                      icon: PhosphorIconsBold.calendar,
                      title: 'Date & Time',
                      child: Text(
                        _formatDateTime(log.date),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppTheme.colors.text,
                            ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Rating
                    _DetailSection(
                      icon: PhosphorIconsBold.fire,
                      title: 'Rating',
                      child: Row(
                        children: List.generate(5, (index) {
                          final value = index + 1;
                          final isFilled = value <= log.rating;
                          return Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Icon(
                              PhosphorIconsBold.fire,
                              size: 24,
                              color: isFilled
                                  ? AppTheme.colors.love
                                  : AppTheme.colors.textSecondary.withValues(alpha: 0.3),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Initiator
                    currentUserDataAsync.when(
                      data: (currentUserData) => partnerAsync.when(
                        data: (partnerData) {
                          final isCurrentUser = log.initiatorId == currentUserAsync.valueOrNull?.uid;
                          final initiatorName = isCurrentUser
                              ? (currentUserData?.displayName ?? 'Me')
                              : (partnerData?.displayName ?? 'Partner');
                          final initiatorPhotoUrl = isCurrentUser
                              ? currentUserPhotoUrl
                              : partnerPhotoUrl;

                          return _DetailSection(
                            icon: PhosphorIconsBold.user,
                            title: 'Initiator',
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: AppTheme.colors.primary.withValues(alpha: 0.12),
                                  backgroundImage: initiatorPhotoUrl != null && initiatorPhotoUrl.isNotEmpty
                                      ? CachedNetworkImageProvider(initiatorPhotoUrl)
                                      : null,
                                  child: initiatorPhotoUrl == null || initiatorPhotoUrl.isEmpty
                                      ? Icon(
                                          PhosphorIconsBold.user,
                                          size: 16,
                                          color: AppTheme.colors.primary,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  initiatorName,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: AppTheme.colors.text,
                                      ),
                                ),
                              ],
                            ),
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, _) => const SizedBox.shrink(),
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, _) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Tags
                    if (log.tags.isNotEmpty)
                      _DetailSection(
                        icon: PhosphorIconsBold.tag,
                        title: 'Tags',
                        child: Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: log.tags.map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.colors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                tag,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.colors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    if (log.tags.isNotEmpty) const SizedBox(height: AppSpacing.md),

                    // Protection
                    _DetailSection(
                      icon: PhosphorIconsBold.shieldCheck,
                      title: 'Protection',
                      child: Row(
                        children: [
                          Icon(
                            log.protectionUsed
                                ? PhosphorIconsBold.checkCircle
                                : PhosphorIconsBold.xCircle,
                            size: 20,
                            color: log.protectionUsed
                                ? AppTheme.colors.success
                                : AppTheme.colors.textSecondary,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            log.protectionUsed ? 'Used' : 'Not used',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: AppTheme.colors.text,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Orgasms
                    if (log.userOrgasmCount > 0 || log.partnerOrgasmCount > 0)
                      currentUserDataAsync.when(
                        data: (currentUserData) => partnerAsync.when(
                          data: (partnerData) {
                            final meName = currentUserData?.displayName ?? 'Me';
                            final partnerName = partnerData?.displayName ?? 'Partner';

                            return _DetailSection(
                              icon: PhosphorIconsBold.sparkle,
                              title: 'Orgasms',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '$meName: ',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: AppTheme.colors.textSecondary,
                                            ),
                                      ),
                                      Text(
                                        '${log.userOrgasmCount}',
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                              color: AppTheme.colors.text,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Row(
                                    children: [
                                      Text(
                                        '$partnerName: ',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: AppTheme.colors.textSecondary,
                                            ),
                                      ),
                                      Text(
                                        '${log.partnerOrgasmCount}',
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                              color: AppTheme.colors.text,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    if (log.userOrgasmCount > 0 || log.partnerOrgasmCount > 0)
                      const SizedBox(height: AppSpacing.md),

                    // Duration
                    if (log.duration != null)
                      _DetailSection(
                        icon: PhosphorIconsBold.clock,
                        title: 'Duration',
                        child: Text(
                          '${log.duration} minutes',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppTheme.colors.text,
                              ),
                        ),
                      ),
                    if (log.duration != null) const SizedBox(height: AppSpacing.md),

                    // Location
                    if (log.location != null && log.location!.isNotEmpty)
                      _DetailSection(
                        icon: PhosphorIconsBold.mapPin,
                        title: 'Location',
                        child: Text(
                          log.location!,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppTheme.colors.text,
                              ),
                        ),
                      ),
                    if (log.location != null && log.location!.isNotEmpty)
                      const SizedBox(height: AppSpacing.md),

                    // Note
                    if (log.note != null && log.note!.isNotEmpty)
                      _DetailSection(
                        icon: PhosphorIconsBold.note,
                        title: 'Note',
                        child: Text(
                          log.note!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.colors.text,
                              ),
                        ),
                      ),
                    if (log.note != null && log.note!.isNotEmpty)
                      const SizedBox(height: AppSpacing.lg),

                    // Edit / delete actions
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _confirmAndDelete(context, ref),
                            icon: const Icon(PhosphorIconsBold.trash),
                            label: const Text('Delete'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.colors.love,
                              side: BorderSide(color: AppTheme.colors.love),
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.md,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              AddIntimacySheet.show(context, logToEdit: log);
                            },
                            icon: const Icon(PhosphorIconsBold.pencil),
                            label: const Text('Edit'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.colors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.md,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime date) {
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
    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    final weekday = weekdays[date.weekday - 1];
    final month = months[date.month - 1];
    final day = date.day;
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$weekday, $month $day, $year at $hour:$minute';
  }

  Future<void> _confirmAndDelete(BuildContext context, WidgetRef ref) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete intimacy log?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              'Delete',
              style: TextStyle(color: AppTheme.colors.love),
            ),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    try {
      final user = ref.read(userProvider).valueOrNull;
      final coupleId = user?.coupleId;
      if (coupleId == null || coupleId.isEmpty) {
        throw Exception('User is not paired.');
      }

      await ref.read(intimacyRepositoryProvider).deleteLog(log.id, coupleId);
      if (!context.mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Intimacy log deleted')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete log: ${e.toString()}')),
      );
    }
  }
}

/// Detail section widget
class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: AppTheme.colors.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.colors.text,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }
}

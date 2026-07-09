import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/bento_card.dart';
import '../../../auth/presentation/auth_providers.dart';
import '../../../auth/domain/couple_model.dart';
import '../../../auth/domain/user_model.dart';
import '../../../../core/services/firebase_service.dart';
import 'package:flutter/services.dart';

class StatusHeader extends StatelessWidget {
  const StatusHeader({
    required this.coupleAsync,
    required this.partnerAsync,
    required this.currentUserAsync,
  });

  final AsyncValue<CoupleModel?> coupleAsync;
  final AsyncValue<UserModel?> partnerAsync;
  final AsyncValue<UserModel?> currentUserAsync;

  @override
  Widget build(BuildContext context) {
    return coupleAsync.when(
      data: (couple) {
        if (couple == null) {
          // Not paired yet - show placeholder
          return BentoCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Center(
              child: Text(
                'Pair with your partner to view status',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        // Get current user and partner data
        return currentUserAsync.when(
          data: (currentUser) {
            final currentUserId = currentUser?.uid ?? '';

            // Get current user's status from couple document
            final currentUserStatus =
                (currentUserId.isNotEmpty && couple.status != null)
                ? couple.status![currentUserId]
                : null;

            // Get partner's status
            return partnerAsync.when(
              data: (partner) {
                final partnerStatus =
                    (partner != null &&
                        partner.uid.isNotEmpty &&
                        couple.status != null)
                    ? couple.status![partner.uid]
                    : null;

                return BentoCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      Expanded(
                        child: AvatarStatus(
                          name: currentUser?.displayName ?? 'You',
                          emoji: currentUserStatus?.emoji ?? '😊',
                          status: currentUserStatus?.text ?? 'Ready',
                          photoUrl: currentUser?.photoUrl,
                          userId: currentUserId,
                          coupleId: couple.id,
                          isEditable: true,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        width: 1,
                        height: 40,
                        color: AppTheme.colors.textSecondary.withValues(
                          alpha: 0.1,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: AvatarStatus(
                          name: partner?.displayName ?? 'Partner',
                          emoji: partnerStatus?.emoji ?? '😊',
                          status: partnerStatus?.text ?? 'Ready',
                          photoUrl: partner?.photoUrl,
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => BentoCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Expanded(
                      child: AvatarStatus(
                        name: currentUser?.displayName ?? 'You',
                        emoji: currentUserStatus?.emoji ?? '😊',
                        status: currentUserStatus?.text ?? 'Ready',
                        userId: currentUserId,
                        coupleId: couple.id,
                        isEditable: true,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppTheme.colors.textSecondary.withValues(
                        alpha: 0.1,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const Expanded(
                      child: AvatarStatus(
                        name: 'Partner',
                        emoji: '😊',
                        status: 'Loading...',
                      ),
                    ),
                  ],
                ),
              ),
              error: (error, stackTrace) {
                return BentoCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      Expanded(
                        child: AvatarStatus(
                          name: currentUser?.displayName ?? 'You',
                          emoji: currentUserStatus?.emoji ?? '😊',
                          status: currentUserStatus?.text ?? 'Ready',
                          userId: currentUserId,
                          coupleId: couple.id,
                          isEditable: true,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        width: 1,
                        height: 40,
                        color: AppTheme.colors.textSecondary.withValues(
                          alpha: 0.1,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      const Expanded(
                        child: AvatarStatus(
                          name: 'Partner',
                          emoji: '😊',
                          status: 'Error',
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          loading: () => BentoCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: const Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => BentoCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: const AvatarStatus(
              name: 'You',
              emoji: '😊',
              status: 'Error',
            ),
          ),
        );
      },
      loading: () => BentoCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => BentoCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: const AvatarStatus(name: 'You', emoji: '😊', status: 'Ready'),
      ),
    );
  }
}

class AvatarStatus extends ConsumerWidget {
  const AvatarStatus({
    required this.name,
    required this.emoji,
    required this.status,
    this.photoUrl,
    this.userId,
    this.coupleId,
    this.isEditable = false,
  });

  final String name;
  final String emoji;
  final String status;
  final String? photoUrl;
  final String? userId;
  final String? coupleId;
  final bool isEditable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: isEditable ? () => _showStatusEditDialog(context, ref) : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppTheme.colors.background,
            backgroundImage: photoUrl != null && photoUrl!.isNotEmpty
                ? CachedNetworkImageProvider(photoUrl!)
                : null,
            child: photoUrl == null || photoUrl!.isEmpty
                ? Text(emoji, style: const TextStyle(fontSize: 20))
                : null,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.colors.text,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        status,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.colors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    if (isEditable)
                      Icon(
                        PhosphorIconsBold.pencilSimple,
                        size: 12,
                        color: AppTheme.colors.textSecondary.withValues(
                          alpha: 0.5,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static const List<String> _statusEmojiPicker = [
    '😊',
    '🤗',
    '❤️',
    '😴',
    '🔋',
    '🤯',
    '💼',
    '🏃',
    '🍷',
    '📚',
    '🎉',
    '😢',
    '☀️',
    '🌙',
    '💪',
    '🧘',
    '✈️',
    '🍳',
    '🎵',
    '💭',
  ];

  Future<void> _showStatusEditDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    if (userId == null || coupleId == null) return;

    final currentEmoji = emoji;
    final currentText = status;

    final textController = TextEditingController(text: currentText);
    String selectedEmoji = _statusEmojiPicker.contains(currentEmoji)
        ? currentEmoji
        : (currentEmoji.isNotEmpty ? currentEmoji : _statusEmojiPicker.first);

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Text(
              'Update Status',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.colors.text,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose emoji',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppTheme.colors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: _statusEmojiPicker.map((e) {
                      final isSelected = selectedEmoji == e;
                      return GestureDetector(
                        onTap: () => setState(() => selectedEmoji = e),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.colors.primary.withValues(
                                    alpha: 0.15,
                                  )
                                : AppTheme.colors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.colors.primary
                                  : AppTheme.colors.textSecondary.withValues(
                                      alpha: 0.2,
                                    ),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(e, style: const TextStyle(fontSize: 24)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: textController,
                    decoration: InputDecoration(
                      labelText: 'Status',
                      hintText: 'Ready',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    maxLength: 30,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: AppTheme.colors.textSecondary),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop({
                    'emoji': selectedEmoji,
                    'text': textController.text.trim().isNotEmpty
                        ? textController.text.trim()
                        : 'Ready',
                  });
                },
                child: Text(
                  'Save',
                  style: TextStyle(
                    color: AppTheme.colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    if (result != null) {
      try {
        final firebaseService = ref.read(firebaseServiceProvider);
        await firebaseService.updateStatus(
          coupleId: coupleId!,
          userId: userId!,
          emoji: result['emoji']!,
          text: result['text']!,
        );
        // Invalidate couple data so UI refreshes immediately with new status
        ref.invalidate(currentCoupleProvider);
        // Show success feedback
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Status updated'),
              backgroundColor: AppTheme.colors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating status: $e'),
              backgroundColor: AppTheme.colors.love,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    }
  }
}

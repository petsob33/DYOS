import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/bento_card.dart';
import '../../../auth/presentation/auth_providers.dart';
import '../../../../core/services/firebase_service.dart';
import 'package:flutter/services.dart';
import '../../../gamification/presentation/user_stats_provider.dart';
import '../../../gamification/domain/progression_plan.dart';
import '../../../gamification/presentation/widgets/level_up_unlock_sheet.dart';
import '../../../premium/presentation/premium_provider.dart';

class QuickMessageCard extends ConsumerWidget {
  const QuickMessageCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coupleAsync = ref.watch(currentCoupleProvider);
    final currentUserAsync = ref.watch(currentUserDataProvider);

    return coupleAsync.when(
      data: (couple) {
        if (couple == null) {
          final c = AppTheme.colors;
          return BentoCard(
            background: c.card,
            child: Center(
              child: Icon(
                PhosphorIconsBold.chatCircle,
                color: c.primary,
                size: 52,
              ),
            ),
          );
        }

        final currentUserId = currentUserAsync.valueOrNull?.uid ?? '';
        final currentSp = ref.watch(currentXpProvider);
        final isPremium = ref.watch(isPremiumProvider).valueOrNull ?? false;
        final quickMessagesUnlocked = ProgressionPlan.isFeatureUnlocked(
          FeatureID.quickMessages,
          currentSp,
          isPremium,
        );

        final c = AppTheme.colors;

        return BentoCard(
          onTap: () {
            if (quickMessagesUnlocked) {
              _showQuickMessageDialog(context, ref, couple.id, currentUserId);
            } else {
              showLevelUpUnlockSheet(context, ref, FeatureID.quickMessages);
            }
          },
          background: c.card,
          child: Center(
            child: Icon(
              PhosphorIconsBold.chatCircle,
              color: c.primary,
              size: 44,
            ),
          ),
        );
      },
      loading: () {
        final c = AppTheme.colors;
        return BentoCard(
          background: c.card,
          child: Center(
            child: Icon(
              PhosphorIconsBold.chatCircle,
              color: c.primary,
              size: 52,
            ),
          ),
        );
      },
      error: (_, __) {
        final c = AppTheme.colors;
        return BentoCard(
          background: c.card,
          child: Center(
            child: Icon(
              PhosphorIconsBold.chatCircle,
              color: c.primary,
              size: 52,
            ),
          ),
        );
      },
    );
  }

  Future<void> _showQuickMessageDialog(
    BuildContext context,
    WidgetRef ref,
    String coupleId,
    String userId,
  ) async {
    final messageController = TextEditingController();

    // Predefined quick messages
    final quickMessages = [
      'Thinking of you 💭',
      'Miss you ❤️',
      'Love you 😘',
      'See you soon 👋',
      'Good morning ☀️',
      'Good night 🌙',
      'How are you? 😊',
    ];

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Quick Message',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppTheme.colors.text,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose a quick message or write your own:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: quickMessages.map((msg) {
                return ActionChip(
                  label: Text(msg),
                  onPressed: () {
                    messageController.text = msg;
                  },
                  backgroundColor: AppTheme.colors.background,
                  side: BorderSide(
                    color: AppTheme.colors.textSecondary.withValues(alpha: 0.2),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: messageController,
              decoration: InputDecoration(
                labelText: 'Your message',
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLength: 100,
              maxLines: 2,
            ),
          ],
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
            onPressed: () async {
              final message = messageController.text.trim();
              if (message.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Please enter a message'),
                    backgroundColor: AppTheme.colors.warning,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
                return;
              }

              Navigator.of(context).pop();

              try {
                final firebaseService = ref.read(firebaseServiceProvider);
                await firebaseService.sendQuickMessage(
                  coupleId: coupleId,
                  fromUserId: userId,
                  message: message,
                );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Message sent!'),
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
                      content: Text('Error sending message: $e'),
                      backgroundColor: AppTheme.colors.love,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }
              }
            },
            child: Text(
              'Send',
              style: TextStyle(
                color: AppTheme.colors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

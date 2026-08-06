import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/l10n/build_context_l10n_extension.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../auth/presentation/auth_providers.dart';
import '../../domain/chat_event.dart';
import '../chat_history_provider.dart';

/// Predefined quick-message shortcuts shown above the composer.
List<String> _quickMessageShortcuts(BuildContext context) => [
      context.l10n.chatScreenShortcutThinkingOfYou,
      context.l10n.chatScreenShortcutMissYou,
      context.l10n.chatScreenShortcutLoveYou,
      context.l10n.chatScreenShortcutSeeYouSoon,
      context.l10n.chatScreenShortcutGoodMorning,
      context.l10n.chatScreenShortcutGoodNight,
      context.l10n.chatScreenShortcutHowAreYou,
    ];

/// A persistent chat thread showing every quick message and haptic touch
/// exchanged with your partner, with a composer to send new ones.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String coupleId, String userId, String message) async {
    if (message.trim().isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await ref.read(firebaseServiceProvider).sendQuickMessage(
            coupleId: coupleId,
            fromUserId: userId,
            message: message.trim(),
          );
      _messageController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.chatScreenSendMessageError(e.toString())),
            backgroundColor: context.colors.love,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _sendTouch(String coupleId, String userId) async {
    try {
      await ref.read(firebaseServiceProvider).sendHapticTouch(
            coupleId: coupleId,
            fromUserId: userId,
            durationMs: 200,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.chatScreenSendTouchError(e.toString())),
            backgroundColor: context.colors.love,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final coupleAsync = ref.watch(currentCoupleProvider);
    final currentUserAsync = ref.watch(currentUserDataProvider);
    final partnerAsync = ref.watch(partnerProvider);

    final couple = coupleAsync.valueOrNull;
    final userId = currentUserAsync.valueOrNull?.uid ?? '';
    final partnerName =
        partnerAsync.valueOrNull?.displayName ?? context.l10n.chatScreenPartnerFallback;

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(title: Text(partnerName)),
      body: couple == null
          ? Center(
              child: Text(
                context.l10n.chatScreenPairPrompt,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: c.textSecondary,
                    ),
              ),
            )
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: _ChatHistoryList(
                      coupleId: couple.id,
                      currentUserId: userId,
                    ),
                  ),
                  _Composer(
                    controller: _messageController,
                    sending: _sending,
                    onSendMessage: (text) => _sendMessage(couple.id, userId, text),
                    onSendTouch: () => _sendTouch(couple.id, userId),
                  ),
                ],
              ),
            ),
    );
  }
}

class _ChatHistoryList extends ConsumerWidget {
  const _ChatHistoryList({required this.coupleId, required this.currentUserId});

  final String coupleId;
  final String currentUserId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final historyAsync = ref.watch(chatHistoryProvider(coupleId));

    return historyAsync.when(
      data: (events) {
        if (events.isEmpty) {
          return Center(
            child: Text(
              context.l10n.chatScreenEmptyState,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: c.textSecondary,
                  ),
            ),
          );
        }
        return ListView.builder(
          reverse: true,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return _ChatBubble(
              event: event,
              isMine: event.fromUserId == currentUserId,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text(
          context.l10n.chatScreenLoadHistoryError,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: c.love),
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.event, required this.isMine});

  final ChatEvent event;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final time = DateFormat.MMMd().add_Hm().format(event.timestamp);
    final bubbleColor = isMine ? c.primary : c.card;
    final textColor = isMine ? Colors.white : c.text;

    final bubbleContent = event.type == ChatEventType.hapticTouch
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(PhosphorIconsBold.heart, size: 16, color: textColor),
              const SizedBox(width: AppSpacing.xs),
              Text(context.l10n.chatScreenTouchLabel, style: TextStyle(color: textColor)),
            ],
          )
        : Text(event.message ?? '', style: TextStyle(color: textColor));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Column(
        crossAxisAlignment:
            isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.72,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: bubbleContent,
          ),
          const SizedBox(height: 2),
          Text(
            time,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: c.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.sending,
    required this.onSendMessage,
    required this.onSendTouch,
  });

  final TextEditingController controller;
  final bool sending;
  final ValueChanged<String> onSendMessage;
  final VoidCallback onSendTouch;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final quickMessageShortcuts = _quickMessageShortcuts(context);
    return Material(
      color: c.card,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: quickMessageShortcuts.length,
                  separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.xs),
                  itemBuilder: (context, index) {
                    final shortcut = quickMessageShortcuts[index];
                    return ActionChip(
                      label: Text(shortcut),
                      onPressed: () => onSendMessage(shortcut),
                      backgroundColor: c.background,
                      side: BorderSide(color: c.textSecondary.withValues(alpha: 0.2)),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  IconButton(
                    tooltip: context.l10n.chatScreenSendTouchTooltip,
                    onPressed: onSendTouch,
                    icon: Icon(PhosphorIconsBold.heart, color: c.love),
                  ),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      maxLength: 100,
                      decoration: InputDecoration(
                        hintText: context.l10n.chatScreenMessageHint,
                        counterText: '',
                        filled: true,
                        fillColor: c.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                      ),
                      onSubmitted: onSendMessage,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  IconButton(
                    tooltip: context.l10n.chatScreenSendTooltip,
                    onPressed: sending ? null : () => onSendMessage(controller.text),
                    icon: Icon(PhosphorIconsBold.paperPlaneRight, color: c.primary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

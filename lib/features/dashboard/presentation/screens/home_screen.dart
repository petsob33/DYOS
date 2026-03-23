import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/bento_card.dart';
import '../../../../models/note_item.dart';
import '../../../../models/notes_provider.dart';
import '../../../../widgets/home/quick_note_card.dart';
import '../../../auth/presentation/auth_providers.dart';
import '../../../auth/domain/couple_model.dart';
import '../../../auth/domain/user_model.dart';
import '../../../events/presentation/event_provider.dart';
import '../../../tracker/presentation/intimacy_provider.dart';
import '../../../tracker/domain/intimacy_log_model.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../../core/services/notification_service.dart';
import 'package:flutter/services.dart';
import '../haptic_listener_provider.dart';
import '../widgets/insight_horizontal_scroll.dart';
import '../../../gamification/domain/level_manager.dart';
import '../../../gamification/presentation/user_stats_provider.dart';
import '../../../gamification/domain/progression_plan.dart';
import '../../../gamification/presentation/widgets/level_up_unlock_sheet.dart';
import '../../../premium/presentation/premium_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  ProviderSubscription<AsyncValue<DateTime?>>? _hapticSubscription;
  ProviderSubscription<AsyncValue<Map<String, dynamic>?>>? _messageSubscription;

  @override
  void initState() {
    super.initState();
    // Setup listeners after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeNotifications();
      _setupListeners();
    });
  }

  Future<void> _initializeNotifications() async {
    try {
      debugPrint('Initializing notifications in home screen...');
      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.initialize();
      final granted = await notificationService.requestPermissions();
      debugPrint('Notification permissions granted: $granted');
      if (!granted) {
        debugPrint('WARNING: Notification permissions not granted. Notifications may not work.');
      }
    } catch (e, stackTrace) {
      debugPrint('Error initializing notifications: $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('NOTE: This might be because the app needs a full restart (not hot reload) after adding flutter_local_notifications');
    }
  }

  @override
  void dispose() {
    _hapticSubscription?.close();
    _messageSubscription?.close();
    super.dispose();
  }

  void _setupListeners() {
    // Listen for haptic signals using listenManual (can be used outside build)
    _hapticSubscription = ref.listenManual(
      hapticSignalsStreamProvider,
      (previous, next) {
        debugPrint('Haptic signal stream update: ${next.valueOrNull}');
        next.when(
          data: (timestamp) {
            debugPrint('Haptic signal received, timestamp: $timestamp, mounted: $mounted');
            if (timestamp != null && mounted) {
              // Show visual notification for haptic signal
              debugPrint('Showing haptic notification');
              _showHapticNotification();
            } else {
              debugPrint('Not showing haptic notification - timestamp: $timestamp, mounted: $mounted');
            }
          },
          loading: () {
            debugPrint('Haptic signal stream loading');
          },
          error: (error, stack) {
            debugPrint('Error in haptic signal stream: $error');
          },
        );
      },
    );
    
    // Listen for quick messages using listenManual
    _messageSubscription = ref.listenManual(
      quickMessagesStreamProvider,
      (previous, next) {
        debugPrint('Quick message stream update: ${next.valueOrNull}');
        next.when(
          data: (message) {
            debugPrint('Quick message received: $message, mounted: $mounted');
            if (message != null && mounted) {
              final messageText = message['message'] as String? ?? '';
              debugPrint('Showing quick message notification: $messageText');
              _showQuickMessageNotification(messageText);
            } else {
              debugPrint('Not showing quick message - message: $message, mounted: $mounted');
            }
          },
          loading: () {
            debugPrint('Quick message stream loading');
          },
          error: (error, stack) {
            debugPrint('Error in quick message stream: $error');
          },
        );
      },
    );
  }

  void _showHapticNotification() {
    debugPrint('_showHapticNotification called');
    
    // Show system notification
    try {
      final notificationService = ref.read(notificationServiceProvider);
      notificationService.showHapticNotification();
      debugPrint('Haptic system notification shown');
    } catch (e) {
      debugPrint('Error showing haptic system notification: $e');
    }
    
    // Also show overlay if app is in foreground
    if (mounted && context.mounted) {
      try {
        showDialog(
          context: context,
          barrierColor: Colors.transparent,
          barrierDismissible: true,
          builder: (dialogContext) {
            debugPrint('Building haptic notification overlay');
            return _HapticNotificationOverlay();
          },
        );
        debugPrint('Haptic notification overlay shown');
      } catch (e, stackTrace) {
        debugPrint('Error showing haptic notification overlay: $e');
        debugPrint('Stack trace: $stackTrace');
      }
    }
  }

  Future<void> _testNotifications(BuildContext context, WidgetRef ref) async {
    final firebaseService = ref.read(firebaseServiceProvider);
    
    // Get user and couple data - ref.read on FutureProvider returns AsyncValue
    final userAsync = ref.read(currentUserDataProvider);
    final coupleAsync = ref.read(currentCoupleProvider);
    
    // Get the actual values from AsyncValue
    final user = userAsync.valueOrNull;
    final couple = coupleAsync.valueOrNull;

    if (user == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('User not found'),
            backgroundColor: AppTheme.colors.love,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    if (couple == null || user.coupleId == null || user.coupleId!.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Not paired. Please pair first.'),
            backgroundColor: AppTheme.colors.love,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    // Capture values for use in dialog closures
    final userId = user.uid;
    final coupleId = user.coupleId!;

    // Show dialog to choose test type
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Test Notifications'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                try {
                  debugPrint('Sending haptic touch - coupleId: $coupleId, fromUserId: $userId');
                  await firebaseService.sendHapticTouch(
                    coupleId: coupleId,
                    fromUserId: userId,
                    durationMs: 200,
                  );
                  debugPrint('Haptic touch sent successfully');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Haptic signal sent! Check console/logs for details.'),
                        backgroundColor: AppTheme.colors.success,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                } catch (e, stackTrace) {
                  debugPrint('Error sending haptic touch: $e');
                  debugPrint('Stack trace: $stackTrace');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: AppTheme.colors.love,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 5),
                      ),
                    );
                  }
                }
              },
              icon: const Icon(PhosphorIconsBold.handTap),
              label: const Text('Test Haptic Signal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.colors.primary,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                try {
                  final testMessage = 'Test message - ${DateTime.now().toString().substring(11, 19)}';
                  debugPrint('Sending quick message - coupleId: $coupleId, fromUserId: $userId, message: $testMessage');
                  await firebaseService.sendQuickMessage(
                    coupleId: coupleId,
                    fromUserId: userId,
                    message: testMessage,
                  );
                  debugPrint('Quick message sent successfully');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Quick message sent! Check console/logs for details.'),
                        backgroundColor: AppTheme.colors.success,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                } catch (e, stackTrace) {
                  debugPrint('Error sending quick message: $e');
                  debugPrint('Stack trace: $stackTrace');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: AppTheme.colors.love,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 5),
                      ),
                    );
                  }
                }
              },
              icon: const Icon(PhosphorIconsBold.chatCircle),
              label: const Text('Test Quick Message'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.colors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showQuickMessageNotification(String message) {
    debugPrint('_showQuickMessageNotification called with message: $message');
    
    // Show system notification
    try {
      final notificationService = ref.read(notificationServiceProvider);
      notificationService.showQuickMessageNotification(message);
      debugPrint('Quick message system notification shown');
    } catch (e) {
      debugPrint('Error showing quick message system notification: $e');
    }
    
    // Also show overlay if app is in foreground
    if (mounted && context.mounted) {
      try {
        showDialog(
          context: context,
          barrierColor: Colors.transparent,
          barrierDismissible: true,
          builder: (dialogContext) {
            debugPrint('Building quick message notification overlay');
            return _QuickMessageNotificationOverlay(message: message);
          },
        );
        debugPrint('Quick message notification overlay shown');
      } catch (e, stackTrace) {
        debugPrint('Error showing quick message notification overlay: $e');
        debugPrint('Stack trace: $stackTrace');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch providers to keep them active
    ref.watch(hapticSignalsStreamProvider);
    ref.watch(quickMessagesStreamProvider);

    final isPairedAsync = ref.watch(isUserPairedProvider);
    final currentUserAsync = ref.watch(currentUserDataProvider);
    final coupleAsync = ref.watch(currentCoupleProvider);
    final partnerAsync = ref.watch(partnerProvider);

    if (isPairedAsync.hasValue && isPairedAsync.value == false) {
      return Scaffold(body: const Center(child: CircularProgressIndicator()));
    }

    if (currentUserAsync.isLoading || coupleAsync.isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center( 
          child: CircularProgressIndicator(), 
        ),
      );

    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: currentUserAsync.when(
          data: (user) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  context.push('/profile');
                },
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppTheme.colors.primary.withValues(alpha: 0.1),
                  backgroundImage: user?.photoUrl != null
                      ? CachedNetworkImageProvider(user!.photoUrl!)
                      : null,
                  child: user?.photoUrl == null
                      ? Icon(
                          PhosphorIconsBold.user,
                          size: 20,
                          color: AppTheme.colors.primary,
                        )
                      : null,
                ),
              ),
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(8.0),
            child: SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          error: (_, __) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: Icon(
                PhosphorIconsBold.user,
                color: AppTheme.colors.textSecondary,
              ),
              onPressed: () {
                context.push('/profile');
              },
            ),
          ),
        ),
        title: const _AppBarLevelStrip(),
        centerTitle: false,
        actions: [
          // Test notification button (for debugging)
          IconButton(
            icon: Icon(
              PhosphorIconsBold.bell,
              color: AppTheme.colors.primary,
            ),
            onPressed: () => _testNotifications(context, ref),
            tooltip: 'Test Notifications',
          ),
          IconButton(
            icon: Icon(
              PhosphorIconsBold.gear,
              color: AppTheme.colors.text,
            ),
            onPressed: () {
              context.push('/settings');
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.lg,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Home',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.colors.text,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Widgets for your life',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              sliver: SliverToBoxAdapter(
                child: _StatusHeader(
                  coupleAsync: coupleAsync,
                  partnerAsync: partnerAsync,
                  currentUserAsync: currentUserAsync,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(
                top: AppSpacing.xl,
                left: 0,
                right: 0,
                bottom: 0,
              ),
              sliver: const SliverToBoxAdapter(
                child: InsightHorizontalScroll(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 600;
                    final crossAxisCount = isWide ? 3 : 2;
                    return MasonryGridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: AppSpacing.lg,
                      crossAxisSpacing: AppSpacing.lg,
                      itemCount: _cards.length,
                      itemBuilder: (context, index) => _cards[index],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final _cards = <Widget>[
  const _DaysTogetherCard(),
  const _CountdownCard(),
  const _IntimacySparkCard(),
  const _TapticTouchCard(),
  const _QuickMessageCard(),
  const _QuickNoteCard(),
  const _EventsCard(),
  const _ListsCard(),
  const _BlueprintsCard(),
];

/// Level strip in app bar (roztáhnutý): version, progress bar, XP. Tap opens Level page.
class _AppBarLevelStrip extends ConsumerWidget {
  const _AppBarLevelStrip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentXp = ref.watch(currentXpProvider);
    final version = LevelManager.currentVersionString(currentXp);
    final progress = LevelManager.calculateProgress(currentXp);
    final c = AppTheme.colors;
    return Padding(
      padding: const EdgeInsets.only(left: 0, right: 8, top: 8, bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/level'),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: c.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Text(
                  version,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: c.primary,
                      ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      minHeight: 6,
                      backgroundColor: c.textSecondary.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(c.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$currentXp SP',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: c.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(width: 4),
                Icon(PhosphorIconsBold.caretRight, size: 16, color: c.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BlueprintsCard extends ConsumerWidget {
  const _BlueprintsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSp = ref.watch(currentXpProvider);
    final isPremium =
        ref.watch(isPremiumProvider).valueOrNull ?? false;
    final unlocked = ProgressionPlan.isFeatureUnlocked(
      FeatureID.blueprints,
      currentSp,
      isPremium,
    );

    final c = AppTheme.colors;

    return BentoCard(
      onTap: () => unlocked
          ? context.push('/blueprints')
          : showLevelUpUnlockSheet(context, ref, FeatureID.blueprints),
      background: c.card,
      child: Center(
        child: Icon(
          PhosphorIconsBold.clipboardText,
          color: c.primary,
          size: 52,
        ),
      ),
    );
  }
}

class _StatusHeader extends StatelessWidget {
  const _StatusHeader({
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
            final currentUserStatus = (currentUserId.isNotEmpty && couple.status != null)
                ? couple.status![currentUserId]
                : null;
            
            // Get partner's status
            return partnerAsync.when(
              data: (partner) {
                final partnerStatus = (partner != null && partner.uid.isNotEmpty && couple.status != null)
                    ? couple.status![partner.uid]
                    : null;
                
                
                return BentoCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      Expanded(
                        child: _AvatarStatus(
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
                        color: AppTheme.colors.textSecondary.withValues(alpha: 0.1),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _AvatarStatus(
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
                      child: _AvatarStatus(
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
                      color: AppTheme.colors.textSecondary.withValues(alpha: 0.1),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const Expanded(
                      child: _AvatarStatus(
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
                        child: _AvatarStatus(
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
                        color: AppTheme.colors.textSecondary.withValues(alpha: 0.1),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      const Expanded(
                        child: _AvatarStatus(
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
            child: const _AvatarStatus(
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
        child: const _AvatarStatus(
          name: 'You',
          emoji: '😊',
          status: 'Ready',
        ),
      ),
    );
  }
}

class _AvatarStatus extends ConsumerWidget {
  const _AvatarStatus({
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
                        color: AppTheme.colors.textSecondary.withValues(alpha: 0.5),
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
    '😊', '🤗', '❤️', '😴', '🔋', '🤯', '💼', '🏃', '🍷', '📚',
    '🎉', '😢', '☀️', '🌙', '💪', '🧘', '✈️', '🍳', '🎵', '💭',
  ];

  Future<void> _showStatusEditDialog(BuildContext context, WidgetRef ref) async {
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
                                ? AppTheme.colors.primary.withValues(alpha: 0.15)
                                : AppTheme.colors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.colors.primary
                                  : AppTheme.colors.textSecondary.withValues(alpha: 0.2),
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

class _DaysTogetherCard extends ConsumerWidget {
  const _DaysTogetherCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coupleAsync = ref.watch(coupleProvider);
    
    return coupleAsync.when(
      data: (couple) {
        if (couple?.anniversaryDate == null) {
          return BentoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Days Together',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppTheme.colors.textSecondary,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Center(
                  child: Text(
                    '0',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppTheme.colors.text,
                        ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Set your anniversary date',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.colors.textSecondary,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        }
        
        final daysTogether = DateTime.now().difference(couple!.anniversaryDate!).inDays;
        
        return BentoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Days Together',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppTheme.colors.textSecondary,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Center(
                child: Text(
                  '$daysTogether',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppTheme.colors.text,
                      ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              
            ],
          ),
        );
      },
      loading: () => BentoCard(
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => BentoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Days Together',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppTheme.colors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: Text(
                '0',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.colors.text,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickNoteCard extends ConsumerWidget {
  const _QuickNoteCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latestNoteAsync = ref.watch(latestSharedNoteProvider);
    
    return latestNoteAsync.when(
      data: (note) {
        return QuickNoteCard(
          content: note?.content ?? '',
          onTap: () {
            context.push('/add-note');
          },
        );
      },
      loading: () => const QuickNoteCard(
        content: '',
      ),
      error: (error, stackTrace) {
        return QuickNoteCard(
          content: '',
          onTap: () {
            context.push('/add-note');
          },
        );
      },
    );
  }
}

class _EventsCard extends ConsumerWidget {
  const _EventsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsStreamProvider);

    return eventsAsync.when(
      data: (events) {
        final upcomingEvents = events.where((event) {
          final today = DateTime.now();
          final eventDate = DateTime(event.date.year, event.date.month, event.date.day);
          final todayDate = DateTime(today.year, today.month, today.day);
          return eventDate.isAfter(todayDate) || eventDate.isAtSameMomentAs(todayDate);
        }).toList();
        
        final c = AppTheme.colors;

        return BentoCard(
          onTap: () {
            context.push('/events');
          },
          background: c.card,
          child: Center(
            child: Icon(
              PhosphorIconsBold.calendar,
              color: c.success,
              size: 52,
            ),
          ),
        );
      },
      loading: () {
        final c = AppTheme.colors;
        return BentoCard(
          onTap: () {
            context.push('/events');
          },
          background: c.card,
          child: Center(
            child: Icon(
              PhosphorIconsBold.calendar,
              color: c.success,
              size: 52,
            ),
          ),
        );
      },
      error: (error, stackTrace) {
        final c = AppTheme.colors;
        return BentoCard(
          onTap: () {
            context.push('/events');
          },
          background: c.card,
          child: Center(
            child: Icon(
              PhosphorIconsBold.calendar,
              color: c.success,
              size: 52,
            ),
          ),
        );
      },
    );
  }
}

class _CountdownCard extends ConsumerWidget {
  const _CountdownCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nextEventAsync = ref.watch(nextEventProvider);

    return nextEventAsync.when(
      data: (event) {
        if (event == null) {
          return BentoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Countdown',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppTheme.colors.textSecondary,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'No upcoming events',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.colors.textSecondary,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        }

        final now = DateTime.now();
        final eventDate = DateTime(event.date.year, event.date.month, event.date.day);
        final today = DateTime(now.year, now.month, now.day);
        final daysUntil = eventDate.difference(today).inDays;

        return BentoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Countdown',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppTheme.colors.textSecondary,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '$daysUntil',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.colors.primary,
                    ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'days until: ${event.title}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.colors.textSecondary,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
      loading: () => BentoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Countdown',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppTheme.colors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
      error: (_, __) => BentoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Countdown',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppTheme.colors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Error loading events',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.colors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntimacySparkCard extends ConsumerWidget {
  const _IntimacySparkCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(intimacyLogsStreamProvider);

    return logsAsync.when(
      data: (logs) {
        if (logs.isEmpty) {
          return BentoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  PhosphorIconsBold.heart,
                  color: AppTheme.colors.love,
                  size: 24,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'No activity yet',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.colors.textSecondary,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        }

        // Get the most recent log
        final sortedLogs = List<IntimacyLog>.from(logs)
          ..sort((a, b) => b.date.compareTo(a.date));
        final lastLog = sortedLogs.first;
        final daysSince = DateTime.now().difference(lastLog.date).inDays;

        String sparkText;
        String sparkEmoji;
        if (daysSince == 0) {
          sparkText = 'Today';
          sparkEmoji = '🔥';
        } else if (daysSince == 1) {
          sparkText = '1 day ago';
          sparkEmoji = '🔥';
        } else if (daysSince < 7) {
          sparkText = '$daysSince days ago';
          sparkEmoji = '🔥';
        } else if (daysSince < 14) {
          sparkText = '$daysSince days ago';
          sparkEmoji = '💫';
        } else {
          sparkText = '$daysSince days ago';
          sparkEmoji = '💭';
        }

        return BentoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    PhosphorIconsBold.heart,
                    color: AppTheme.colors.love,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.colors.textSecondary,
                            ),
                        children: [
                          const TextSpan(text: ''),
                          TextSpan(
                            text: sparkText,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.colors.text,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          TextSpan(
                            text: ' $sparkEmoji',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.colors.text,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => BentoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              PhosphorIconsBold.heart,
              color: AppTheme.colors.love,
              size: 24,
            ),
            const SizedBox(height: AppSpacing.sm),
            const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
      error: (_, __) => BentoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              PhosphorIconsBold.heart,
              color: AppTheme.colors.love,
              size: 24,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Error loading data',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.colors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TapticTouchCard extends ConsumerStatefulWidget {
  const _TapticTouchCard();

  @override
  ConsumerState<_TapticTouchCard> createState() => _TapticTouchCardState();
}

class _TapticTouchCardState extends ConsumerState<_TapticTouchCard> {
  DateTime? _pressStartTime;
  bool _isPressed = false;
  bool _justSent = false;

  @override
  Widget build(BuildContext context) {
    final currentSp = ref.watch(currentXpProvider);
    final isPremium = ref.watch(isPremiumProvider).valueOrNull ?? false;
    final unlocked =
        ProgressionPlan.isRewardUnlocked(RewardKind.taptic, currentSp, isPremium);

    final coupleAsync = ref.watch(currentCoupleProvider);
    final currentUserAsync = ref.watch(currentUserDataProvider);

    return coupleAsync.when(
      data: (couple) {
        if (couple == null) {
          return BentoCard(
            child: Center(
              child: Icon(
                PhosphorIconsBold.heart,
                color: AppTheme.colors.love.withValues(alpha: 0.3),
                size: 56,
              ),
            ),
          );
        }

        final currentUserId = currentUserAsync.valueOrNull?.uid ?? '';

        return BentoCard(
          child: GestureDetector(
            onTapDown: (_) {
              if (!unlocked) {
                HapticFeedback.selectionClick();
                return;
              }
              setState(() {
                _isPressed = true;
                _pressStartTime = DateTime.now();
              });
              HapticFeedback.mediumImpact();
            },
            onTapUp: (_) {
              if (!unlocked) {
                context.push('/premium');
              } else {
                _handleRelease(couple.id, currentUserId);
              }
            },
            onTapCancel: () {
              if (!unlocked) return;
              _handleRelease(couple.id, currentUserId);
            },
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: _isPressed
                    ? AppTheme.colors.love.withValues(alpha: 0.1)
                    : _justSent
                        ? AppTheme.colors.success.withValues(alpha: 0.1)
                        : AppTheme.colors.background,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      PhosphorIconsBold.heart,
                      color: _isPressed
                          ? AppTheme.colors.love
                          : _justSent
                              ? AppTheme.colors.success
                              : AppTheme.colors.love.withValues(alpha: 0.6),
                      size: 56,
                    ),
                    if (!unlocked) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Unlock with DYOS+ or via the Roadmap',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.colors.textSecondary,
                            ),
                      ),
                    ],
                    if (_justSent) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Sent',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: AppTheme.colors.success,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () => BentoCard(
        child: Center(
          child: Icon(
            PhosphorIconsBold.heart,
            color: AppTheme.colors.love.withValues(alpha: 0.3),
            size: 56,
          ),
        ),
      ),
      error: (_, __) => BentoCard(
        child: Center(
          child: Icon(
            PhosphorIconsBold.heart,
            color: AppTheme.colors.love.withValues(alpha: 0.3),
            size: 56,
          ),
        ),
      ),
    );
  }

  void _handleRelease(String coupleId, String userId) {
    if (_pressStartTime == null) return;

    final duration = DateTime.now().difference(_pressStartTime!);
    final durationMs = duration.inMilliseconds.clamp(100, 2000); // Min 100ms, max 2s

    setState(() {
      _isPressed = false;
    });

    HapticFeedback.lightImpact();

    final firebaseService = ref.read(firebaseServiceProvider);
    firebaseService.sendHapticTouch(
      coupleId: coupleId,
      fromUserId: userId,
      durationMs: durationMs,
    ).then((_) {
      if (!mounted) return;
      setState(() => _justSent = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Sent to partner'),
          backgroundColor: AppTheme.colors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) setState(() => _justSent = false);
      });
    }).catchError((error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending: $error'),
            backgroundColor: AppTheme.colors.love,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    });

    _pressStartTime = null;
  }
}

class _QuickMessageCard extends ConsumerWidget {
  const _QuickMessageCard();

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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
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

/// Overlay widget for haptic signal notification
class _HapticNotificationOverlay extends StatefulWidget {
  @override
  State<_HapticNotificationOverlay> createState() => _HapticNotificationOverlayState();
}

class _HapticNotificationOverlayState extends State<_HapticNotificationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
    
    // Auto-dismiss after animation
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppTheme.colors.love.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.colors.love.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(
                    PhosphorIconsBold.heart,
                    color: AppTheme.colors.love,
                    size: 64,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _QuickMessageNotificationOverlay extends StatefulWidget {
  final String message;
  
  const _QuickMessageNotificationOverlay({required this.message});

  @override
  State<_QuickMessageNotificationOverlay> createState() => _QuickMessageNotificationOverlayState();
}

class _QuickMessageNotificationOverlayState extends State<_QuickMessageNotificationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();
    
    // Auto-dismiss after 4 seconds
    Future.delayed(const Duration(milliseconds: 4000), () {
      if (mounted) {
        _controller.reverse().then((_) {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Align(
            alignment: Alignment.topCenter,
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _opacityAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: BentoCard(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppTheme.colors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            PhosphorIconsBold.chatCircle,
                            color: AppTheme.colors.primary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Quick Message',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: AppTheme.colors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                widget.message,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: AppTheme.colors.text,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ListsCard extends ConsumerWidget {
  const _ListsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bucketListNotesAsync = ref.watch(
      coupleNotesProvider(type: NoteType.bucketList),
    );

    return bucketListNotesAsync.when(
      data: (notes) {
        final totalCount = notes.length;
        final hasItems = totalCount > 0;
        
        final c = AppTheme.colors;

        return BentoCard(
          onTap: () {
            context.push('/lists');
          },
          background: c.card,
          child: Center(
            child: Icon(
              PhosphorIconsBold.listChecks,
              color: c.warning,
              size: 52,
            ),
          ),
        );
      },
      loading: () {
        final c = AppTheme.colors;
        return BentoCard(
          onTap: () {
            context.push('/lists');
          },
          background: c.card,
          child: Center(
            child: Icon(
              PhosphorIconsBold.listChecks,
              color: c.warning,
              size: 52,
            ),
          ),
        );
      },
      error: (error, stackTrace) {
        final c = AppTheme.colors;
        return BentoCard(
          onTap: () {
            context.push('/lists');
          },
          background: c.card,
          child: Center(
            child: Icon(
              PhosphorIconsBold.listChecks,
              color: c.warning,
              size: 52,
            ),
          ),
        );
      },
    );
  }
}


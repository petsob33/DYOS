import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/auth_providers.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../../core/services/app_logger.dart';
import '../../../../core/services/notification_service.dart';
import 'package:flutter/services.dart';
import '../haptic_listener_provider.dart';
import '../widgets/insight_horizontal_scroll.dart';
import '../widgets/app_bar_level_strip.dart';
import '../widgets/blueprints_card.dart';
import '../widgets/status_header.dart';
import '../widgets/days_together_card.dart';
import '../widgets/quick_note_dashboard_card.dart';
import '../widgets/events_card.dart';
import '../widgets/countdown_card.dart';
import '../widgets/intimacy_spark_card.dart';
import '../widgets/taptic_touch_card.dart';
import '../widgets/quick_message_card.dart';
import '../widgets/haptic_notification_overlay.dart';
import '../widgets/quick_message_notification_overlay.dart';
import '../widgets/lists_card.dart';

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
      AppLogger.debug('Initializing notifications in home screen...');
      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.initialize();
      final granted = await notificationService.requestPermissions();
      AppLogger.debug('Notification permissions granted: $granted');
      if (!granted) {
        AppLogger.debug(
          'WARNING: Notification permissions not granted. Notifications may not work.',
        );
      }
    } catch (e, stackTrace) {
      AppLogger.debug('Error initializing notifications: $e');
      AppLogger.debug('Stack trace: $stackTrace');
      AppLogger.debug(
        'NOTE: This might be because the app needs a full restart (not hot reload) after adding flutter_local_notifications',
      );
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
    _hapticSubscription = ref.listenManual(hapticSignalsStreamProvider, (
      previous,
      next,
    ) {
      debugPrint('Haptic signal stream update: ${next.valueOrNull}');
      next.when(
        data: (timestamp) {
          debugPrint(
            'Haptic signal received, timestamp: $timestamp, mounted: $mounted',
          );
          if (timestamp != null && mounted) {
            // Show visual notification for haptic signal
            debugPrint('Showing haptic notification');
            _showHapticNotification();
          } else {
            debugPrint(
              'Not showing haptic notification - timestamp: $timestamp, mounted: $mounted',
            );
          }
        },
        loading: () {
          debugPrint('Haptic signal stream loading');
        },
        error: (error, stack) {
          debugPrint('Error in haptic signal stream: $error');
        },
      );
    });

    // Listen for quick messages using listenManual
    _messageSubscription = ref.listenManual(quickMessagesStreamProvider, (
      previous,
      next,
    ) {
      debugPrint('Quick message stream update: ${next.valueOrNull}');
      next.when(
        data: (message) {
          debugPrint('Quick message received: $message, mounted: $mounted');
          if (message != null && mounted) {
            final messageText = message['message'] as String? ?? '';
            debugPrint('Showing quick message notification: $messageText');
            _showQuickMessageNotification(messageText);
          } else {
            debugPrint(
              'Not showing quick message - message: $message, mounted: $mounted',
            );
          }
        },
        loading: () {
          debugPrint('Quick message stream loading');
        },
        error: (error, stack) {
          debugPrint('Error in quick message stream: $error');
        },
      );
    });
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
            return HapticNotificationOverlay();
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
                  debugPrint(
                    'Sending haptic touch - coupleId: $coupleId, fromUserId: $userId',
                  );
                  await firebaseService.sendHapticTouch(
                    coupleId: coupleId,
                    fromUserId: userId,
                    durationMs: 200,
                  );
                  debugPrint('Haptic touch sent successfully');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Haptic signal sent! Check console/logs for details.',
                        ),
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
                  final testMessage =
                      'Test message - ${DateTime.now().toString().substring(11, 19)}';
                  debugPrint(
                    'Sending quick message - coupleId: $coupleId, fromUserId: $userId, message: $testMessage',
                  );
                  await firebaseService.sendQuickMessage(
                    coupleId: coupleId,
                    fromUserId: userId,
                    message: testMessage,
                  );
                  debugPrint('Quick message sent successfully');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Quick message sent! Check console/logs for details.',
                        ),
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
            return QuickMessageNotificationOverlay(message: message);
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

    ref.watch(isUserPairedProvider);
    final currentUserAsync = ref.watch(currentUserDataProvider);
    final coupleAsync = ref.watch(currentCoupleProvider);
    final partnerAsync = ref.watch(partnerProvider);

    if (currentUserAsync.isLoading || coupleAsync.isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
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
                  backgroundColor: AppTheme.colors.primary.withValues(
                    alpha: 0.1,
                  ),
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
        title: const AppBarLevelStrip(),
        centerTitle: false,
        actions: [
          // Test notification button (for debugging)
          IconButton(
            icon: Icon(PhosphorIconsBold.bell, color: AppTheme.colors.primary),
            onPressed: () => _testNotifications(context, ref),
            tooltip: 'Test Notifications',
          ),
          IconButton(
            icon: Icon(PhosphorIconsBold.gear, color: AppTheme.colors.text),
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
                child: StatusHeader(
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
  const DaysTogetherCard(),
  const CountdownCard(),
  const IntimacySparkCard(),
  const TapticTouchCard(),
  const QuickMessageCard(),
  const QuickNoteDashboardCard(),
  const EventsCard(),
  const ListsCard(),
  const BlueprintsCard(),
];

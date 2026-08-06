import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/constants/app_spacing.dart';
import '../l10n/build_context_l10n_extension.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/adaptive_banner_ad.dart';
import '../../features/auth/presentation/auth_providers.dart';
import '../../features/gamification/domain/progression_plan.dart';
import '../../features/gamification/presentation/user_stats_provider.dart';
import '../../features/gamification/presentation/widgets/level_up_unlock_sheet.dart';
import '../../features/premium/presentation/premium_provider.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/firebase_test_screen.dart';
import '../../features/auth/presentation/pairing_screen.dart';
import '../../features/dashboard/presentation/screens/home_screen.dart';
import '../../features/dashboard/presentation/screens/chat_screen.dart';
import '../../features/timeline/presentation/screens/timeline_screen.dart';
import '../../features/timeline/presentation/screens/add_memory_screen.dart';
import '../../features/timeline/presentation/screens/memories_map_screen.dart';
import '../../features/timeline/presentation/screens/memory_detail_screen.dart';
import '../../features/timeline/domain/memory_model.dart';
import '../../features/tracker/presentation/data_screen.dart';
import '../../features/tracker/presentation/screens/intimacy_history_screen.dart';
import '../../features/tracker/presentation/widgets/add_intimacy_sheet.dart';
import '../../features/lists/lists_screen.dart';
import '../../features/lists/settings_screen.dart';
import '../../features/notes/presentation/screens/add_note_screen.dart';
import '../../features/auth/presentation/profile_screen.dart';
import '../../features/auth/presentation/edit_profile_picture_screen.dart';
import '../../features/premium/presentation/screens/premium_landing_screen.dart';
import '../../features/gamification/presentation/screens/system_status_demo_screen.dart';
import '../../features/blueprints/presentation/screens/blueprint_detail_screen.dart';
import '../../features/blueprints/presentation/screens/blueprints_list_screen.dart';
import '../../features/gamification/presentation/screens/level_screen.dart';
import '../../features/notes/presentation/screens/secret_notes_screen.dart';
import '../../features/cycle/presentation/cycle_tracking_screen.dart';
import '../../features/events/presentation/add_event_sheet.dart';
import '../../features/events/presentation/events_screen.dart';
import '../../features/notes/domain/note_item.dart';

part 'app_router.g.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

/// Debug routes must be explicitly enabled with:
/// --dart-define=ENABLE_DEBUG_ROUTES=true
const bool _enableDebugRoutes = bool.fromEnvironment(
  'ENABLE_DEBUG_ROUTES',
  defaultValue: false,
);

bool get _isFirebaseTestRouteEnabled => !kReleaseMode && _enableDebugRoutes;

/// Helper function to create a page with slide transition animation
Page<T> buildPageWithSlideTransition<T extends Object?>(
  BuildContext context,
  GoRouterState state,
  Widget child, {
  Duration transitionDuration = const Duration(milliseconds: 300),
  Curve transitionCurve = Curves.easeInOut,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
    ) {
      // Slide from right to left when pushing
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      final tween = Tween<Offset>(begin: begin, end: end);
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: transitionCurve,
      );
      final offsetAnimation = tween.animate(curvedAnimation);

      return SlideTransition(
        position: offsetAnimation,
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    },
    transitionDuration: transitionDuration,
    reverseTransitionDuration: transitionDuration,
  );
}

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  ref.listen(authStateProvider, (prev, next) {
    if (next.valueOrNull == null) {
      ref.read(pairingConfirmedCoupleIdProvider.notifier).state = null;
    }
  });

  ref.listen(userProvider, (prev, next) {
    next.whenData((user) {
      final pending = ref.read(pairingConfirmedCoupleIdProvider);
      // Only clear pending state once the user profile actually reflects the pairing
      if (pending != null &&
          pending.isNotEmpty &&
          user?.coupleId != null &&
          user!.coupleId == pending) {
        // Delay clearing slightly to allow the UI to settle on the new state
        Future.delayed(const Duration(milliseconds: 500), () {
          ref.read(pairingConfirmedCoupleIdProvider.notifier).state = null;
        });
      }
    });
  });

  // Watch auth state - Stream<User?> - rebuilds the router when it changes
  ref.watch(authStateProvider);
  // Watch user data - Stream<UserModel?> - rebuilds the router when it changes
  ref.watch(userProvider);
  // Watch temporary pairing state from PairingScreen to prevent race conditions during redirect
  ref.watch(pairingConfirmedCoupleIdProvider);

  return GoRouter(
    navigatorKey: appNavigatorKey,
    initialLocation: '/login',
    redirect: (context, state) {
      // Get auth state and check if user is on a public page
      final authState = ref.watch(authStateProvider);
      final firebaseUser = authState.valueOrNull;
      final isAuthenticated = firebaseUser != null;
      final onPublicRoute = state.matchedLocation == '/login' || state.matchedLocation == '/register';
      debugPrint('[Router] location=${state.matchedLocation} auth=${authState.runtimeType}(${firebaseUser?.uid}) isAuthenticated=$isAuthenticated');

      // 1. Handle unauthenticated users
      if (!isAuthenticated) {
        return onPublicRoute ? null : '/login';
      }

      // --- User is authenticated ---

      // Get user profile state from Firestore and temporary pairing state
      final userState = ref.watch(userProvider);
      final userModel = userState.valueOrNull;
      final pendingCoupleId = ref.watch(pairingConfirmedCoupleIdProvider);

      // Check if critical data is still loading
      final isLoading = authState.isLoading || userState.isLoading;
      debugPrint('[Router] userState=${userState.runtimeType} userModel=${userModel?.uid} coupleId=${userModel?.coupleId} isLoading=$isLoading hasError=${userState.hasError}');

      // 2. Handle loading state
      if (isLoading) {
        // If on login/register, a successful auth just happened. Redirect to /home
        // to show progress. The router will re-evaluate once loading is done.
        if (onPublicRoute) {
          return '/home';
        }
        // If already in the app, stay put while loading to avoid screen flashing.
        return null;
      }

      // --- Loading is finished ---

      // 3. Check for UID mismatch (transient state after fast login/logout)
      // If the loaded profile is for a different user, wait for the stream to catch up.
      if (userModel != null && userModel.uid != firebaseUser.uid) {
        return null; // Stay put and wait for the correct profile
      }

      // 3b. If userModel is null while authenticated and no error, the stream is
      // still transitioning (Firebase auth emits null → user, causing a brief
      // AsyncData(null) before Firestore responds). Treat as loading.
      if (userModel == null && !userState.hasError) {
        return onPublicRoute ? '/home' : null;
      }

      // 4. Determine the real pairing status
      final hasCoupleId = (userModel?.coupleId != null && userModel!.coupleId!.isNotEmpty) ||
                         (pendingCoupleId != null && pendingCoupleId.isNotEmpty);

      final onPairingRoute = state.matchedLocation == '/pairing';

      // 5. Enforce routing rules based on pairing status
      if (hasCoupleId) {
        // User is paired. They belong in the main app.
        // If they are on a public or pairing page, send them to the home shell.
        if (onPublicRoute || onPairingRoute) {
          return '/home';
        }
      } else {
        // User is NOT paired. They MUST go to the pairing screen.
        // If they are not already on the pairing screen, redirect them.
        if (!onPairingRoute) {
          return '/pairing';
        }
      }

      // 6. No redirect is necessary if all conditions are met
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) => buildPageWithSlideTransition(
          context,
          state,
          const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        pageBuilder: (context, state) {
          final email = state.uri.queryParameters['email'];
          return buildPageWithSlideTransition(
            context,
            state,
            RegisterScreen(email: email),
          );
        },
      ),
      if (_isFirebaseTestRouteEnabled)
        GoRoute(
          path: '/firebase-test',
          name: 'firebase-test',
          pageBuilder: (context, state) => buildPageWithSlideTransition(
            context,
            state,
            const FirebaseTestScreen(),
          ),
        ),
      GoRoute(
        path: '/pairing',
        name: 'pairing',
        pageBuilder: (context, state) => buildPageWithSlideTransition(
          context,
          state,
          const PairingScreen(),
        ),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        pageBuilder: (context, state) => buildPageWithSlideTransition(
          context,
          state,
          const SettingsScreen(),
        ),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        pageBuilder: (context, state) => buildPageWithSlideTransition(
          context,
          state,
          const ProfileScreen(),
        ),
      ),
      GoRoute(
        path: '/chat',
        name: 'chat',
        pageBuilder: (context, state) => buildPageWithSlideTransition(
          context,
          state,
          const ChatScreen(),
        ),
      ),
      GoRoute(
        path: '/premium',
        name: 'premium',
        pageBuilder: (context, state) => buildPageWithSlideTransition(
          context,
          state,
          const PremiumLandingScreen(),
        ),
      ),
      GoRoute(
        path: '/system-status-demo',
        name: 'system-status-demo',
        pageBuilder: (context, state) => buildPageWithSlideTransition(
          context,
          state,
          const SystemStatusDemoScreen(),
        ),
      ),
      GoRoute(
        path: '/level',
        name: 'level',
        pageBuilder: (context, state) => buildPageWithSlideTransition(
          context,
          state,
          const LevelScreen(),
        ),
      ),
      GoRoute(
        path: '/blueprints',
        name: 'blueprints',
        pageBuilder: (context, state) => buildPageWithSlideTransition(
          context,
          state,
          const BlueprintsListScreen(),
        ),
      ),
      GoRoute(
        path: '/blueprint/:sectionId',
        name: 'blueprint-detail',
        pageBuilder: (context, state) {
          final sectionId = state.pathParameters['sectionId'] ?? '';
          return buildPageWithSlideTransition(
            context,
            state,
            BlueprintDetailScreen(sectionId: sectionId),
          );
        },
      ),
      GoRoute(
        path: '/blueprint/travel-config',
        name: 'blueprint-travel-config',
        pageBuilder: (context, state) => buildPageWithSlideTransition(
          context,
          state,
          const BlueprintDetailScreen(sectionId: 'travel'),
        ),
      ),
      GoRoute(
        path: '/edit-profile-picture',
        name: 'edit-profile-picture',
        pageBuilder: (context, state) => buildPageWithSlideTransition(
          context,
          state,
          const EditProfilePictureScreen(),
        ),
      ),
      GoRoute(
        path: '/intimacy-history',
        name: 'intimacy-history',
        pageBuilder: (context, state) => buildPageWithSlideTransition(
          context,
          state,
          const IntimacyHistoryScreen(),
        ),
      ),
      GoRoute(
        path: '/secret-notes',
        name: 'secret-notes',
        pageBuilder: (context, state) => buildPageWithSlideTransition(
          context,
          state,
          const SecretNotesScreen(),
        ),
      ),
      GoRoute(
        path: '/add-memory',
        name: 'add-memory',
        pageBuilder: (context, state) => buildPageWithSlideTransition(
          context,
          state,
          const AddMemoryScreen(),
        ),
      ),
      GoRoute(
        path: '/memory/edit',
        name: 'memory-edit',
        pageBuilder: (context, state) {
          final memory = state.extra as Memory?;
          if (memory == null) {
            return buildPageWithSlideTransition(
              context,
              state,
              Scaffold(
                body: Center(child: Text(context.l10n.appRouterMemoryNotFound)),
              ),
            );
          }
          return buildPageWithSlideTransition(
            context,
            state,
            AddMemoryScreen(initialMemory: memory),
          );
        },
      ),
      GoRoute(
        path: '/memory/map',
        name: 'memory-map',
        pageBuilder: (context, state) => buildPageWithSlideTransition(
          context,
          state,
          const MemoriesMapScreen(),
        ),
      ),
      GoRoute(
        path: '/memory/detail',
        name: 'memory-detail',
        pageBuilder: (context, state) {
          final memory = state.extra as Memory?;
          if (memory == null) {
            return buildPageWithSlideTransition(
              context,
              state,
              Scaffold(
                body: Center(child: Text(context.l10n.appRouterMemoryNotFound)),
              ),
            );
          }
          return buildPageWithSlideTransition(
            context,
            state,
            MemoryDetailScreen(memory: memory),
          );
        },
      ),
      GoRoute(
        path: '/add-note',
        name: 'add-note',
        pageBuilder: (context, state) {
          final typeParam = state.uri.queryParameters['type'];
          NoteType? initialType;
          if (typeParam != null) {
            try {
              initialType = NoteType.values.firstWhere(
                (e) => e.name == typeParam,
              );
            } catch (e) {
              // Invalid type parameter, use default
            }
          }
          return buildPageWithSlideTransition(
            context,
            state,
            AddNoteScreen(initialType: initialType),
          );
        },
      ),
      GoRoute(
        path: '/events',
        name: 'events',
        pageBuilder: (context, state) => buildPageWithSlideTransition(
          context,
          state,
          const EventsScreen(),
        ),
      ),
      GoRoute(
        path: '/lists',
        name: 'lists',
        pageBuilder: (context, state) => buildPageWithSlideTransition(
          context,
          state,
          const ListsScreen(),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            RootShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/memory',
                name: 'memory',
                builder: (context, state) => const TimelineScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/data',
                name: 'data',
                builder: (context, state) => const DataScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cycle',
                name: 'cycle',
                builder: (context, state) => const CycleTrackingScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}


class RootShell extends ConsumerWidget {
  const RootShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const int _branchCount = 4; // Home, Memory, Data, Cycle
  static const double _swipeVelocityThreshold = 200; // px/s – min. rychlost pro přepnutí
  static const double _swipeUpVelocityThreshold = 400; // px/s – swipe nahoru otevře Quick Add

  void _onTabSelected(BuildContext context, WidgetRef ref, int index) {
    if (index == 1) {
      final currentSp = ref.read(currentXpProvider);
      final isPremium = ref.read(isPremiumProvider).valueOrNull ?? false;
      if (!ProgressionPlan.isFeatureUnlocked(FeatureID.memories, currentSp, isPremium)) {
        showLevelUpUnlockSheet(context, ref, FeatureID.memories);
        return;
      }
    }
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  void _onHorizontalSwipe(BuildContext context, WidgetRef ref, double velocity) {
    final current = navigationShell.currentIndex;
    if (velocity < -_swipeVelocityThreshold && current < _branchCount - 1) {
      final nextIndex = current + 1;
      if (nextIndex == 1) {
        final currentSp = ref.read(currentXpProvider);
        final isPremium = ref.read(isPremiumProvider).valueOrNull ?? false;
        if (!ProgressionPlan.isFeatureUnlocked(FeatureID.memories, currentSp, isPremium)) {
          showLevelUpUnlockSheet(context, ref, FeatureID.memories);
          return;
        }
      }
      navigationShell.goBranch(nextIndex);
    } else if (velocity > _swipeVelocityThreshold && current > 0) {
      navigationShell.goBranch(current - 1);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumProvider).valueOrNull ?? false;
    final items = [
      _NavItem(context.l10n.appRouterNavHome, PhosphorIconsBold.house),
      _NavItem(context.l10n.appRouterNavMemory, PhosphorIconsBold.clockCounterClockwise),
      _NavItem(context.l10n.appRouterNavData, PhosphorIconsBold.chartPieSlice),
      _NavItem(context.l10n.appRouterNavCalendar, PhosphorIconsBold.calendar),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0;
          _onHorizontalSwipe(context, ref, velocity.toDouble());
        },
        onVerticalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0;
          if (velocity < -_swipeUpVelocityThreshold) {
            showQuickAddSheet(context, ref);
          }
        },
        behavior: HitTestBehavior.translucent,
        child: navigationShell,
      ),
      bottomNavigationBar: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isPremium) const AdaptiveBannerAd(),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    for (int i = 0; i < items.length + 1; i++)
                      if (i == 2)
                        // Insert the add button as a big round button in the center, in line with other nav items
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Material(
                            color: context.colors.primary,
                            shape: const CircleBorder(),
                            elevation: 4,
                            shadowColor: context.colors.shadow,
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () {
                                showQuickAddSheet(context, ref);
                              },
                              child: SizedBox(
                                width: 56,
                                height: 56,
                                child: Icon(
                                  PhosphorIconsBold.plus,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        // Render the nav item (skip slot 2 for add btn)
                        Expanded(
                          child: _BottomNavItem(
                            item: items[i > 2 ? i - 1 : i],
                            index: i > 2 ? i - 1 : i,
                            selected: navigationShell.currentIndex == (i > 2 ? i - 1 : i),
                            onTap: () => _onTabSelected(context, ref, i > 2 ? i - 1 : i),
                          ),
                        ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.label, this.icon);
  final String label;
  final IconData icon;
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.item,
    required this.index,
    required this.selected,
    required this.onTap,
  });

  final _NavItem item;
  final int index;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: selected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows the Quick Add bottom sheet (add memory, note, intimacy, event).
/// Used by shell FAB and by swipe-up on the home insight widget.
void showQuickAddSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => _QuickAddSheet(parentContext: context),
  );
}

class _QuickAddSheet extends ConsumerWidget {
  const _QuickAddSheet({required this.parentContext});

  final BuildContext parentContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSp = ref.watch(currentXpProvider);
    final isPremium = ref.watch(isPremiumProvider).valueOrNull ?? false;
    final memoriesUnlocked = ProgressionPlan.isFeatureUnlocked(
      FeatureID.memories,
      currentSp,
      isPremium,
    );

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 6,
            margin: const EdgeInsets.only(bottom: AppSpacing.lg),
            decoration: BoxDecoration(
              color: context.colors.textSecondary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          Text(
            context.l10n.appRouterQuickActionsHeading,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: context.colors.text,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              _QuickActionChip(
                icon: PhosphorIconsBold.chatTeardropText,
                label: context.l10n.appRouterQuickActionAddNote,
                navigationRoute: '/add-note',
              ),
              _QuickActionChip(
                icon: PhosphorIconsBold.camera,
                label: context.l10n.appRouterQuickActionAddMemory,
                navigationRoute: memoriesUnlocked ? '/add-memory' : null,
                onTap: memoriesUnlocked
                    ? null
                    : () {
                        showLevelUpUnlockSheet(
                          parentContext,
                          ref,
                          FeatureID.memories,
                        );
                      },
              ),
              _QuickActionChip(
                icon: PhosphorIconsBold.heart,
                label: context.l10n.appRouterQuickActionLogIntimacy,
                onTap: () {
                  AddIntimacySheet.show(context);
                },
              ),
              _QuickActionChip(
                icon: PhosphorIconsBold.calendarPlus,
                label: context.l10n.appRouterQuickActionAddEvent,
                onTap: () {
                  AddEventSheet.show(context);
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
    required this.icon,
    required this.label,
    this.onTap,
    this.navigationRoute,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final String? navigationRoute;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.background,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          // Get the GoRouter instance before closing the sheet
          // This ensures we have access to it even after the sheet closes
          final router = GoRouter.of(context);
          // Close the bottom sheet
          Navigator.of(context).pop();
          // Execute navigation or callback after sheet animation completes
          Future.delayed(const Duration(milliseconds: 200), () {
            if (navigationRoute != null) {
              router.push(navigationRoute!);
            } else if (onTap != null) {
              onTap!();
            }
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: context.colors.primary, size: 18),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: context.colors.text,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

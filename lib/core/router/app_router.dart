import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../features/auth/presentation/auth_providers.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/firebase_test_screen.dart';
import '../../features/auth/presentation/pairing_screen.dart';
import '../../features/dashboard/presentation/screens/home_screen.dart';
import '../../features/timeline/presentation/screens/timeline_screen.dart';
import '../../features/timeline/presentation/screens/add_memory_screen.dart';
import '../../features/tracker/presentation/data_screen.dart';
import '../../features/tracker/presentation/widgets/add_intimacy_sheet.dart';
import '../../features/lists/lists_screen.dart';
import '../../features/lists/settings_screen.dart';
import '../../features/notes/presentation/screens/add_note_screen.dart';
import '../../features/auth/presentation/profile_screen.dart';
import '../../features/notes/presentation/screens/secret_notes_screen.dart';
import '../../models/note_item.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  // Watch auth state - Stream<User?>
  final authState = ref.watch(authStateProvider);
  // Watch user data - Stream<UserModel?>
  final userState = ref.watch(userProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      // Get current auth state
      final firebaseUser = authState.valueOrNull;
      final isAuthenticated = firebaseUser != null;
      
      // Get current user data (UserModel from Firestore)
      final userModel = userState.valueOrNull;
      final hasCoupleId = userModel?.coupleId != null && userModel!.coupleId!.isNotEmpty;
      
      // Define public routes (don't require authentication)
      final isPublicRoute = state.matchedLocation == '/login' || 
                           state.matchedLocation == '/register' ||
                           state.matchedLocation == '/firebase-test';
      
      // Define pairing route (requires auth but not pairing)
      final isPairingRoute = state.matchedLocation == '/pairing';
      
      // Define protected routes (require both auth and pairing)
      final isProtectedRoute = !isPublicRoute && !isPairingRoute;

      // If no user, redirect to login (unless already on public route)
      if (!isAuthenticated) {
        return isPublicRoute ? null : '/login';
      }

      // User is authenticated - check if still loading user data
      if (userState.isLoading) {
        return null; // Wait for user data to load
      }

      // If user but no coupleId, redirect to pairing (unless already on pairing/login/register)
      if (!hasCoupleId) {
        return (isPairingRoute || isPublicRoute) ? null : '/pairing';
      }

      // User has coupleId - if on login/register/pairing, redirect to home shell
      if (isPublicRoute || isPairingRoute) {
        return '/home';
      }

      // Both user and coupleId exist, allow access to protected routes (home shell)
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/firebase-test',
        name: 'firebase-test',
        builder: (context, state) => const FirebaseTestScreen(),
      ),
      GoRoute(
        path: '/pairing',
        name: 'pairing',
        builder: (context, state) => const PairingScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/secret-notes',
        name: 'secret-notes',
        builder: (context, state) => const SecretNotesScreen(),
      ),
      GoRoute(
        path: '/add-memory',
        name: 'add-memory',
        builder: (context, state) => const AddMemoryScreen(),
      ),
      GoRoute(
        path: '/add-note',
        name: 'add-note',
        builder: (context, state) {
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
          return AddNoteScreen(initialType: initialType);
        },
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
                path: '/lists',
                name: 'lists',
                builder: (context, state) => const ListsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}


class RootShell extends StatelessWidget {
  const RootShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTabSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem('Home', PhosphorIconsBold.house),
      _NavItem('Memory', PhosphorIconsBold.clockCounterClockwise),
      _NavItem('Data', PhosphorIconsBold.chartPieSlice),
      _NavItem('Lists', PhosphorIconsBold.listChecks),
    ];

    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: DecoratedBox(
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (int i = 0; i < items.length + 1; i++)
                  if (i == 2)
                    // Insert the add button as a big round button in the center, in line with other nav items
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Material(
                        color: AppTheme.colors.primary,
                        shape: const CircleBorder(),
                        elevation: 4,
                        shadowColor: AppTheme.colors.shadow,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () {
                            showModalBottomSheet<void>(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(24)),
                              ),
                              builder: (context) => const _QuickAddSheet(),
                            );
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
                    // Render the nav item for Home/Memory/Data/Lists (skip slot 2 for add btn)
                    Expanded(
                      child: _BottomNavItem(
                        item: items[i > 2 ? i - 1 : i],
                        index: i > 2 ? i - 1 : i,
                        selected: navigationShell.currentIndex == (i > 2 ? i - 1 : i),
                        onTap: () => _onTabSelected(i > 2 ? i - 1 : i),
                      ),
                    ),
              ],
            ),
          ),
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
                  ? AppTheme.colors.primary
                  : AppTheme.colors.textSecondary,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: selected
                        ? AppTheme.colors.primary
                        : AppTheme.colors.textSecondary,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAddSheet extends StatelessWidget {
  const _QuickAddSheet();

  @override
  Widget build(BuildContext context) {
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
              color: AppTheme.colors.textSecondary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          Text(
            'Quick actions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.colors.text,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              _QuickActionChip(
                icon: PhosphorIconsBold.chatTeardropText,
                label: 'Add note',
                navigationRoute: '/add-note',
              ),
              _QuickActionChip(
                icon: PhosphorIconsBold.camera,
                label: 'Add memory',
                navigationRoute: '/add-memory',
              ),
              _QuickActionChip(
                icon: PhosphorIconsBold.heart,
                label: 'Log intimacy',
                onTap: () {
                  AddIntimacySheet.show(context);
                },
              ),
              _QuickActionChip(
                icon: PhosphorIconsBold.shoppingCartSimple,
                label: 'List item',
                onTap: () {
                  // TODO: Implement add list item
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
      color: AppTheme.colors.background,
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
              Icon(icon, color: AppTheme.colors.primary, size: 18),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppTheme.colors.text,
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

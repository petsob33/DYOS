import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firebase_service.dart';
import '../../../features/auth/presentation/auth_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _handleDeleteAccount(BuildContext context, WidgetRef ref) async {
    // Show confirmation dialog with warning
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Text(
          'Delete Account',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.colors.love,
              ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This action cannot be undone. This will permanently delete:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.colors.text,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '• Your account and profile\n'
              '• All your memories and photos\n'
              '• All intimacy logs and data\n'
              '• Your pairing (partner will be unpaired)\n'
              '• All notes and lists',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.colors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Are you absolutely sure?',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.colors.love,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.colors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.colors.love,
            ),
            child: const Text(
              'Delete Forever',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    try {
      // Show loading indicator
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: AppSpacing.md),
                Text('Deleting account...'),
              ],
            ),
          ),
        );
      }

      // Delete account and all data
      final firebaseService = ref.read(firebaseServiceProvider);
      await firebaseService.deleteAccount();

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Navigate to login screen
      if (context.mounted) {
        context.go('/login');
      }
    } catch (e) {
      // Close loading dialog if still open
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting account: ${e.toString()}'),
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

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.colors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.colors.love,
            ),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

    try {
      // Show loading indicator
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      // Sign out from Firebase Auth
      // This will clear the authentication session
      final authService = ref.read(authServiceProvider);
      await authService.signOut();

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Navigate to login screen
      // The router will automatically redirect when auth state changes,
      // but we'll navigate explicitly to ensure it happens
      if (context.mounted) {
        context.go('/login');
      }
    } catch (e) {
      // Close loading dialog if still open
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error logging out: ${e.toString()}'),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppTheme.colors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.colors.text,
                    ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Pairing button
              Material(
                color: AppTheme.colors.card,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () async {
                    // Check if user is already paired
                    final isPairedAsync = ref.read(isUserPairedProvider);
                    final isPaired = await isPairedAsync.when(
                      data: (value) => value ?? false,
                      loading: () => false,
                      error: (_, __) => false,
                    );
                    
                    // If already paired, go to home page
                    // Otherwise, go to pairing page
                    if (isPaired) {
                      if (context.mounted) {
                        context.go('/home');
                      }
                    } else {
                      if (context.mounted) {
                        context.push('/pairing');
                      }
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        Icon(
                          PhosphorIconsBold.heart,
                          color: AppTheme.colors.primary,
                          size: 24,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pairing',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.colors.text,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Manage your pairing',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppTheme.colors.textSecondary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          PhosphorIconsBold.caretRight,
                          color: AppTheme.colors.textSecondary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // Delete Account button
              Material(
                color: AppTheme.colors.card,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _handleDeleteAccount(context, ref),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        Icon(
                          PhosphorIconsBold.trash,
                          color: AppTheme.colors.love,
                          size: 24,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Delete Account',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.colors.love,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Permanently delete your account',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppTheme.colors.textSecondary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          PhosphorIconsBold.caretRight,
                          color: AppTheme.colors.textSecondary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // Logout button
              Material(
                color: AppTheme.colors.card,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _handleLogout(context, ref),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        Icon(
                          PhosphorIconsBold.signOut,
                          color: AppTheme.colors.love,
                          size: 24,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Log out',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.colors.text,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Sign out and clear session',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppTheme.colors.textSecondary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          PhosphorIconsBold.caretRight,
                          color: AppTheme.colors.textSecondary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

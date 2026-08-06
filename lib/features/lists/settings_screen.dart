import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_mode_provider.dart';
import '../../../core/l10n/locale_provider.dart';
import '../../core/l10n/build_context_l10n_extension.dart';
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
          context.l10n.settingsScreenDeleteAccountTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: context.colors.love,
              ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.settingsScreenDeleteAccountWarning,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.colors.text,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              context.l10n.settingsScreenDeleteAccountBulletList,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.colors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              context.l10n.settingsScreenDeleteAccountConfirmQuestion,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.colors.love,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              context.l10n.commonCancel,
              style: TextStyle(color: context.colors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: context.colors.love,
            ),
            child: Text(
              context.l10n.settingsScreenDeleteForever,
              style: const TextStyle(fontWeight: FontWeight.w700),
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
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: AppSpacing.md),
                Text(context.l10n.settingsScreenDeletingAccount),
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
            content: Text(context.l10n.settingsScreenDeleteAccountError(e.toString())),
            backgroundColor: context.colors.love,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> _handleSetAnniversaryDate(BuildContext context, WidgetRef ref) async {
    final userAsync = ref.read(userProvider);
    final user = await userAsync.when(
      data: (u) => u,
      loading: () => null,
      error: (_, __) => null,
    );

    if (user == null || user.coupleId == null || user.coupleId!.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.settingsScreenMustBePairedForAnniversary),
            backgroundColor: context.colors.love,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
      return;
    }

    // Get current anniversary date
    final coupleAsync = ref.read(currentCoupleProvider);
    final couple = await coupleAsync.when(
      data: (c) => c,
      loading: () => null,
      error: (_, __) => null,
    );

    final initialDate = couple?.anniversaryDate ?? DateTime.now();
    final firstDate = DateTime(1900);
    final lastDate = DateTime.now();

    // Show date picker
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: context.l10n.settingsScreenSelectAnniversaryDateHelp,
      cancelText: context.l10n.commonCancel,
      confirmText: context.l10n.settingsScreenSetAnniversaryConfirm,
    );

    if (pickedDate == null || !context.mounted) return;

    try {
      // Update anniversary date in Firestore
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('couples').doc(user.coupleId!).update({
        'anniversaryDate': Timestamp.fromDate(pickedDate),
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.settingsScreenAnniversaryUpdated),
            backgroundColor: context.colors.success,
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
            content: Text(context.l10n.settingsScreenAnniversaryUpdateError(e.toString())),
            backgroundColor: context.colors.love,
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
        title: Text(context.l10n.settingsScreenLogOut),
        content: Text(context.l10n.settingsScreenLogoutConfirmQuestion),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              context.l10n.commonCancel,
              style: TextStyle(color: context.colors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: context.colors.love,
            ),
            child: Text(context.l10n.settingsScreenLogOut),
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
            content: Text(context.l10n.settingsScreenLogoutError(e.toString())),
            backgroundColor: context.colors.love,
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(context.l10n.settingsScreenTitle),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.settingsScreenTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.colors.text,
                    ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Anniversary Date button
              Consumer(
                builder: (context, ref, child) {
                  final coupleAsync = ref.watch(currentCoupleProvider);
                  return coupleAsync.when(
                    data: (couple) {
                      final anniversaryDate = couple?.anniversaryDate;
                      final daysTogether = anniversaryDate != null
                          ? DateTime.now().difference(anniversaryDate).inDays
                          : null;

                      return Material(
                        color: context.colors.card,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => _handleSetAnniversaryDate(context, ref),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Row(
                              children: [
                                Icon(
                                  PhosphorIconsBold.calendarHeart,
                                  color: context.colors.primary,
                                  size: 24,
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        context.l10n.settingsScreenAnniversaryDateLabel,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: context.colors.text,
                                            ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        anniversaryDate != null
                                            ? '${anniversaryDate.year}-${anniversaryDate.month.toString().padLeft(2, '0')}-${anniversaryDate.day.toString().padLeft(2, '0')}${daysTogether != null ? ' • ${context.l10n.settingsScreenDaysTogether(daysTogether)}' : ''}'
                                            : context.l10n.settingsScreenSetAnniversaryDatePrompt,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: context.colors.textSecondary,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  PhosphorIconsBold.caretRight,
                                  color: context.colors.textSecondary,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    loading: () => Material(
                      color: context.colors.card,
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Row(
                          children: [
                            Icon(
                              PhosphorIconsBold.calendarHeart,
                              color: context.colors.primary,
                              size: 24,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    context.l10n.settingsScreenAnniversaryDateLabel,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: context.colors.text,
                                        ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    context.l10n.settingsScreenLoading,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: context.colors.textSecondary,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.md),
              // Appearance (theme mode) card
              Material(
                color: context.colors.card,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            PhosphorIconsBold.moon,
                            color: context.colors.primary,
                            size: 24,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Text(
                            context.l10n.settingsScreenAppearanceLabel,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: context.colors.text,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Consumer(
                        builder: (context, ref, child) {
                          final currentMode = ref
                                  .watch(themeModeControllerProvider)
                                  .valueOrNull ??
                              ThemeMode.system;
                          return SegmentedButton<ThemeMode>(
                            segments: [
                              ButtonSegment(
                                value: ThemeMode.light,
                                label: Text(context.l10n.settingsScreenThemeLight),
                              ),
                              ButtonSegment(
                                value: ThemeMode.dark,
                                label: Text(context.l10n.settingsScreenThemeDark),
                              ),
                              ButtonSegment(
                                value: ThemeMode.system,
                                label: Text(context.l10n.settingsScreenThemeSystem),
                              ),
                            ],
                            selected: {currentMode},
                            onSelectionChanged: (selection) {
                              ref
                                  .read(themeModeControllerProvider.notifier)
                                  .setMode(selection.first);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // Language card
              Material(
                color: context.colors.card,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            PhosphorIconsBold.translate,
                            color: context.colors.primary,
                            size: 24,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Text(
                            'Language',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: context.colors.text,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Consumer(
                        builder: (context, ref, child) {
                          final currentLocale =
                              ref.watch(localeControllerProvider).valueOrNull;
                          return SegmentedButton<Locale?>(
                            segments: const [
                              ButtonSegment(
                                value: null,
                                label: Text('System'),
                              ),
                              ButtonSegment(
                                value: Locale('cs'),
                                label: Text('Čeština'),
                              ),
                              ButtonSegment(
                                value: Locale('en'),
                                label: Text('English'),
                              ),
                            ],
                            selected: {currentLocale},
                            onSelectionChanged: (selection) {
                              ref
                                  .read(localeControllerProvider.notifier)
                                  .setLocale(selection.first);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // Pairing button
              Material(
                color: context.colors.card,
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
                          color: context.colors.primary,
                          size: 24,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.l10n.settingsScreenPairingLabel,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: context.colors.text,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                context.l10n.settingsScreenPairingSubtitle,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: context.colors.textSecondary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          PhosphorIconsBold.caretRight,
                          color: context.colors.textSecondary,
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
                color: context.colors.card,
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
                          color: context.colors.love,
                          size: 24,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.l10n.settingsScreenDeleteAccountTitle,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: context.colors.love,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                context.l10n.settingsScreenDeleteAccountSubtitle,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: context.colors.textSecondary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          PhosphorIconsBold.caretRight,
                          color: context.colors.textSecondary,
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
                color: context.colors.card,
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
                          color: context.colors.love,
                          size: 24,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.l10n.settingsScreenLogOut,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: context.colors.text,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                context.l10n.settingsScreenLogoutSubtitle,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: context.colors.textSecondary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          PhosphorIconsBold.caretRight,
                          color: context.colors.textSecondary,
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

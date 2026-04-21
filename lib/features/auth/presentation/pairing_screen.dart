import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/services/pairing_exceptions.dart';
import '../../../core/services/auth_service.dart';
import 'auth_providers.dart';

class PairingScreen extends ConsumerStatefulWidget {
  const PairingScreen({super.key});

  @override
  ConsumerState<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends ConsumerState<PairingScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.colors.love),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(authServiceProvider).signOut();
      if (mounted) context.go('/login');
    }
  }

  Future<void> _submitEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final firebaseService = ref.read(firebaseServiceProvider);
      final email = _emailController.text.trim();
      final result = await firebaseService.pairWithEmail(email);

      ref.read(pairingConfirmedCoupleIdProvider.notifier).state = result.coupleId;

      if (mounted) {
        final name = result.partnerDisplayName?.isNotEmpty == true
            ? result.partnerDisplayName!
            : email;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Paired with $name!'),
            backgroundColor: AppTheme.colors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 2),
          ),
        );
        context.go('/home');
      }
    } on PairingException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: AppTheme.colors.love,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Unable to pair right now. Check your connection.';
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage!),
            backgroundColor: AppTheme.colors.love,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      appBar: AppBar(
        title: const Text('Connect with Partner'),
        actions: [
          IconButton(
            icon: const Icon(PhosphorIconsBold.signOut),
            onPressed: _signOut,
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Icon(
                  PhosphorIconsBold.heart,
                  size: 80,
                  color: AppTheme.colors.primary,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Enter your partner\'s email',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.colors.text,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Both of you must already have an account',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.colors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'partner@email.com',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: AppTheme.colors.textSecondary.withOpacity(0.2),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: AppTheme.colors.textSecondary.withOpacity(0.2),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: AppTheme.colors.primary, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: AppTheme.colors.love, width: 2),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: AppTheme.colors.love, width: 2),
                    ),
                    filled: true,
                    fillColor: AppTheme.colors.card,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.md,
                    ),
                    prefixIcon: Icon(
                      PhosphorIconsBold.envelope,
                      color: AppTheme.colors.primary,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an email address';
                    }
                    final email = value.trim().toLowerCase();
                    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
                      return 'Enter a valid email address';
                    }
                    final currentEmail = ref
                        .read(firebaseServiceProvider)
                        .currentUser
                        ?.email
                        ?.toLowerCase();
                    if (currentEmail != null && email == currentEmail) {
                      return 'You cannot pair with yourself';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.colors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Pair',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                        ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

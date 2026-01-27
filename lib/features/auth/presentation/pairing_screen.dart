import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/bento_card.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/services/pairing_exceptions.dart';
import 'auth_providers.dart';

class PairingScreen extends ConsumerStatefulWidget {
  const PairingScreen({super.key});

  @override
  ConsumerState<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends ConsumerState<PairingScreen> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  bool _isLoading = true;
  String? _userCode;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _checkPairingStatus();
  }

  void _checkPairingStatus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listen(isUserPairedProvider, (previous, next) {
        next.whenData((isPaired) {
          if (isPaired == true && mounted) {
            context.go('/home');
          }
        });
      });
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final firebaseService = ref.read(firebaseServiceProvider);
      final currentUser = firebaseService.currentUser;
      
      if (currentUser == null) {
        if (mounted) {
          setState(() {
            _errorMessage = 'User is not signed in';
            _isLoading = false;
          });
        }
        return;
      }

      var userData = await firebaseService.getUserData();

      if (userData == null) {
        final displayName = currentUser.displayName ?? 'User';
        userData = await firebaseService.createOrUpdateUser(
          uid: currentUser.uid,
          email: currentUser.email ?? '',
          displayName: displayName,
          photoUrl: currentUser.photoURL,
        );
      } else if (userData.inviteCode == null || userData.inviteCode!.isEmpty) {
        userData = await firebaseService.createOrUpdateUser(
          uid: currentUser.uid,
          email: userData.email,
          displayName: userData.displayName ?? 'User',
          photoUrl: userData.photoUrl,
        );
      }

      if (mounted) {
        setState(() {
          _userCode = userData?.inviteCode ?? 'N/A';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading data: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  void _copyCode() {
    if (_userCode == null || _userCode == 'N/A') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Code is not available'),
          backgroundColor: AppTheme.colors.love,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    Clipboard.setData(ClipboardData(text: _userCode!));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Code copied'),
        backgroundColor: AppTheme.colors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _submitCode() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final firebaseService = ref.read(firebaseServiceProvider);
      final currentUser = firebaseService.currentUser;

      if (currentUser == null) {
        throw Exception('User is not signed in');
      }

      final partnerCode = _codeController.text.trim().toUpperCase();
      final partnerUser = await firebaseService.findUserByInviteCode(partnerCode);

      if (partnerUser == null) {
        throw PartnerNotFoundException();
      }

      await firebaseService.pairUsers(currentUser.uid, partnerUser.uid);

      // Wait a bit for Firestore to sync and router to see the change
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully paired with ${partnerUser.displayName ?? partnerCode}!'),
            backgroundColor: AppTheme.colors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error pairing. Please try again.';
          _isSubmitting = false;
        });
      }
    }

    if (_errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage!),
          backgroundColor: AppTheme.colors.love,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.colors.background,
        appBar: AppBar(
          title: const Text('Pairing'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null && _userCode == null) {
      return Scaffold(
        backgroundColor: AppTheme.colors.background,
        appBar: AppBar(
          title: const Text('Pairing'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  PhosphorIconsBold.warning,
                  size: 64,
                  color: AppTheme.colors.love,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  _errorMessage ?? 'Error',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.colors.text,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton(
                  onPressed: _loadUserData,
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      appBar: AppBar(
        title: const Text('Pairing'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.xl),
                Icon(
                  PhosphorIconsBold.heart,
                  size: 80,
                  color: AppTheme.colors.primary,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Connect with your partner',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.colors.text,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Share your code or enter your partner\'s code',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.colors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                BentoCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            PhosphorIconsBold.user,
                            color: AppTheme.colors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Your code',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: AppTheme.colors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _userCode ?? 'Loading...',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.colors.primary,
                                    letterSpacing: 2,
                                  ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(PhosphorIconsBold.copy),
                            onPressed: _copyCode,
                            color: AppTheme.colors.primary,
                            tooltip: 'Copy',
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Share this code with your partner',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppTheme.colors.textSecondary,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: AppTheme.colors.textSecondary.withOpacity(0.2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      child: Text(
                        'or',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.colors.textSecondary,
                            ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: AppTheme.colors.textSecondary.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Enter partner\'s code',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppTheme.colors.text,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _codeController,
                  decoration: InputDecoration(
                    hintText: 'e.g. ANNA-1234',
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
                      borderSide: BorderSide(
                        color: AppTheme.colors.primary,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: AppTheme.colors.love,
                        width: 2,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: AppTheme.colors.love,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: AppTheme.colors.card,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.md,
                    ),
                    prefixIcon: Icon(
                      PhosphorIconsBold.key,
                      color: AppTheme.colors.primary,
                    ),
                  ),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a code';
                    }
                    final normalizedValue = value.trim().toUpperCase();
                    if (_userCode != null && normalizedValue == _userCode) {
                      return 'You cannot pair with yourself';
                    }
                    final pattern = RegExp(r'^[A-Z]+-\d+$');
                    if (!pattern.hasMatch(normalizedValue)) {
                      return 'Invalid code format (e.g. PETR-8821)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.colors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
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
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Pair',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
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

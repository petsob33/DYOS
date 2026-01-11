import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/bento_card.dart';
import '../../../core/services/firebase_service.dart';
import '../domain/user_model.dart';
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
  String? _userName;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Load user data when screen initializes
    _loadUserData();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  /// Load current user's data to display their invite code
  /// 
  /// This fetches the user document from Firestore to get:
  /// - The user's invite code (to display and share)
  /// - The user's display name (for personalization)
  /// 
  /// If the user doesn't have an inviteCode (e.g., old account),
  /// it will be automatically generated and saved.
  Future<void> _loadUserData() async {
    try {
      final firebaseService = ref.read(firebaseServiceProvider);
      final currentUser = firebaseService.currentUser;
      
      // Safety check: ensure user is authenticated
      if (currentUser == null) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Uživatel není přihlášen';
            _isLoading = false;
          });
        }
        return;
      }

      // Get user data from Firestore
      var userData = await firebaseService.getUserData();

      // If user document doesn't exist, create it with inviteCode
      // This can happen if user was created before we added inviteCode generation
      if (userData == null) {
        // Try to create user document using createOrUpdateUser
        // This will generate inviteCode automatically
        final displayName = currentUser.displayName ?? 'User';
        userData = await firebaseService.createOrUpdateUser(
          uid: currentUser.uid,
          email: currentUser.email ?? '',
          displayName: displayName,
          photoUrl: currentUser.photoURL,
        );
      } 
      // If user exists but doesn't have inviteCode, generate and save it
      else if (userData.inviteCode == null || userData.inviteCode!.isEmpty) {
        // Use createOrUpdateUser to generate missing inviteCode
        userData = await firebaseService.createOrUpdateUser(
          uid: currentUser.uid,
          email: userData.email,
          displayName: userData.displayName ?? 'User',
          photoUrl: userData.photoUrl,
        );
      }

      // Update UI with user data
      if (mounted) {
        setState(() {
          _userCode = userData?.inviteCode ?? 'N/A';
          _userName = userData?.displayName ?? 'Uživatel';
          _isLoading = false;
        });
      }
    } catch (e) {
      // Handle errors gracefully
      if (mounted) {
        setState(() {
          _errorMessage = 'Chyba při načítání dat: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  /// Copy the user's invite code to clipboard
  /// 
  /// Shows a snackbar confirmation when the code is copied.
  void _copyCode() {
    if (_userCode == null || _userCode == 'N/A') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Kód není k dispozici'),
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
        content: const Text('Kód zkopírován'),
        backgroundColor: AppTheme.colors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Submit partner's invite code to create a pair
  /// 
  /// This method:
  /// 1. Validates the input code
  /// 2. Finds the partner user by their invite code
  /// 3. Creates a couple document in Firestore
  /// 4. Updates both users with the coupleId
  /// 5. Redirects to home page on success
  /// 
  /// Shows error messages if pairing fails.
  Future<void> _submitCode() async {
    // Validate form first
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

      // Safety check: ensure user is authenticated
      if (currentUser == null) {
        throw Exception('Uživatel není přihlášen');
      }

      // Get the entered code and normalize it (uppercase)
      final partnerCode = _codeController.text.trim().toUpperCase();

      // Safety check: prevent pairing with yourself
      if (partnerCode == _userCode) {
        throw Exception('Nemůžete se spárovat sami se sebou');
      }

      // Find partner user by their invite code
      final partnerUser = await firebaseService.findUserByInviteCode(partnerCode);

      if (partnerUser == null) {
        throw Exception('Uživatel s tímto kódem nebyl nalezen');
      }

      // Safety check: verify partner is not already paired
      if (partnerUser.coupleId != null && partnerUser.coupleId!.isNotEmpty) {
        throw Exception('Tento uživatel je již spárovaný');
      }

      // Create the pair - this will create the couple document and update both users
      await firebaseService.pairUsers(currentUser.uid, partnerUser.uid);

      // Refresh the pairing status provider to get updated status
      // This ensures the router sees the updated pairing status before navigation
      await ref.refresh(isUserPairedProvider.future);

      // Success! Show success message and redirect to home
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Úspěšně spárováno s ${partnerUser.displayName ?? partnerCode}!'),
            backgroundColor: AppTheme.colors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 2),
          ),
        );

        // Redirect to home page after successful pairing
        // Use go() to replace the current route so user can't go back to pairing
        // The router will now see that the user is paired and allow navigation
        context.go('/home');
      }
    } catch (e) {
      // Handle errors and show user-friendly message
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isSubmitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage ?? 'Chyba při spárování'),
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
  }

  @override
  Widget build(BuildContext context) {
    // Show loading state while fetching user data
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.colors.background,
        appBar: AppBar(
          title: const Text('Spárování'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Show error state if user data couldn't be loaded
    if (_errorMessage != null && _userCode == null) {
      return Scaffold(
        backgroundColor: AppTheme.colors.background,
        appBar: AppBar(
          title: const Text('Spárování'),
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
                  _errorMessage ?? 'Chyba',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.colors.text,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton(
                  onPressed: _loadUserData,
                  child: const Text('Zkusit znovu'),
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
        title: const Text('Spárování'),
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
                // Icon
                Icon(
                  PhosphorIconsBold.heart,
                  size: 80,
                  color: AppTheme.colors.primary,
                ),
                const SizedBox(height: AppSpacing.lg),
                // Title
                Text(
                  'Propojte se s partnerem',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.colors.text,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Sdílejte svůj kód nebo zadejte kód partnera',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.colors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                // Your code card
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
                            'Váš kód',
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
                              _userCode ?? 'Načítání...',
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
                            tooltip: 'Kopírovat',
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Sdílejte tento kód se svým partnerem',
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
                // Divider with "OR"
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
                        'nebo',
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
                // Partner code input
                Text(
                  'Zadejte kód partnera',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppTheme.colors.text,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _codeController,
                  decoration: InputDecoration(
                    hintText: 'např. ANNA-1234',
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
                      return 'Zadejte prosím kód';
                    }
                    final normalizedValue = value.trim().toUpperCase();
                    if (_userCode != null && normalizedValue == _userCode) {
                      return 'Nemůžete se spárovat sami se sebou';
                    }
                    // Basic format validation (LETTERS-NUMBERS)
                    // Format: NAME-1234 (e.g., PETR-8821, ANNA-1234)
                    final pattern = RegExp(r'^[A-Z]+-\d+$');
                    if (!pattern.hasMatch(normalizedValue)) {
                      return 'Neplatný formát kódu (např. PETR-8821)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                // Submit button
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
                          'Spárovat',
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

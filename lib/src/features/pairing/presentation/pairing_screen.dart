import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/bento_card.dart';

class PairingScreen extends StatefulWidget {
  const PairingScreen({super.key});

  @override
  State<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends State<PairingScreen> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // Mock username - in real app this would come from user data
  final String _username = 'Petr';
  final String _userCode = 'PETR-8821';

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _copyCode() {
    Clipboard.setData(ClipboardData(text: _userCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Kód zkopírován'),
        backgroundColor: AppTheme.colors.card,
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
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });

      // TODO: Handle pairing logic
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Spárování s ${_codeController.text.trim()}...'),
          backgroundColor: AppTheme.colors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                              _userCode,
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
                    if (value.trim() == _userCode) {
                      return 'Nemůžete se spárovat sami se sebou';
                    }
                    // Basic format validation (LETTERS-NUMBERS)
                    final pattern = RegExp(r'^[A-Z]+-\d+$');
                    if (!pattern.hasMatch(value.trim().toUpperCase())) {
                      return 'Neplatný formát kódu';
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

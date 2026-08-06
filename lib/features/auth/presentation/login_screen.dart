import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/l10n/build_context_l10n_extension.dart';
import '../../../core/services/auth_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      await authService.signInWithGoogle();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Show forgot password dialog
  ///
  /// Displays a dialog where user can enter their email to receive
  /// a password reset link.
  Future<void> _showForgotPasswordDialog(BuildContext context) async {
    final emailController = TextEditingController(text: _emailController.text);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Text(
          context.l10n.loginScreenResetPasswordTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: context.colors.text,
              ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.loginScreenResetPasswordBody,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.colors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: context.l10n.loginScreenEmailLabel,
                hintText: context.l10n.loginScreenEmailHint,
                prefixIcon: Icon(
                  PhosphorIconsBold.envelope,
                  color: context.colors.textSecondary,
                ),
                filled: true,
                fillColor: context.colors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
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
            onPressed: () {
              if (emailController.text.trim().isNotEmpty &&
                  emailController.text.contains('@')) {
                Navigator.of(context).pop(true);
              }
            },
            child: Text(
              context.l10n.loginScreenSendButton,
              style: TextStyle(
                color: context.colors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (result == true && emailController.text.trim().isNotEmpty) {
      try {
        final authService = ref.read(authServiceProvider);
        await authService.sendPasswordResetEmail(emailController.text.trim());

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.loginScreenResetEmailSent),
              backgroundColor: context.colors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.loginScreenGenericError(e.toString())),
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
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      await authService.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } catch (e) {
      if (e.toString().contains('No user found for that email')) {
        final result = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(context.l10n.loginScreenAccountNotFoundTitle),
            content: Text(context.l10n.loginScreenAccountNotFoundBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(context.l10n.commonCancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(context.l10n.loginScreenRegisterAction),
              ),
            ],
          ),
        );

        if (result == true) {
          context.go('/register?email=${_emailController.text}');
        }
      } else {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          behavior: HitTestBehavior.opaque,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.xxl),

                Icon(
                  PhosphorIconsBold.heart,
                  size: 80,
                  color: context.colors.primary,
                ),
                const SizedBox(height: AppSpacing.lg),

                Text(
                  context.l10n.loginScreenWelcomeBack,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: context.colors.text,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),

                Text(
                  context.l10n.loginScreenSignInToContinue,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: context.colors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxl),

                GestureDetector(
                  onTap: () {
                    _emailFocusNode.requestFocus();
                    SystemChannels.textInput.invokeMethod('TextInput.show');
                  },
                  child: TextFormField(
                    controller: _emailController,
                    focusNode: _emailFocusNode,
                    enabled: true,
                    readOnly: false,
                    canRequestFocus: true,
                    enableInteractiveSelection: true,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofocus: false,
                    onTap: () {
                      _emailFocusNode.requestFocus();
                      SystemChannels.textInput.invokeMethod('TextInput.show');
                    },
                    onFieldSubmitted: (_) {
                      _passwordFocusNode.requestFocus();
                    },
                  decoration: InputDecoration(
                    labelText: context.l10n.loginScreenEmailLabel,
                    prefixIcon: Icon(
                      PhosphorIconsBold.envelope,
                      color: context.colors.textSecondary,
                    ),
                    filled: true,
                    fillColor: context.colors.card,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: context.colors.love,
                        width: 1,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.l10n.loginScreenEmailRequired;
                    }
                    if (!value.contains('@')) {
                      return context.l10n.loginScreenEmailInvalid;
                    }
                    return null;
                  },
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                GestureDetector(
                  onTap: () {
                    _passwordFocusNode.requestFocus();
                    SystemChannels.textInput.invokeMethod('TextInput.show');
                  },
                  child: TextFormField(
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    enabled: true,
                    readOnly: false,
                    canRequestFocus: true,
                    enableInteractiveSelection: true,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onTap: () {
                      _passwordFocusNode.requestFocus();
                      SystemChannels.textInput.invokeMethod('TextInput.show');
                    },
                    onFieldSubmitted: (_) => _handleLogin(),
                  decoration: InputDecoration(
                    labelText: context.l10n.loginScreenPasswordLabel,
                    prefixIcon: Icon(
                      PhosphorIconsBold.lock,
                      color: context.colors.textSecondary,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? PhosphorIconsBold.eyeSlash
                            : PhosphorIconsBold.eye,
                        color: context.colors.textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: context.colors.card,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: context.colors.love,
                        width: 1,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.l10n.loginScreenPasswordRequired;
                    }
                    if (value.length < 6) {
                      return context.l10n.loginScreenPasswordTooShort;
                    }
                    return null;
                  },
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _isLoading ? null : () => _showForgotPasswordDialog(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                    ),
                    child: Text(
                      context.l10n.loginScreenForgotPassword,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.colors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: context.colors.love.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          PhosphorIconsBold.warning,
                          color: context.colors.love,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: context.colors.love,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: AppSpacing.lg),

                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          context.l10n.loginScreenSignInButton,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                ),
                const SizedBox(height: AppSpacing.lg),

                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: context.colors.textSecondary.withOpacity(0.3),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: Text(
                        context.l10n.loginScreenOrDivider,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: context.colors.textSecondary,
                            ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: context.colors.textSecondary.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _handleGoogleSignIn,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.colors.text,
                    side: BorderSide(
                      color: context.colors.textSecondary.withOpacity(0.3),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: Icon(
                    PhosphorIconsBold.googleLogo,
                    size: 20,
                    color: context.colors.text,
                  ),
                  label: Text(
                    context.l10n.loginScreenContinueWithGoogle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: context.colors.text,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      context.l10n.loginScreenNoAccountPrompt,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: context.colors.textSecondary,
                          ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.go('/register');
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                        ),
                      ),
                      child: Text(
                        context.l10n.loginScreenSignUpButton,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: context.colors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }
}

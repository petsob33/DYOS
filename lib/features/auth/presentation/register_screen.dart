import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

/// Register Screen
/// 
/// This screen allows new users to create an account.
/// Users can navigate here from the login screen.
/// 
/// Features:
/// - Name, email, password, and confirm password input fields
/// - Form validation (email format, password strength, password match)
/// - Password visibility toggles for both password fields
/// - Error message display
/// - Loading state during registration
/// - Link back to login screen
/// - Back button to return to login
/// 
/// After successful registration:
/// - Firebase Auth account is created
/// - User document is created in Firestore
/// - User is automatically redirected to home screen
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

/// State class for RegisterScreen
/// 
/// Manages:
/// - Form state and validation
/// - Text field controllers (name, email, password, confirm password)
/// - Loading state
/// - Password visibility toggles (for both password fields)
/// - Error messages
class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  /// Form key for validation
  /// Used to trigger form validation and access form state
  final _formKey = GlobalKey<FormState>();
  
  /// Controller for name input field
  final _nameController = TextEditingController();
  
  /// Controller for email input field
  final _emailController = TextEditingController();
  
  /// Controller for password input field
  final _passwordController = TextEditingController();
  
  /// Controller for confirm password input field
  /// Used to verify that user typed password correctly
  final _confirmPasswordController = TextEditingController();
  
  /// Focus node for name field
  final _nameFocusNode = FocusNode();
  
  /// Focus node for email field
  final _emailFocusNode = FocusNode();
  
  /// Focus node for password field
  final _passwordFocusNode = FocusNode();
  
  /// Focus node for confirm password field
  final _confirmPasswordFocusNode = FocusNode();
  
  /// Loading state flag
  /// When true, shows loading indicator and disables form submission
  bool _isLoading = false;
  
  /// Password visibility toggle for main password field
  bool _obscurePassword = true;
  
  /// Password visibility toggle for confirm password field
  /// Separate toggle allows user to verify password match if needed
  bool _obscureConfirmPassword = true;
  
  /// Error message to display to user
  /// Set when registration fails, cleared when form is submitted again
  String? _errorMessage;

  /// Cleanup method
  /// 
  /// Disposes of all text controllers and focus nodes to prevent memory leaks.
  /// Called automatically when widget is removed from widget tree.
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  /// Handle registration form submission
  /// 
  /// Process:
  /// 1. Validate all form fields
  ///    - Name: required, minimum 2 characters
  ///    - Email: required, valid format
  ///    - Password: required, minimum 6 characters
  ///    - Confirm password: required, must match password
  /// 2. If validation fails, return early (errors shown automatically)
  /// 3. Set loading state to true, clear any previous errors
  /// 4. Call AuthService to register with email/password
  ///    - Creates Firebase Auth account
  ///    - Creates Firestore user document
  /// 5. On success: Navigate to home screen
  /// 6. On error: Display error message to user
  /// 7. Always: Reset loading state
  /// 
  /// Error handling:
  /// - AuthService throws user-friendly error strings
  /// - Common errors: email already in use, weak password, etc.
  /// - Errors are displayed in the error message container
  /// 
  /// Navigation:
  /// - Uses go_router's context.go() for navigation
  /// - Router will handle redirect if user is already authenticated
  Future<void> _handleRegister() async {
    // Step 1: Validate form
    // This triggers all field validators and shows error messages if invalid
    if (!_formKey.currentState!.validate()) return;

    // Step 2: Update UI state
    setState(() {
      _isLoading = true;        // Show loading indicator
      _errorMessage = null;     // Clear previous errors
    });

    try {
      // Step 3: Get AuthService from Riverpod
      final authService = ref.read(authServiceProvider);
      
      // Step 4: Attempt registration
      // This will:
      // - Create Firebase Auth account
      // - Update display name in Auth profile
      // - Create UserModel document in Firestore
      // Throws a string error if registration fails
      await authService.registerWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
        displayName: _nameController.text,
      );
      
      // Step 5: Success - navigate to home
      // Check mounted to ensure widget is still in tree
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      // Step 6: Error - display message to user
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      // Step 7: Always reset loading state
      // Check mounted to prevent setState after dispose
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Build the registration screen UI
  /// 
  /// Layout structure:
  /// - Scaffold with app background color
  /// - SafeArea to avoid system UI overlap
  /// - SingleChildScrollView for keyboard handling
  /// - Form widget for validation
  /// - Column with all form elements
  /// 
  /// UI Components (top to bottom):
  /// 1. Back button (to return to login)
  /// 2. App logo/icon (heart icon)
  /// 3. Title and subtitle
  /// 4. Name input field
  /// 5. Email input field
  /// 6. Password input field (with visibility toggle)
  /// 7. Confirm password input field (with visibility toggle)
  /// 8. Error message container (conditional)
  /// 9. Sign up button (with loading state)
  /// 10. Link to login screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      // Ensure keyboard can appear
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: GestureDetector(
          // Dismiss keyboard when tapping outside
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
                const SizedBox(height: AppSpacing.xl),
                
                // Back Button
                // Allows user to return to login screen without completing registration
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(
                      PhosphorIconsBold.arrowLeft,
                      color: AppTheme.colors.text,
                    ),
                    onPressed: () => context.go('/login'),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                
                // App Logo/Icon
                Icon(
                  PhosphorIconsBold.heart,
                  size: 80,
                  color: AppTheme.colors.primary,
                ),
                const SizedBox(height: AppSpacing.lg),
                
                // Title
                Text(
                  'Create account',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.colors.text,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                
                // Subtitle
                Text(
                  'Sign up to get started',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.colors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxl),
                
                // Name Input Field
                // First field in registration form
                GestureDetector(
                  onTap: () {
                    _nameFocusNode.requestFocus();
                    SystemChannels.textInput.invokeMethod('TextInput.show');
                  },
                  child: TextFormField(
                    controller: _nameController,
                    focusNode: _nameFocusNode,
                    enabled: true,                               // Ensure field is enabled
                    readOnly: false,                             // Ensure field is not read-only
                    canRequestFocus: true,                       // Explicitly allow focus requests
                    enableInteractiveSelection: true,            // Enable text selection
                    textCapitalization: TextCapitalization.words, // Capitalize first letter of each word
                    textInputAction: TextInputAction.next,        // "Next" button moves to email field
                    onTap: () {
                      _nameFocusNode.requestFocus();
                      SystemChannels.textInput.invokeMethod('TextInput.show');
                    },
                    onFieldSubmitted: (_) {
                      _emailFocusNode.requestFocus();
                    },
                  decoration: InputDecoration(
                    labelText: 'Full name',
                    prefixIcon: Icon(
                      PhosphorIconsBold.user,
                      color: AppTheme.colors.textSecondary,
                    ),
                    filled: true,
                    fillColor: AppTheme.colors.card,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: AppTheme.colors.love,
                        width: 1,
                      ),
                    ),
                  ),
                  validator: (value) {
                    // Check if field is empty
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    // Ensure name is at least 2 characters (reasonable minimum)
                    if (value.length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                
                // Email Input Field
                // Same as login screen - email format validation
                GestureDetector(
                  onTap: () {
                    _emailFocusNode.requestFocus();
                    SystemChannels.textInput.invokeMethod('TextInput.show');
                  },
                  child: TextFormField(
                    controller: _emailController,
                    focusNode: _emailFocusNode,
                    enabled: true,                               // Ensure field is enabled
                    readOnly: false,                             // Ensure field is not read-only
                    canRequestFocus: true,                       // Explicitly allow focus requests
                    enableInteractiveSelection: true,            // Enable text selection
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onTap: () {
                      _emailFocusNode.requestFocus();
                      SystemChannels.textInput.invokeMethod('TextInput.show');
                    },
                    onFieldSubmitted: (_) {
                      _passwordFocusNode.requestFocus();
                    },
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(
                      PhosphorIconsBold.envelope,
                      color: AppTheme.colors.textSecondary,
                    ),
                    filled: true,
                    fillColor: AppTheme.colors.card,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: AppTheme.colors.love,
                        width: 1,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                
                // Password Input Field
                // First password field - user enters their chosen password
                GestureDetector(
                  onTap: () {
                    _passwordFocusNode.requestFocus();
                    SystemChannels.textInput.invokeMethod('TextInput.show');
                  },
                  child: TextFormField(
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    enabled: true,                               // Ensure field is enabled
                    readOnly: false,                             // Ensure field is not read-only
                    canRequestFocus: true,                       // Explicitly allow focus requests
                    enableInteractiveSelection: true,            // Enable text selection
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next, // "Next" moves to confirm password
                    onTap: () {
                      _passwordFocusNode.requestFocus();
                      SystemChannels.textInput.invokeMethod('TextInput.show');
                    },
                    onFieldSubmitted: (_) {
                      _confirmPasswordFocusNode.requestFocus();
                    },
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(
                      PhosphorIconsBold.lock,
                      color: AppTheme.colors.textSecondary,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? PhosphorIconsBold.eyeSlash
                            : PhosphorIconsBold.eye,
                        color: AppTheme.colors.textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: AppTheme.colors.card,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: AppTheme.colors.love,
                        width: 1,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    // Firebase requires minimum 6 characters
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                
                // Confirm Password Input Field
                // Second password field - user re-enters password to verify
                // Has separate visibility toggle so user can verify match if needed
                GestureDetector(
                  onTap: () {
                    _confirmPasswordFocusNode.requestFocus();
                    SystemChannels.textInput.invokeMethod('TextInput.show');
                  },
                  child: TextFormField(
                    controller: _confirmPasswordController,
                    focusNode: _confirmPasswordFocusNode,
                    enabled: true,                               // Ensure field is enabled
                    readOnly: false,                             // Ensure field is not read-only
                    canRequestFocus: true,                       // Explicitly allow focus requests
                    enableInteractiveSelection: true,            // Enable text selection
                    obscureText: _obscureConfirmPassword,
                    textInputAction: TextInputAction.done, // "Done" submits form
                    onTap: () {
                      _confirmPasswordFocusNode.requestFocus();
                      SystemChannels.textInput.invokeMethod('TextInput.show');
                    },
                    onFieldSubmitted: (_) => _handleRegister(), // Submit on "Done" press
                  decoration: InputDecoration(
                    labelText: 'Confirm password',
                    prefixIcon: Icon(
                      PhosphorIconsBold.lock,
                      color: AppTheme.colors.textSecondary,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? PhosphorIconsBold.eyeSlash
                            : PhosphorIconsBold.eye,
                        color: AppTheme.colors.textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: AppTheme.colors.card,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: AppTheme.colors.love,
                        width: 1,
                      ),
                    ),
                  ),
                  validator: (value) {
                    // Check if field is empty
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    // Critical validation: passwords must match
                    // This prevents typos that would lock user out of account
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                
                // Error Message Container
                // Shows registration errors (email already in use, weak password, etc.)
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppTheme.colors.love.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          PhosphorIconsBold.warning,
                          color: AppTheme.colors.love,
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
                                  color: AppTheme.colors.love,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: AppSpacing.lg),
                
                // Sign Up Button
                // Primary action button - triggers registration
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
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
                          'Sign up',
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
                
                // Login Link
                // Allows users to navigate back to login screen
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.colors.textSecondary,
                          ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.go('/login');
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                        ),
                      ),
                      child: Text(
                        'Sign in',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.colors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }
}

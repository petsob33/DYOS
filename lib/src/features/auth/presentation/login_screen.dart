import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/data/services/auth_service.dart';
import 'register_screen.dart';

/// Login Screen
/// 
/// This screen allows existing users to sign in to their account.
/// It's the first screen shown when the app starts (if user is not authenticated).
/// 
/// Features:
/// - Email and password input fields
/// - Form validation
/// - Password visibility toggle
/// - Error message display
/// - Loading state during authentication
/// - Link to registration screen
/// 
/// After successful login, user is automatically redirected to home screen
/// by the router's authentication redirect logic.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

/// State class for LoginScreen
/// 
/// Manages:
/// - Form state and validation
/// - Text field controllers
/// - Loading state
/// - Password visibility
/// - Error messages
class _LoginScreenState extends ConsumerState<LoginScreen> {
  /// Form key for validation
  /// Used to trigger form validation and access form state
  final _formKey = GlobalKey<FormState>();
  
  /// Controller for email input field
  /// Manages the text value and cursor position
  final _emailController = TextEditingController();
  
  /// Controller for password input field
  /// Manages the text value and cursor position
  final _passwordController = TextEditingController();
  
  /// Focus node for email field
  /// Used to manage focus state and ensure keyboard appears
  final _emailFocusNode = FocusNode();
  
  /// Focus node for password field
  /// Used to manage focus state and ensure keyboard appears
  final _passwordFocusNode = FocusNode();
  
  /// Loading state flag
  /// When true, shows loading indicator and disables form submission
  bool _isLoading = false;
  
  /// Password visibility toggle
  /// When true, password is hidden (obscured). When false, password is visible.
  bool _obscurePassword = true;
  
  /// Error message to display to user
  /// Set when authentication fails, cleared when form is submitted again
  String? _errorMessage;

  /// Cleanup method
  /// 
  /// Disposes of text controllers and focus nodes to prevent memory leaks.
  /// Called automatically when widget is removed from widget tree.
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  /// Handle login form submission
  /// 
  /// Process:
  /// 1. Validate form fields (email format, password length, etc.)
  /// 2. If validation fails, return early (validation errors shown automatically)
  /// 3. Set loading state to true, clear any previous errors
  /// 4. Call AuthService to sign in with email/password
  /// 5. On success: Navigate to home screen
  /// 6. On error: Display error message to user
  /// 7. Always: Reset loading state
  /// 
  /// Error handling:
  /// - AuthService throws user-friendly error strings
  /// - These are displayed in the error message container
  /// - User can retry after seeing the error
  /// 
  /// Navigation:
  /// - Uses go_router's context.go() for navigation
  /// - Router will handle redirect if user is already authenticated
  Future<void> _handleLogin() async {
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
      // ref.read() gets the provider without watching (we don't need reactivity here)
      final authService = ref.read(authServiceProvider);
      
      // Step 4: Attempt authentication
      // This will throw a string error if authentication fails
      await authService.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      
      // Step 5: Success - navigate to home
      // Check mounted to ensure widget is still in tree (prevents errors if user navigated away)
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      // Step 6: Error - display message to user
      // AuthService throws user-friendly error strings
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

  /// Build the login screen UI
  /// 
  /// Layout structure:
  /// - Scaffold with app background color
  /// - SafeArea to avoid system UI overlap
  /// - SingleChildScrollView for keyboard handling
  /// - Form widget for validation
  /// - Column with all form elements
  /// 
  /// UI Components (top to bottom):
  /// 1. App logo/icon (heart icon)
  /// 2. Welcome title and subtitle
  /// 3. Email input field
  /// 4. Password input field (with visibility toggle)
  /// 5. Error message container (conditional)
  /// 6. Sign in button (with loading state)
  /// 7. Link to registration screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use app's background color for consistency
      backgroundColor: AppTheme.colors.background,
      // Ensure keyboard can appear
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        // SafeArea ensures content isn't hidden behind system UI (notch, status bar)
        child: GestureDetector(
          // Dismiss keyboard when tapping outside
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          behavior: HitTestBehavior.opaque,
          child: SingleChildScrollView(
            // SingleChildScrollView allows scrolling when keyboard appears
            // This prevents keyboard from covering input fields
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            // Form widget enables validation
            // _formKey is used to trigger validation programmatically
            key: _formKey,
            child: Column(
              // Column stacks children vertically
              crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch children to full width
              children: [
                // Top spacing for visual balance
                const SizedBox(height: AppSpacing.xxl),
                
                // App Logo/Icon
                // Heart icon represents the app's theme (couple/love app)
                Icon(
                  PhosphorIconsBold.heart,
                  size: 80,
                  color: AppTheme.colors.primary,
                ),
                const SizedBox(height: AppSpacing.lg),
                
                // Welcome Title
                // Large, bold text to greet returning users
                Text(
                  'Welcome back',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.colors.text,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                
                // Subtitle
                // Provides context about what the user should do
                Text(
                  'Sign in to continue',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.colors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxl),
                
                // Email Input Field
                // TextFormField provides validation and error display
                GestureDetector(
                  onTap: () {
                    // Explicitly request focus and show keyboard
                    _emailFocusNode.requestFocus();
                    SystemChannels.textInput.invokeMethod('TextInput.show');
                  },
                  child: TextFormField(
                    controller: _emailController,              // Binds to controller
                    focusNode: _emailFocusNode,                // Manages focus state
                    enabled: true,                             // Ensure field is enabled
                    readOnly: false,                           // Ensure field is not read-only
                    canRequestFocus: true,                     // Explicitly allow focus requests
                    enableInteractiveSelection: true,          // Enable text selection
                    keyboardType: TextInputType.emailAddress, // Shows email keyboard on mobile
                    textInputAction: TextInputAction.next,    // "Next" button moves to password field
                    autofocus: false,                          // Don't auto-focus (user can click)
                    onTap: () {
                      // Force keyboard to show
                      _emailFocusNode.requestFocus();
                      SystemChannels.textInput.invokeMethod('TextInput.show');
                    },
                    onFieldSubmitted: (_) {
                      // Move focus to password field when "Next" is pressed
                      _passwordFocusNode.requestFocus();
                    },
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(
                      PhosphorIconsBold.envelope,
                      color: AppTheme.colors.textSecondary,
                    ),
                    filled: true,                           // Fill with background color
                    fillColor: AppTheme.colors.card,        // Card color for filled background
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16), // Rounded corners
                      borderSide: BorderSide.none,         // No border (filled style)
                    ),
                    errorBorder: OutlineInputBorder(
                      // Red border when validation fails
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: AppTheme.colors.love,        // Red color for errors
                        width: 1,
                      ),
                    ),
                  ),
                  // Validator function - called during form validation
                  validator: (value) {
                    // Check if field is empty
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    // Basic email format check (contains @)
                    // Note: More robust validation could use regex
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null; // null means validation passed
                  },
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                
                // Password Input Field
                // Similar to email field but with password-specific features
                GestureDetector(
                  onTap: () {
                    // Explicitly request focus and show keyboard
                    _passwordFocusNode.requestFocus();
                    SystemChannels.textInput.invokeMethod('TextInput.show');
                  },
                  child: TextFormField(
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,            // Manages focus state
                    enabled: true,                             // Ensure field is enabled
                    readOnly: false,                           // Ensure field is not read-only
                    canRequestFocus: true,                     // Explicitly allow focus requests
                    enableInteractiveSelection: true,          // Enable text selection
                    obscureText: _obscurePassword,           // Hide/show password
                    textInputAction: TextInputAction.done,   // "Done" button submits form
                    onTap: () {
                      // Force keyboard to show
                      _passwordFocusNode.requestFocus();
                      SystemChannels.textInput.invokeMethod('TextInput.show');
                    },
                    onFieldSubmitted: (_) => _handleLogin(), // Submit on "Done" press
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(
                      PhosphorIconsBold.lock,
                      color: AppTheme.colors.textSecondary,
                    ),
                    // Password visibility toggle button
                    suffixIcon: IconButton(
                      icon: Icon(
                        // Show eye-slash when password is hidden, eye when visible
                        _obscurePassword
                            ? PhosphorIconsBold.eyeSlash
                            : PhosphorIconsBold.eye,
                        color: AppTheme.colors.textSecondary,
                      ),
                      onPressed: () {
                        // Toggle password visibility
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
                      return 'Please enter your password';
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
                
                // Error Message Container
                // Only shown when _errorMessage is not null
                // Displays authentication errors (wrong password, user not found, etc.)
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      // Light red background for error
                      color: AppTheme.colors.love.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        // Warning icon
                        Icon(
                          PhosphorIconsBold.warning,
                          color: AppTheme.colors.love,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        // Error message text
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
                
                // Sign In Button
                // Primary action button - triggers login
                ElevatedButton(
                  // Disable button when loading to prevent double-submission
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.colors.primary, // App's primary color
                    foregroundColor: Colors.white,            // White text
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16), // Rounded corners
                    ),
                    elevation: 0, // Flat design (no shadow)
                  ),
                  child: _isLoading
                      ? // Show loading spinner when authenticating
                        const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : // Show button text when not loading
                        Text(
                          'Sign in',
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
                
                // Registration Link
                // Allows users to navigate to registration screen
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Prompt text
                    Text(
                      "Don't have an account? ",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.colors.textSecondary,
                          ),
                    ),
                    // Link button to registration screen
                    TextButton(
                      onPressed: () {
                        // Navigate to registration screen
                        context.go('/register');
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                        ),
                      ),
                      child: Text(
                        'Sign up',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.colors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                // Firebase Test Button (for testing connection)
                Center(
                  child: TextButton(
                    onPressed: () {
                      context.go('/firebase-test');
                    },
                    child: Text(
                      'Test Firebase Connection',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.colors.textSecondary,
                            decoration: TextDecoration.underline,
                          ),
                    ),
                  ),
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

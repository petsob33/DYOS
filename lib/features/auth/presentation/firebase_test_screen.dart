import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/l10n/build_context_l10n_extension.dart';
import '../../../core/services/auth_service.dart';
import '../data/user_repository.dart';

/// Firebase Connection Test Screen
/// 
/// This screen tests all Firebase connections and services.
/// Use this to verify that Firebase is properly configured.
class FirebaseTestScreen extends ConsumerStatefulWidget {
  const FirebaseTestScreen({super.key});

  @override
  ConsumerState<FirebaseTestScreen> createState() => _FirebaseTestScreenState();
}

class _FirebaseTestScreenState extends ConsumerState<FirebaseTestScreen> {
  final List<TestResult> _results = [];
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    // Auto-run tests when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runAllTests();
    });
  }

  Future<void> _runAllTests() async {
    setState(() {
      _results.clear();
      _isRunning = true;
    });

    // Test 1: Firebase Core
    await _testFirebaseCore();

    // Test 2: Firebase Auth
    await _testFirebaseAuth();

    // Test 3: Firestore Connection
    await _testFirestoreConnection();

    // Test 4: Auth Service
    await _testAuthService();

    // Test 5: User Repository
    await _testUserRepository();

    // Test 6: Firestore Write/Read
    await _testFirestoreWriteRead();

    setState(() {
      _isRunning = false;
    });
  }

  Future<void> _testFirebaseCore() async {
    try {
      final app = Firebase.app();
      _addResult(
        'Firebase Core',
        true,
        'Firebase initialized: ${app.name}',
      );
    } catch (e) {
      _addResult(
        'Firebase Core',
        false,
        'Error: $e',
      );
    }
  }

  Future<void> _testFirebaseAuth() async {
    try {
      final auth = FirebaseAuth.instance;
      final user = auth.currentUser;
      _addResult(
        'Firebase Auth',
        true,
        user != null
            ? 'User logged in: ${user.email}'
            : 'No user logged in (OK)',
      );
    } catch (e) {
      _addResult(
        'Firebase Auth',
        false,
        'Error: $e',
      );
    }
  }

  Future<void> _testFirestoreConnection() async {
    try {
      final firestore = FirebaseFirestore.instance;
      // Try to read a test document (this will fail if Firestore is not configured)
      await firestore.collection('_test').limit(1).get();
      _addResult(
        'Firestore Connection',
        true,
        'Firestore is connected and accessible',
      );
    } catch (e) {
      _addResult(
        'Firestore Connection',
        false,
        'Error: $e\n\nMake sure:\n- Firestore is enabled in Firebase Console\n- Security rules allow reads',
      );
    }
  }

  Future<void> _testAuthService() async {
    try {
      final authService = ref.read(authServiceProvider);
      final user = authService.currentUser;
      _addResult(
        'Auth Service',
        true,
        'AuthService is working\nCurrent user: ${user?.email ?? "None"}',
      );
    } catch (e) {
      _addResult(
        'Auth Service',
        false,
        'Error: $e',
      );
    }
  }

  Future<void> _testUserRepository() async {
    try {
      final userRepo = ref.read(userRepositoryProvider);
      final user = userRepo.currentUser;
      _addResult(
        'User Repository',
        true,
        'UserRepository is working\nCurrent user: ${user?.email ?? "None"}',
      );
    } catch (e) {
      _addResult(
        'User Repository',
        false,
        'Error: $e',
      );
    }
  }

  Future<void> _testFirestoreWriteRead() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final testDocRef = firestore.collection('_test').doc('connection_test');

      // Write test
      await testDocRef.set({
        'test': true,
        'timestamp': FieldValue.serverTimestamp(),
        'message': 'Firebase connection test',
      });

      // Read test
      final doc = await testDocRef.get();
      if (doc.exists) {
        // Clean up
        await testDocRef.delete();

        _addResult(
          'Firestore Write/Read',
          true,
          'Successfully wrote and read from Firestore\nData: ${doc.data()}',
        );
      } else {
        _addResult(
          'Firestore Write/Read',
          false,
          'Write succeeded but read failed',
        );
      }
    } catch (e) {
      _addResult(
        'Firestore Write/Read',
        false,
        'Error: $e\n\nMake sure:\n- Firestore is enabled\n- Security rules allow writes',
      );
    }
  }

  void _addResult(String testName, bool passed, String message) {
    setState(() {
      _results.add(TestResult(
        name: testName,
        passed: passed,
        message: message,
      ));
    });
  }

  int get _passedCount => _results.where((r) => r.passed).length;
  int get _failedCount => _results.where((r) => !r.passed).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(context.l10n.firebaseTestScreenTitle),
        actions: [
          IconButton(
            icon: const Icon(PhosphorIconsBold.arrowClockwise),
            onPressed: _isRunning ? null : _runAllTests,
            tooltip: context.l10n.firebaseTestScreenRerunTooltip,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Summary Card
            Card(
              color: _failedCount == 0
                  ? context.colors.success.withOpacity(0.1)
                  : context.colors.love.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    Icon(
                      _failedCount == 0
                          ? PhosphorIconsBold.checkCircle
                          : PhosphorIconsBold.warning,
                      size: 48,
                      color: _failedCount == 0
                          ? context.colors.success
                          : context.colors.love,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      _isRunning
                          ? context.l10n.firebaseTestScreenRunning
                          : _failedCount == 0
                              ? context.l10n.firebaseTestScreenAllPassed
                              : context.l10n.firebaseTestScreenSomeFailed,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: _failedCount == 0
                                ? context.colors.success
                                : context.colors.love,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      context.l10n.firebaseTestScreenPassedCount(_passedCount, _results.length),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: context.colors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Test Results
            if (_isRunning)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_results.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Text(context.l10n.firebaseTestScreenNoResults),
                ),
              )
            else
              ..._results.map((result) => _TestResultCard(result: result)),

            const SizedBox(height: AppSpacing.xl),

            // Instructions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          PhosphorIconsBold.info,
                          color: context.colors.primary,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          context.l10n.firebaseTestScreenWhatToCheckHeading,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _InstructionItem(
                      context.l10n.firebaseTestScreenInstructionAllGreen,
                    ),
                    _InstructionItem(
                      context.l10n.firebaseTestScreenInstructionCoreFailed,
                    ),
                    _InstructionItem(
                      context.l10n.firebaseTestScreenInstructionFirestoreFailed,
                    ),
                    _InstructionItem(
                      context.l10n.firebaseTestScreenInstructionWriteReadFailed,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TestResult {
  final String name;
  final bool passed;
  final String message;

  TestResult({
    required this.name,
    required this.passed,
    required this.message,
  });
}

class _TestResultCard extends StatelessWidget {
  final TestResult result;

  const _TestResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Icon
            Icon(
              result.passed
                  ? PhosphorIconsBold.checkCircle
                  : PhosphorIconsBold.xCircle,
              color: result.passed
                  ? context.colors.success
                  : context.colors.love,
              size: 24,
            ),
            const SizedBox(width: AppSpacing.md),
            // Test Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: result.passed
                              ? context.colors.success
                              : context.colors.love,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    result.message,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.colors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InstructionItem extends StatelessWidget {
  final String text;

  const _InstructionItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

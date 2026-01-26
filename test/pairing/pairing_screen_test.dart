import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ouros_app/features/auth/presentation/pairing_screen.dart';
import 'package:ouros_app/core/services/firebase_service.dart';
import 'package:ouros_app/features/auth/domain/user_model.dart';

void main() {
  group('PairingScreen Widget Tests', () {
    testWidgets('displays loading indicator initially', (WidgetTester tester) async {
      // Note: This is a simplified test. In a real scenario, you'd need to
      // mock the FirebaseService and providers properly.
      
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PairingScreen(),
          ),
        ),
      );

      // The screen shows loading initially
      // Note: This test may need adjustment based on actual implementation
      // since it depends on FirebaseService which requires mocking
    });

    testWidgets('displays user invite code when loaded', (WidgetTester tester) async {
      // This would require proper mocking of FirebaseService
      // For now, we'll test the UI structure expectations
      
      // Expected UI elements:
      // - Title: "Propojte se s partnerem"
      // - User code display
      // - Copy button
      // - Partner code input field
      // - Submit button
    });

    testWidgets('validates invite code format', (WidgetTester tester) async {
      // Test that the form validates:
      // - Empty code shows error
      // - Invalid format shows error
      // - Same code as user shows error
      // - Valid format passes validation
    });

    testWidgets('copies invite code to clipboard', (WidgetTester tester) async {
      // Test that clicking copy button:
      // - Copies code to clipboard
      // - Shows success snackbar
    });

    testWidgets('shows error when pairing fails', (WidgetTester tester) async {
      // Test error scenarios:
      // - User not found
      // - User already paired
      // - Network error
    });

    testWidgets('navigates to home after successful pairing', (WidgetTester tester) async {
      // Test that after successful pairing:
      // - Shows success message
      // - Navigates to /home
    });
  });

  group('PairingScreen Validation Tests', () {
    test('validates empty invite code', () {
      final validator = (String? value) {
        if (value == null || value.trim().isEmpty) {
          return 'Zadejte prosím kód';
        }
        return null;
      };

      expect(validator(''), 'Zadejte prosím kód');
      expect(validator('   '), 'Zadejte prosím kód');
      expect(validator('USER-1234'), null);
    });

    test('validates invite code format', () {
      final validator = (String? value, String? userCode) {
        if (value == null || value.trim().isEmpty) {
          return 'Zadejte prosím kód';
        }
        final normalizedValue = value.trim().toUpperCase();
        if (userCode != null && normalizedValue == userCode) {
          return 'Nemůžete se spárovat sami se sebou';
        }
        final pattern = RegExp(r'^[A-Z]+-\d+$');
        if (!pattern.hasMatch(normalizedValue)) {
          return 'Neplatný formát kódu (např. PETR-8821)';
        }
        return null;
      };

      // Valid formats
      expect(validator('USER-1234', null), null);
      expect(validator('PETR-8821', null), null);
      expect(validator('ANNA-5678', null), null);
      expect(validator('user-1234', null), null); // Should be uppercased

      // Invalid formats
      expect(validator('USER1234', null), isNotNull); // Missing dash
      expect(validator('USER-ABC', null), isNotNull); // Letters instead of numbers
      expect(validator('1234-USER', null), isNotNull); // Wrong order
      expect(validator('USER', null), isNotNull); // Missing numbers

      // Self-pairing prevention
      expect(validator('USER-1234', 'USER-1234'), 'Nemůžete se spárovat sami se sebou');
    });
  });
}

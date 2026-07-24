
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:go_router/go_router.dart';
import 'package:ouros_app/core/theme/app_theme.dart';
import 'package:ouros_app/features/auth/presentation/pairing_screen.dart';
import 'package:ouros_app/core/services/firebase_service.dart';
import 'package:ouros_app/core/services/pairing_exceptions.dart';
import 'package:ouros_app/core/services/auth_service.dart';
import 'package:ouros_app/features/auth/presentation/auth_providers.dart';
import 'package:ouros_app/features/auth/domain/user_model.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:shared_preferences/shared_preferences.dart';

// Mocks
class MockFirebaseService extends Mock implements FirebaseService {
  @override
  Future<UserModel?> getUserData({dynamic getOptions}) => super.noSuchMethod(
        Invocation.method(#getUserData, [], {#getOptions: getOptions}),
        returnValue: Future<UserModel?>.value(null),
      );

  @override
  Future<PairInviteCodeResult> pairWithInviteCode(String? inviteCode) =>
      super.noSuchMethod(
        Invocation.method(#pairWithInviteCode, [inviteCode]),
        returnValue: Future<PairInviteCodeResult>.value(
          PairInviteCodeResult(coupleId: 'new-couple-id', partnerDisplayName: 'Partner'),
        ),
      );

  @override
  Future<UserModel> createOrUpdateUser({
    required String uid,
    required String email,
    required String displayName,
    String? photoUrl,
  }) =>
      super.noSuchMethod(
        Invocation.method(#createOrUpdateUser, [], {
          #uid: uid,
          #email: email,
          #displayName: displayName,
          #photoUrl: photoUrl,
        }),
        returnValue: Future<UserModel>.value(
          UserModel(uid: uid, email: email, displayName: displayName),
        ),
      );
}

class MockAuthService extends Mock implements AuthService {
  @override
  Future<void> signOut() => super.noSuchMethod(
        Invocation.method(#signOut, []),
        returnValue: Future<void>.value(),
        returnValueForMissingStub: Future<void>.value(),
      );
}

void main() {
  late MockFirebaseService mockFirebaseService;
  late MockAuthService mockAuthService;
  late MockUser mockUser;

  setUp(() async {
    mockFirebaseService = MockFirebaseService();
    mockAuthService = MockAuthService();
    mockUser = MockUser(
      uid: 'current-user-id',
      email: 'me@test.com',
      displayName: 'Me',
    );
    
    when(mockFirebaseService.currentUser).thenReturn(mockUser);
    when(mockAuthService.signOut()).thenAnswer((_) async {});
    SharedPreferences.setMockInitialValues({});
  });

  Widget createTestWidget({List<Override> overrides = const []}) {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const PairingScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const Scaffold(body: Text('Login Screen')),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const Scaffold(body: Text('Home Screen')),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        firebaseServiceProvider.overrideWithValue(mockFirebaseService),
        authServiceProvider.overrideWithValue(mockAuthService),
        // Mocking other providers to avoid errors
        isUserPairedProvider.overrideWith((ref) => Stream.value(false)),
        userProvider.overrideWith((ref) => const Stream.empty()),
        hasSeenTutorialProvider.overrideWith((ref) => Future.value(true)), // Skip tutorial by default
        ...overrides,
      ],
      child: MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: router,
      ),
    );
  }

  group('PairingScreen UI Tests', () {
    testWidgets('shows logout button and triggers sign out', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final userData = UserModel(
        uid: 'current-user-id',
        email: 'me@test.com',
        displayName: 'Me',
        inviteCode: 'ME-9999',
      );
      
      when(mockFirebaseService.getUserData(getOptions: anyNamed('getOptions')))
          .thenAnswer((_) async => userData);

      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      final logoutButton = find.byIcon(PhosphorIconsBold.signOut);
      expect(logoutButton, findsOneWidget);

      await tester.tap(logoutButton);
      await tester.pumpAndSettle();

      // Check for confirm dialog
      expect(find.text('Sign Out'), findsNWidgets(2)); // Title and Button
      
      await tester.tap(find.text('Sign Out').last);
      await tester.pumpAndSettle();

      verify(mockAuthService.signOut()).called(1);
    });
  });
}

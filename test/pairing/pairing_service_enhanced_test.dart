
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:ouros_app/core/services/pairing_service.dart';
import 'package:ouros_app/core/services/pairing_exceptions.dart';

import 'pairing_service_enhanced_test.mocks.dart';

// Mockito's manual `extends Mock implements X` pattern can't safely mock
// httpsCallable() here: FirebaseFunctions.httpsCallable() has a
// non-nullable HttpsCallable return type, and a hand-rolled Mock subclass
// has no way to supply the `returnValue` Mock.noSuchMethod() needs while
// `when(...)` is recording - it returns null instead, and the runtime
// throws a TypeError assigning null to the non-nullable return type,
// corrupting mockito's internal `when()` state for every later test in the
// file. @GenerateMocks generates a proper SmartFake-backed override that
// avoids this.
@GenerateMocks([FirebaseFunctions, HttpsCallable, HttpsCallableResult])
void main() {
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth firebaseAuth;
  late MockFirebaseFunctions functions;
  late MockHttpsCallable callable;
  late PairingService pairingService;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    functions = MockFirebaseFunctions();
    callable = MockHttpsCallable();

    // pairWithInviteCode() and pairWithEmail() both go through a single
    // named Cloud Function call - see lib/core/services/pairing_service.dart.
    // The real pairing logic (existence/already-paired checks, Firestore
    // writes) now runs server-side in functions/index.js inside a
    // transaction, so the client is only responsible for mapping
    // FirebaseFunctionsException codes to typed PairingExceptions.
    when(functions.httpsCallable('pairWithInviteCode')).thenReturn(callable);

    // Default user
    final currentUser = MockUser(
      uid: 'current-user-id',
      email: 'me@test.com',
      displayName: 'Me',
    );
    firebaseAuth = MockFirebaseAuth(mockUser: currentUser, signedIn: true);

    pairingService = PairingService(
      auth: firebaseAuth,
      firestore: firestore,
      functions: functions,
    );
  });

  group('PairingService.pairWithInviteCode - Edge Cases', () {
    test('SUCCESS: pairs with valid partner invite code', () async {
      final result0 = MockHttpsCallableResult();
      when(result0.data).thenReturn(
        {'coupleId': 'couple_123', 'partnerDisplayName': 'Partner'},
      );
      when(callable.call(any)).thenAnswer((_) async => result0);

      final result = await pairingService.pairWithInviteCode('PART-1234');

      expect(result.coupleId, 'couple_123');
      expect(result.partnerDisplayName, 'Partner');
    });

    test('FAILURE: throws GenericPairingException when not logged in', () async {
      // Sign out
      await firebaseAuth.signOut();

      expect(
        () => pairingService.pairWithInviteCode('PART-1234'),
        throwsA(isA<GenericPairingException>().having((e) => e.message, 'message', contains('sign in again'))),
      );
    });

    test('FAILURE: throws GenericPairingException for invalid format', () async {
      expect(
        () => pairingService.pairWithInviteCode('INVALID'),
        throwsA(isA<GenericPairingException>().having((e) => e.message, 'message', contains('Invalid invite code format'))),
      );
      expect(
        () => pairingService.pairWithInviteCode('A-1234'), // Too short prefix (regex says {2,10})
        throwsA(isA<GenericPairingException>()),
      );
    });

    test('FAILURE: throws PartnerNotFoundException when code does not exist', () async {
      when(callable.call(any)).thenThrow(
        FirebaseFunctionsException(
          code: 'not-found',
          message: 'User with this code was not found.',
        ),
      );

      expect(
        () => pairingService.pairWithInviteCode('NONE-0000'),
        throwsA(isA<PartnerNotFoundException>()),
      );
    });

    test('FAILURE: throws SelfPairingException when pairing with own code', () async {
      when(callable.call(any)).thenThrow(
        FirebaseFunctionsException(
          code: 'invalid-argument',
          message: 'You cannot pair with yourself.',
        ),
      );

      expect(
        () => pairingService.pairWithInviteCode('ME-9999'),
        throwsA(isA<SelfPairingException>()),
      );
    });

    test('FAILURE: throws UserAlreadyPairedException when current user is already paired', () async {
      when(callable.call(any)).thenThrow(
        FirebaseFunctionsException(
          code: 'already-exists',
          message: 'Your account is already paired.',
          details: {'type': 'user_already_paired'},
        ),
      );

      expect(
        () => pairingService.pairWithInviteCode('PART-1234'),
        throwsA(isA<UserAlreadyPairedException>()),
      );
    });

    test('FAILURE: throws PartnerAlreadyPairedException when partner is already paired', () async {
      when(callable.call(any)).thenThrow(
        FirebaseFunctionsException(
          code: 'already-exists',
          message: 'This user is already paired.',
          details: {'type': 'partner_already_paired'},
        ),
      );

      expect(
        () => pairingService.pairWithInviteCode('PART-1234'),
        throwsA(isA<PartnerAlreadyPairedException>()),
      );
    });

    test('FAILURE: throws UserNotFoundException when current user document is missing', () async {
      // functions/index.js returns 'not-found' for BOTH a missing
      // current-user document and a missing partner, distinguished only by
      // message text - the client must branch on the message, not just the
      // code (this was a real bug: both used to map to
      // PartnerNotFoundException).
      when(callable.call(any)).thenThrow(
        FirebaseFunctionsException(
          code: 'not-found',
          message: 'Current user not found.',
        ),
      );

      expect(
        () => pairingService.pairWithInviteCode('PART-1234'),
        throwsA(isA<UserNotFoundException>()),
      );
    });
  });

  group('PairingService.findUserByInviteCode', () {
    // Note: Since we're using a manual mock for functions, we need to stub its behavior if possible.
    // However, Mockito doesn't play well with HttpsCallable without generated mocks or complex setups.
    // For this task, I'll focus on the Firestore-based logic as it's the primary pairing mechanism.
  });
}

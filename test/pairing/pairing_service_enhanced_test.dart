
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:ouros_app/core/services/pairing_service.dart';
import 'package:ouros_app/core/services/pairing_exceptions.dart';
import 'package:ouros_app/features/auth/domain/user_model.dart';

// We need to mock FirebaseFunctions and HttpsCallable
class MockFirebaseFunctions extends Mock implements FirebaseFunctions {}
class MockHttpsCallable extends Mock implements HttpsCallable {}
class MockHttpsCallableResult extends Mock implements HttpsCallableResult {
  @override
  final dynamic data;
  MockHttpsCallableResult({this.data});
}

void main() {
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth firebaseAuth;
  late MockFirebaseFunctions functions;
  late PairingService pairingService;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    functions = MockFirebaseFunctions();
    
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
      // Setup partner
      const partnerId = 'partner-id';
      const partnerCode = 'PART-1234';
      await firestore.collection('users').doc(partnerId).set({
        'uid': partnerId,
        'displayName': 'Partner',
        'inviteCode': partnerCode,
        'coupleId': null,
      });

      // Setup current user in firestore
      await firestore.collection('users').doc('current-user-id').set({
        'uid': 'current-user-id',
        'displayName': 'Me',
        'inviteCode': 'ME-9999',
        'coupleId': null,
      });

      final result = await pairingService.pairWithInviteCode(partnerCode);

      expect(result.coupleId, isNotEmpty);
      expect(result.partnerDisplayName, 'Partner');

      // Verify firestore updates
      final meDoc = await firestore.collection('users').doc('current-user-id').get();
      final partnerDoc = await firestore.collection('users').doc(partnerId).get();
      
      expect(meDoc.data()?['coupleId'], result.coupleId);
      expect(partnerDoc.data()?['coupleId'], result.coupleId);

      final coupleDoc = await firestore.collection('couples').doc(result.coupleId).get();
      expect(coupleDoc.exists, true);
      expect(coupleDoc.data()?['members'], containsAll(['current-user-id', partnerId]));
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
      // Ensure firestore is empty or doesn't have this code
      expect(
        () => pairingService.pairWithInviteCode('NONE-0000'),
        throwsA(isA<PartnerNotFoundException>()),
      );
    });

    test('FAILURE: throws SelfPairingException when pairing with own code', () async {
      const myCode = 'ME-9999';
      await firestore.collection('users').doc('current-user-id').set({
        'uid': 'current-user-id',
        'inviteCode': myCode,
      });

      expect(
        () => pairingService.pairWithInviteCode(myCode),
        throwsA(isA<SelfPairingException>()),
      );
    });

    test('FAILURE: throws UserAlreadyPairedException when current user is already paired', () async {
      const partnerId = 'partner-id';
      const partnerCode = 'PART-1234';
      await firestore.collection('users').doc(partnerId).set({
        'uid': partnerId,
        'inviteCode': partnerCode,
        'coupleId': null,
      });

      // I'm already paired
      await firestore.collection('users').doc('current-user-id').set({
        'uid': 'current-user-id',
        'inviteCode': 'ME-9999',
        'coupleId': 'already-paired-id',
      });

      expect(
        () => pairingService.pairWithInviteCode(partnerCode),
        throwsA(isA<UserAlreadyPairedException>()),
      );
    });

    test('FAILURE: throws PartnerAlreadyPairedException when partner is already paired', () async {
      const partnerId = 'partner-id';
      const partnerCode = 'PART-1234';
      // Partner is already paired
      await firestore.collection('users').doc(partnerId).set({
        'uid': partnerId,
        'inviteCode': partnerCode,
        'coupleId': 'partner-already-paired-id',
      });

      await firestore.collection('users').doc('current-user-id').set({
        'uid': 'current-user-id',
        'inviteCode': 'ME-9999',
        'coupleId': null,
      });

      expect(
        () => pairingService.pairWithInviteCode(partnerCode),
        throwsA(isA<PartnerAlreadyPairedException>()),
      );
    });

    test('FAILURE: throws UserNotFoundException when current user document is missing', () async {
      const partnerId = 'partner-id';
      const partnerCode = 'PART-1234';
      await firestore.collection('users').doc(partnerId).set({
        'uid': partnerId,
        'inviteCode': partnerCode,
        'coupleId': null,
      });

      // current-user-id NOT in firestore
      
      expect(
        () => pairingService.pairWithInviteCode(partnerCode),
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

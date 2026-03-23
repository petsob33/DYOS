import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ouros_app/core/services/firebase_service.dart';
import 'package:ouros_app/core/services/pairing_exceptions.dart';

void main() {
  group('Pairing callable exception mapping', () {
    test('maps invalid-argument to GenericPairingException', () {
      final error = FirebaseFunctionsException(
        code: 'invalid-argument',
        message: 'Invite code format is invalid.',
      );

      final mapped = mapPairingFunctionsException(error);
      expect(mapped, isA<GenericPairingException>());
      expect(mapped.message, contains('Invalid invite code format'));
    });

    test('maps not-found to PartnerNotFoundException', () {
      final error = FirebaseFunctionsException(
        code: 'not-found',
        message: 'User with this code was not found.',
      );

      final mapped = mapPairingFunctionsException(error);
      expect(mapped, isA<PartnerNotFoundException>());
    });

    test('maps failed-precondition (self pairing)', () {
      final error = FirebaseFunctionsException(
        code: 'failed-precondition',
        message: 'You cannot pair with yourself.',
      );

      final mapped = mapPairingFunctionsException(error);
      expect(mapped, isA<SelfPairingException>());
    });

    test('maps failed-precondition (current user already paired)', () {
      final error = FirebaseFunctionsException(
        code: 'failed-precondition',
        message: 'Your account is already paired.',
      );

      final mapped = mapPairingFunctionsException(error);
      expect(mapped, isA<UserAlreadyPairedException>());
    });

    test('maps failed-precondition (partner already paired)', () {
      final error = FirebaseFunctionsException(
        code: 'failed-precondition',
        message: 'This user is already paired.',
      );

      final mapped = mapPairingFunctionsException(error);
      expect(mapped, isA<PartnerAlreadyPairedException>());
    });

    test('maps unknown codes to GenericPairingException', () {
      final error = FirebaseFunctionsException(
        code: 'internal',
        message: 'Something unexpected happened.',
      );

      final mapped = mapPairingFunctionsException(error);
      expect(mapped, isA<GenericPairingException>());
      expect(mapped.message, contains('Something unexpected happened'));
    });
  });
}

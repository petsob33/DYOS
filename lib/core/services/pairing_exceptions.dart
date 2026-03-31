/// Result of a successful [PairingService.pairWithInviteCode] call.
class PairInviteCodeResult {
  const PairInviteCodeResult({
    required this.coupleId,
    this.partnerDisplayName,
  });

  final String coupleId;
  final String? partnerDisplayName;
}

/// Base class for all pairing-related exceptions.
abstract class PairingException implements Exception {
  final String message;
  PairingException(this.message);

  @override
  String toString() => message;
}

/// Thrown when a user attempts to pair with themselves.
class SelfPairingException extends PairingException {
  SelfPairingException() : super('You cannot pair with yourself.');
}

/// Thrown when the current user is not found in the database.
class UserNotFoundException extends PairingException {
  UserNotFoundException() : super('Current user not found.');
}

/// Thrown when the partner user with the given code is not found.
class PartnerNotFoundException extends PairingException {
  PartnerNotFoundException() : super('User with this code was not found.');
}

/// Thrown when the current user is already paired.
class UserAlreadyPairedException extends PairingException {
  UserAlreadyPairedException() : super('Your account is already paired.');
}

/// Thrown when the partner user is already paired.
class PartnerAlreadyPairedException extends PairingException {
  PartnerAlreadyPairedException() : super('This user is already paired.');
}

/// Generic pairing exception for unknown errors.
class GenericPairingException extends PairingException {
  GenericPairingException([String message = 'An unknown error occurred during pairing.']) : super(message);
}

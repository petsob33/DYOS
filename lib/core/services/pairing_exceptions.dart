/// Base class for all pairing-related exceptions.
abstract class PairingException implements Exception {
  final String message;
  PairingException(this.message);

  @override
  String toString() => message;
}

/// Thrown when a user attempts to pair with themselves.
class SelfPairingException extends PairingException {
  SelfPairingException() : super('Nelze se spárovat sám se sebou.');
}

/// Thrown when the current user is not found in the database.
class UserNotFoundException extends PairingException {
  UserNotFoundException() : super('Aktuální uživatel nebyl nalezen.');
}

/// Thrown when the partner user with the given code is not found.
class PartnerNotFoundException extends PairingException {
  PartnerNotFoundException() : super('Uživatel s tímto kódem nebyl nalezen.');
}

/// Thrown when the current user is already paired.
class UserAlreadyPairedException extends PairingException {
  UserAlreadyPairedException() : super('Váš účet je již spárován.');
}

/// Thrown when the partner user is already paired.
class PartnerAlreadyPairedException extends PairingException {
  PartnerAlreadyPairedException() : super('Tento uživatel je již spárován.');
}

/// Generic pairing exception for unknown errors.
class GenericPairingException extends PairingException {
  GenericPairingException([String message = 'Při párování došlo k neznámé chybě.']) : super(message);
}

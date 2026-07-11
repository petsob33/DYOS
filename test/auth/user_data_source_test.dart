import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:ouros_app/features/auth/data/user_data_source.dart';
import 'package:ouros_app/features/auth/domain/user_model.dart';

// getUserByInviteCode() is backed by a Cloud Functions callable, not
// Firestore directly, so UserDataSource always needs a FirebaseFunctions
// instance even for tests that never call that method.
class _UnusedFirebaseFunctions extends Mock implements FirebaseFunctions {}

void main() {
  late FakeFirebaseFirestore firestore;
  late UserDataSource dataSource;

  UserModel buildUser({
    String uid = 'user_1',
    String email = 'me@test.com',
    String? coupleId,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: 'Me',
      inviteCode: 'ME-1234',
      coupleId: coupleId,
      createdAt: DateTime(2026, 1, 1),
    );
  }

  setUp(() {
    firestore = FakeFirebaseFirestore();
    dataSource = UserDataSource(
      firestore: firestore,
      functions: _UnusedFirebaseFunctions(),
    );
  });

  group('UserDataSource.createUser / getUserById', () {
    test('creates a user document and reads it back', () async {
      final user = buildUser();

      await dataSource.createUser(user);
      final fetched = await dataSource.getUserById(user.uid);

      expect(fetched, isNotNull);
      expect(fetched!.uid, user.uid);
      expect(fetched.email, user.email);
      expect(fetched.inviteCode, user.inviteCode);
    });

    test('getUserById returns null when the document does not exist', () async {
      final fetched = await dataSource.getUserById('missing-uid');
      expect(fetched, isNull);
    });
  });

  group('UserDataSource.updateUser', () {
    test('updates fields on an existing document', () async {
      final user = buildUser();
      await dataSource.createUser(user);

      final updated = user.copyWith(displayName: 'New Name');
      await dataSource.updateUser(updated);

      final fetched = await dataSource.getUserById(user.uid);
      expect(fetched!.displayName, 'New Name');
    });

    test('throws when the document does not exist', () async {
      final user = buildUser();
      expect(() => dataSource.updateUser(user), throwsA(anything));
    });
  });

  group('UserDataSource.createOrUpdateUser', () {
    test('creates the document when it does not exist yet', () async {
      final user = buildUser();
      await dataSource.createOrUpdateUser(user);

      final fetched = await dataSource.getUserById(user.uid);
      expect(fetched, isNotNull);
    });

    test('merges into an existing document without clobbering other fields', () async {
      final user = buildUser();
      await dataSource.createUser(user);

      // Simulate a partner-only update touching a single field, as
      // happens e.g. after pairing sets coupleId.
      await dataSource.createOrUpdateUser(
        user.copyWith(coupleId: 'couple_1'),
      );

      final fetched = await dataSource.getUserById(user.uid);
      expect(fetched!.coupleId, 'couple_1');
      // Field not touched by the partial update should survive the merge.
      expect(fetched.displayName, user.displayName);
    });
  });

  group('UserDataSource.updateUserFields', () {
    test('updates only the specified fields', () async {
      final user = buildUser();
      await dataSource.createUser(user);

      await dataSource.updateUserFields(user.uid, {'coupleId': 'couple_9'});

      final fetched = await dataSource.getUserById(user.uid);
      expect(fetched!.coupleId, 'couple_9');
      expect(fetched.displayName, user.displayName);
    });

    test('throws when the document does not exist', () async {
      expect(
        () => dataSource.updateUserFields('missing-uid', {'coupleId': 'x'}),
        throwsA(anything),
      );
    });
  });

  group('UserDataSource.deleteUser', () {
    test('removes the document', () async {
      final user = buildUser();
      await dataSource.createUser(user);

      await dataSource.deleteUser(user.uid);

      final fetched = await dataSource.getUserById(user.uid);
      expect(fetched, isNull);
    });
  });

  group('UserDataSource.userExists', () {
    test('returns true when the document exists', () async {
      final user = buildUser();
      await dataSource.createUser(user);

      expect(await dataSource.userExists(user.uid), isTrue);
    });

    test('returns false when the document does not exist', () async {
      expect(await dataSource.userExists('missing-uid'), isFalse);
    });
  });

  group('UserDataSource.streamUser', () {
    test('emits the current user, then updates as the document changes', () async {
      final user = buildUser();
      await dataSource.createUser(user);

      final emissions = <UserModel?>[];
      final subscription = dataSource.streamUser(user.uid).listen(emissions.add);
      await Future<void>.delayed(Duration.zero);

      await dataSource.updateUserFields(user.uid, {'coupleId': 'couple_1'});
      await Future<void>.delayed(Duration.zero);

      await subscription.cancel();

      expect(emissions.first?.coupleId, isNull);
      expect(emissions.last?.coupleId, 'couple_1');
    });

    test('emits null when the document is deleted', () async {
      final user = buildUser();
      await dataSource.createUser(user);

      final emissions = <UserModel?>[];
      final subscription = dataSource.streamUser(user.uid).listen(emissions.add);
      await Future<void>.delayed(Duration.zero);

      await dataSource.deleteUser(user.uid);
      await Future<void>.delayed(Duration.zero);

      await subscription.cancel();

      expect(emissions.last, isNull);
    });
  });

  group('UserModel.fromFirestore', () {
    Future<DocumentSnapshot> writeRaw(
      String uid,
      Map<String, dynamic> data,
    ) async {
      await firestore.collection('users').doc(uid).set(data);
      return firestore.collection('users').doc(uid).get();
    }

    test('tolerates a null email by defaulting to an empty string', () async {
      final doc = await writeRaw('user_2', {
        'email': null,
        'displayName': 'No Email',
      });

      final user = UserModel.fromFirestore(doc);

      expect(user.email, '');
      expect(user.uid, 'user_2');
    });

    test('drops a malformed status map missing required fields', () async {
      final doc = await writeRaw('user_3', {
        'email': 'me@test.com',
        'status': {'emoji': '🙂'}, // missing 'text'
      });

      final user = UserModel.fromFirestore(doc);

      expect(user.status, isNull);
    });

    test('keeps a well-formed status map', () async {
      final doc = await writeRaw('user_4', {
        'email': 'me@test.com',
        'status': {'emoji': '🙂', 'text': 'Feeling good'},
      });

      final user = UserModel.fromFirestore(doc);

      expect(user.status?.emoji, '🙂');
      expect(user.status?.text, 'Feeling good');
    });

    test('throws when the document does not exist', () async {
      final missingDoc = await firestore.collection('users').doc('ghost').get();
      expect(() => UserModel.fromFirestore(missingDoc), throwsStateError);
    });
  });
}

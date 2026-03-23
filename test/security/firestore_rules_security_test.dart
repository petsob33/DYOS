import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  const hardenedUsersRule = '''
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
''';

  group('Firestore security rules hardening', () {
    test('user can update only own /users/{uid} document', () async {
      final auth = BehaviorSubject<Map<String, dynamic>?>();
      final firestore = FakeFirebaseFirestore(
        securityRules: hardenedUsersRule,
        authObject: auth,
      );

      auth.add({'uid': 'user_1'});

      await expectLater(
        firestore.collection('users').doc('user_1').set({
          'email': 'user1@test.com',
          'displayName': 'User One',
        }),
        completes,
      );

      await expectLater(
        firestore.collection('users').doc('user_2').set({
          'email': 'user2@test.com',
          'displayName': 'User Two',
        }),
        throwsException,
      );
    });

    test('unauthenticated user cannot read /users/{uid}', () async {
      final auth = BehaviorSubject<Map<String, dynamic>?>();
      final firestore = FakeFirebaseFirestore(
        securityRules: hardenedUsersRule,
        authObject: auth,
      );

      auth.add({'uid': 'seed_user'});
      await firestore.collection('users').doc('seed_user').set({
        'email': 'seed@test.com',
        'displayName': 'Seed',
      });

      auth.add(null);

      await expectLater(
        firestore.collection('users').doc('seed_user').get(),
        throwsException,
      );
    });

  });
}

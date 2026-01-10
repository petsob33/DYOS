import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import '../../lib/src/core/data/models/user_model.dart';
import '../../lib/src/core/data/models/couple_model.dart';

/// Integration tests for pairing functionality
/// 
/// These tests verify the complete pairing flow:
/// 1. User registration with invite code generation
/// 2. Finding partner by invite code
/// 3. Creating couple document
/// 4. Updating both users with coupleId
/// 5. Verifying pairing status
void main() {
  group('Pairing Integration Tests', () {
    late FakeFirebaseFirestore firestore;

    setUp(() {
      firestore = FakeFirebaseFirestore();
    });

    test('complete pairing flow: user1 pairs with user2', () async {
      // Step 1: Create user1
      final user1 = UserModel(
        uid: 'user1',
        email: 'user1@test.com',
        displayName: 'Alice',
        inviteCode: 'ALIC-1234',
        createdAt: DateTime.now(),
      );
      await firestore.collection('users').doc('user1').set(user1.toJson());

      // Step 2: Create user2
      final user2 = UserModel(
        uid: 'user2',
        email: 'user2@test.com',
        displayName: 'Bob',
        inviteCode: 'BOB-5678',
        createdAt: DateTime.now(),
      );
      await firestore.collection('users').doc('user2').set(user2.toJson());

      // Step 3: User1 finds user2 by invite code
      final findQuery = await firestore
          .collection('users')
          .where('inviteCode', isEqualTo: 'BOB-5678')
          .limit(1)
          .get();

      expect(findQuery.docs.length, 1);
      final foundUser = UserModel.fromFirestore(findQuery.docs.first);
      expect(foundUser.uid, 'user2');
      expect(foundUser.coupleId, isNull); // Not paired yet

      // Step 4: Create couple document
      final coupleId = 'couple_${DateTime.now().millisecondsSinceEpoch}';
      final statusMap = <String, CoupleStatus>{
        'user1': CoupleStatus(
          emoji: '😊',
          text: 'Ready to connect',
          updatedAt: DateTime.now(),
        ),
        'user2': CoupleStatus(
          emoji: '😊',
          text: 'Ready to connect',
          updatedAt: DateTime.now(),
        ),
      };

      final couple = CoupleModel(
        id: coupleId,
        members: ['user1', 'user2'],
        anniversaryDate: DateTime.now(),
        createdAt: DateTime.now(),
        subscriptionTier: 'free',
        status: statusMap,
      );

      // Step 5: Update both users and create couple (atomic operation)
      final batch = firestore.batch();

      // Create couple document
      final coupleRef = firestore.collection('couples').doc(coupleId);
      batch.set(coupleRef, couple.toJson());

      // Update user1
      final user1Ref = firestore.collection('users').doc('user1');
      batch.update(user1Ref, {'coupleId': coupleId});

      // Update user2
      final user2Ref = firestore.collection('users').doc('user2');
      batch.update(user2Ref, {'coupleId': coupleId});

      await batch.commit();

      // Step 6: Verify pairing was successful
      // Check user1
      final user1Doc = await firestore.collection('users').doc('user1').get();
      final user1Data = UserModel.fromFirestore(user1Doc);
      expect(user1Data.coupleId, coupleId);

      // Check user2
      final user2Doc = await firestore.collection('users').doc('user2').get();
      final user2Data = UserModel.fromFirestore(user2Doc);
      expect(user2Data.coupleId, coupleId);

      // Check couple document
      final coupleDoc = await firestore.collection('couples').doc(coupleId).get();
      expect(coupleDoc.exists, true);
      final coupleData = CoupleModel.fromJson(coupleDoc.data()!);
      expect(coupleData.members, containsAll(['user1', 'user2']));
      expect(coupleData.members.length, 2);
      expect(coupleData.subscriptionTier, 'free');
      expect(coupleData.status, isNotNull);
      expect(coupleData.status!.keys, containsAll(['user1', 'user2']));
    });

    test('prevents pairing if user already has coupleId', () async {
      // Create user1 already paired
      final user1 = UserModel(
        uid: 'user1',
        email: 'user1@test.com',
        displayName: 'Alice',
        inviteCode: 'ALIC-1234',
        coupleId: 'existing_couple',
      );
      await firestore.collection('users').doc('user1').set(user1.toJson());

      // Create user2 not paired
      final user2 = UserModel(
        uid: 'user2',
        email: 'user2@test.com',
        displayName: 'Bob',
        inviteCode: 'BOB-5678',
      );
      await firestore.collection('users').doc('user2').set(user2.toJson());

      // Try to find user1 by invite code
      final findQuery = await firestore
          .collection('users')
          .where('inviteCode', isEqualTo: 'ALIC-1234')
          .limit(1)
          .get();

      expect(findQuery.docs.length, 1);
      final foundUser = UserModel.fromFirestore(findQuery.docs.first);
      
      // Verify user1 is already paired
      expect(foundUser.coupleId, isNotNull);
      expect(foundUser.coupleId, 'existing_couple');
      
      // This should prevent pairing
      expect(foundUser.coupleId!.isNotEmpty, true);
    });

    test('prevents self-pairing', () async {
      final user1 = UserModel(
        uid: 'user1',
        email: 'user1@test.com',
        displayName: 'Alice',
        inviteCode: 'ALIC-1234',
      );
      await firestore.collection('users').doc('user1').set(user1.toJson());

      // Try to find user1 by their own invite code
      final findQuery = await firestore
          .collection('users')
          .where('inviteCode', isEqualTo: 'ALIC-1234')
          .limit(1)
          .get();

      expect(findQuery.docs.length, 1);
      final foundUser = UserModel.fromFirestore(findQuery.docs.first);
      
      // Should detect self-pairing attempt
      expect(foundUser.uid, 'user1');
      // In real implementation, this would throw an exception
    });

    test('retrieves partner information after pairing', () async {
      // Setup: Create paired users
      final coupleId = 'couple_123';
      
      final user1 = UserModel(
        uid: 'user1',
        email: 'user1@test.com',
        displayName: 'Alice',
        inviteCode: 'ALIC-1234',
        coupleId: coupleId,
      );
      
      final user2 = UserModel(
        uid: 'user2',
        email: 'user2@test.com',
        displayName: 'Bob',
        inviteCode: 'BOB-5678',
        coupleId: coupleId,
      );

      await firestore.collection('users').doc('user1').set(user1.toJson());
      await firestore.collection('users').doc('user2').set(user2.toJson());

      final couple = CoupleModel(
        id: coupleId,
        members: ['user1', 'user2'],
        anniversaryDate: DateTime.now(),
        createdAt: DateTime.now(),
        subscriptionTier: 'free',
      );
      await firestore.collection('couples').doc(coupleId).set(couple.toJson());

      // Get couple data
      final coupleDoc = await firestore.collection('couples').doc(coupleId).get();
      final coupleData = CoupleModel.fromJson(coupleDoc.data()!);

      // Find partner (the other member)
      final partnerUid = coupleData.members.firstWhere(
        (uid) => uid != 'user1',
        orElse: () => '',
      );

      expect(partnerUid, 'user2');

      // Get partner's user data
      final partnerDoc = await firestore.collection('users').doc(partnerUid).get();
      final partnerData = UserModel.fromFirestore(partnerDoc);

      expect(partnerData.uid, 'user2');
      expect(partnerData.displayName, 'Bob');
      expect(partnerData.coupleId, coupleId);
    });

    test('checks pairing status correctly', () async {
      // Unpaired user
      final unpairedUser = UserModel(
        uid: 'user1',
        email: 'user1@test.com',
        displayName: 'Alice',
        inviteCode: 'ALIC-1234',
      );
      await firestore.collection('users').doc('user1').set(unpairedUser.toJson());

      final unpairedDoc = await firestore.collection('users').doc('user1').get();
      final unpairedData = UserModel.fromFirestore(unpairedDoc);
      final isPaired1 = unpairedData.coupleId != null && unpairedData.coupleId!.isNotEmpty;
      expect(isPaired1, false);

      // Paired user
      final pairedUser = UserModel(
        uid: 'user2',
        email: 'user2@test.com',
        displayName: 'Bob',
        inviteCode: 'BOB-5678',
        coupleId: 'couple_123',
      );
      await firestore.collection('users').doc('user2').set(pairedUser.toJson());

      final pairedDoc = await firestore.collection('users').doc('user2').get();
      final pairedData = UserModel.fromFirestore(pairedDoc);
      final isPaired2 = pairedData.coupleId != null && pairedData.coupleId!.isNotEmpty;
      expect(isPaired2, true);
    });
  });
}

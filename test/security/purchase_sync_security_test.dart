import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

import 'package:ouros_app/features/auth/domain/user_model.dart';
import 'package:ouros_app/features/premium/data/purchase_service.dart';

void main() {
  group('Purchase sync security guards', () {
    test('does nothing when premium entitlement is missing', () async {
      var getUserDataCalls = 0;
      var updateCalls = 0;
      final service = PurchaseService(
        auth: MockFirebaseAuth(),
        getUserData: () async {
          getUserDataCalls++;
          return null;
        },
        updateCoupleSubscription: (
          String coupleId, {
          required String subscriptionTier,
          DateTime? subscriptionExpiry,
        }) async {
          updateCalls++;
        },
      );

      await service.syncPremiumEntitlementToFirestore(
        isEntitlementActive: false,
      );

      expect(getUserDataCalls, 0);
      expect(updateCalls, 0);
    });

    test('does nothing when entitlement exists but is inactive', () async {
      var getUserDataCalls = 0;
      var updateCalls = 0;
      final service = PurchaseService(
        auth: MockFirebaseAuth(),
        getUserData: () async {
          getUserDataCalls++;
          return null;
        },
        updateCoupleSubscription: (
          String coupleId, {
          required String subscriptionTier,
          DateTime? subscriptionExpiry,
        }) async {
          updateCalls++;
        },
      );

      await service.syncPremiumEntitlementToFirestore(
        isEntitlementActive: false,
      );

      expect(getUserDataCalls, 0);
      expect(updateCalls, 0);
    });

    test('does not sync when user is not authenticated', () async {
      var getUserDataCalls = 0;
      var updateCalls = 0;
      final service = PurchaseService(
        auth: MockFirebaseAuth(),
        getUserData: () async {
          getUserDataCalls++;
          return null;
        },
        updateCoupleSubscription: (
          String coupleId, {
          required String subscriptionTier,
          DateTime? subscriptionExpiry,
        }) async {
          updateCalls++;
        },
      );

      await service.syncPremiumEntitlementToFirestore(
        isEntitlementActive: true,
      );

      expect(getUserDataCalls, 0);
      expect(updateCalls, 0);
    });

    test('does not sync when user has no coupleId', () async {
      var getUserDataCalls = 0;
      var updateCalls = 0;
      final auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'user_1', email: 'user@example.com'),
      );
      final service = PurchaseService(
        auth: auth,
        getUserData: () async {
          getUserDataCalls++;
          return UserModel(
          uid: 'user_1',
          email: 'user@example.com',
          displayName: 'User',
          coupleId: null,
        );
        },
        updateCoupleSubscription: (
          String coupleId, {
          required String subscriptionTier,
          DateTime? subscriptionExpiry,
        }) async {
          updateCalls++;
        },
      );

      await service.syncPremiumEntitlementToFirestore(
        isEntitlementActive: true,
      );

      expect(getUserDataCalls, 1);
      expect(updateCalls, 0);
    });

    test('syncs premium tier for authenticated couple user', () async {
      var getUserDataCalls = 0;
      String? updatedCoupleId;
      String? updatedTier;
      DateTime? updatedExpiry;
      final auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'user_1', email: 'user@example.com'),
      );
      final service = PurchaseService(
        auth: auth,
        getUserData: () async {
          getUserDataCalls++;
          return UserModel(
          uid: 'user_1',
          email: 'user@example.com',
          displayName: 'User',
          coupleId: 'couple_1',
        );
        },
        updateCoupleSubscription: (
          String coupleId, {
          required String subscriptionTier,
          DateTime? subscriptionExpiry,
        }) async {
          updatedCoupleId = coupleId;
          updatedTier = subscriptionTier;
          updatedExpiry = subscriptionExpiry;
        },
      );

      await service.syncPremiumEntitlementToFirestore(
        isEntitlementActive: true,
        entitlementExpirationDate: '2026-12-31T00:00:00.000Z',
      );

      expect(getUserDataCalls, 1);
      expect(updatedCoupleId, 'couple_1');
      expect(updatedTier, 'premium');
      expect(updatedExpiry, DateTime.parse('2026-12-31T00:00:00.000Z'));
    });
  });
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../core/services/firebase_service.dart';
import '../../auth/domain/user_model.dart';

/// Entitlement identifier configured in RevenueCat dashboard for premium access.
const String premiumEntitlementId = 'premium';

/// Service that bridges RevenueCat purchases to Firestore so both partners
/// get premium via the shared couple document stream.
class PurchaseService {
  PurchaseService({
    FirebaseService? firebaseService,
    FirebaseAuth? auth,
    Future<UserModel?> Function()? getUserData,
    Future<void> Function(
      String coupleId, {
      required String subscriptionTier,
      DateTime? subscriptionExpiry,
    })? updateCoupleSubscription,
  })  : assert(
          firebaseService != null ||
              (getUserData != null && updateCoupleSubscription != null),
          'Provide firebaseService or both test callbacks.',
        ),
        _auth = auth ?? FirebaseAuth.instance,
        _getUserData = getUserData ?? firebaseService!.getUserData,
        _updateCoupleSubscription =
            updateCoupleSubscription ?? firebaseService!.updateCoupleSubscription;

  final FirebaseAuth _auth;
  final Future<UserModel?> Function() _getUserData;
  final Future<void> Function(
    String coupleId, {
    required String subscriptionTier,
    DateTime? subscriptionExpiry,
  }) _updateCoupleSubscription;

  /// Purchases the given store product via RevenueCat, then syncs premium
  /// status to the couple document so the partner gets premium instantly.
  Future<void> purchaseProduct(StoreProduct storeProduct) async {
    final result = await Purchases.purchase(
      PurchaseParams.storeProduct(storeProduct),
    );
    await syncCustomerInfoToFirestore(result.customerInfo);
  }

  /// Restores purchases from the store, then syncs premium status to Firestore
  /// if the user has an active entitlement.
  Future<void> restorePurchases() async {
    final customerInfo = await Purchases.restorePurchases();
    await syncCustomerInfoToFirestore(customerInfo);
  }

  /// Fetches the current offerings (products) from RevenueCat.
  Future<Offerings> getOfferings() async {
    return Purchases.getOfferings();
  }

  /// Writes premium state to the couple document when the user has an active
  /// premium entitlement. Both partners receive the update via the couple stream.
  @visibleForTesting
  Future<void> syncCustomerInfoToFirestore(CustomerInfo customerInfo) async {
    final entitlement = customerInfo.entitlements.active[premiumEntitlementId] ??
        customerInfo.entitlements.all[premiumEntitlementId];
    await syncPremiumEntitlementToFirestore(
      isEntitlementActive: entitlement?.isActive ?? false,
      entitlementExpirationDate: entitlement?.expirationDate,
    );
  }

  @visibleForTesting
  Future<void> syncPremiumEntitlementToFirestore({
    required bool isEntitlementActive,
    String? entitlementExpirationDate,
  }) async {
    if (!isEntitlementActive) return;

    final user = _auth.currentUser;
    if (user == null) return;

    final userData = await _getUserData();
    final coupleId = userData?.coupleId;
    if (coupleId == null || coupleId.isEmpty) return;

    DateTime? expirationDate;
    if (entitlementExpirationDate != null) {
      expirationDate = DateTime.tryParse(entitlementExpirationDate);
    }

    await _updateCoupleSubscription(
      coupleId,
      subscriptionTier: 'premium',
      subscriptionExpiry: expirationDate,
    );
  }
}

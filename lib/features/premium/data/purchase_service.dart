import 'package:firebase_auth/firebase_auth.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../core/services/firebase_service.dart';

/// Entitlement identifier configured in RevenueCat dashboard for premium access.
const String premiumEntitlementId = 'premium';

/// Service that bridges RevenueCat purchases to Firestore so both partners
/// get premium via the shared couple document stream.
class PurchaseService {
  PurchaseService({required FirebaseService firebaseService})
      : _firebaseService = firebaseService;

  final FirebaseService _firebaseService;

  FirebaseAuth get _auth => FirebaseAuth.instance;

  /// Purchases the given store product via RevenueCat, then syncs premium
  /// status to the couple document so the partner gets premium instantly.
  Future<void> purchaseProduct(StoreProduct storeProduct) async {
    final result = await Purchases.purchase(
      PurchaseParams.storeProduct(storeProduct),
    );
    await _syncCustomerInfoToFirestore(result.customerInfo);
  }

  /// Restores purchases from the store, then syncs premium status to Firestore
  /// if the user has an active entitlement.
  Future<void> restorePurchases() async {
    final customerInfo = await Purchases.restorePurchases();
    await _syncCustomerInfoToFirestore(customerInfo);
  }

  /// Fetches the current offerings (products) from RevenueCat.
  Future<Offerings> getOfferings() async {
    return Purchases.getOfferings();
  }

  /// Writes premium state to the couple document when the user has an active
  /// premium entitlement. Both partners receive the update via the couple stream.
  Future<void> _syncCustomerInfoToFirestore(CustomerInfo customerInfo) async {
    final entitlement = customerInfo.entitlements.active[premiumEntitlementId] ??
        customerInfo.entitlements.all[premiumEntitlementId];
    if (entitlement == null || !entitlement.isActive) return;

    final user = _auth.currentUser;
    if (user == null) return;

    final userData = await _firebaseService.getUserData();
    final coupleId = userData?.coupleId;
    if (coupleId == null || coupleId.isEmpty) return;

    DateTime? expirationDate;
    if (entitlement.expirationDate != null) {
      expirationDate = DateTime.tryParse(entitlement.expirationDate!);
    }

    await _firebaseService.updateCoupleSubscription(
      coupleId,
      subscriptionTier: 'premium',
      subscriptionExpiry: expirationDate,
    );
  }
}

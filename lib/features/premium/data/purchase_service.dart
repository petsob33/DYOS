import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Entitlement identifier configured in RevenueCat dashboard for premium access.
const String premiumEntitlementId = 'premium';

/// Thin wrapper around RevenueCat purchases.
///
/// Premium state is NOT written to Firestore from the client (Firestore rules
/// forbid it). RevenueCat calls the `revenuecatWebhook` Cloud Function, which
/// updates `couples/{id}` so both partners get premium via the couple stream.
class PurchaseService {
  /// Purchases the given store product. Returns true when the premium
  /// entitlement is active afterwards.
  Future<bool> purchaseProduct(StoreProduct storeProduct) async {
    await _ensureConfigured();
    final result = await Purchases.purchase(
      PurchaseParams.storeProduct(storeProduct),
    );
    return hasPremium(result.customerInfo);
  }

  /// Restores purchases from the store. Returns true when premium is active.
  /// The webhook re-syncs the couple document on restore/transfer events.
  Future<bool> restorePurchases() async {
    await _ensureConfigured();
    return hasPremium(await Purchases.restorePurchases());
  }

  /// Fetches the current offerings (products) from RevenueCat.
  Future<Offerings> getOfferings() async {
    await _ensureConfigured();
    return Purchases.getOfferings();
  }

  @visibleForTesting
  static bool hasPremium(CustomerInfo info) =>
      info.entitlements.active[premiumEntitlementId]?.isActive ?? false;

  Future<void> _ensureConfigured() async {
    if (!await Purchases.isConfigured) {
      throw Exception('Subscription service unavailable — missing API key.');
    }
  }
}

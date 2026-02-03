import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/presentation/auth_providers.dart';
import '../../auth/domain/couple_model.dart';
import '../../../core/services/firebase_service.dart';
import '../data/purchase_service.dart';

part 'premium_provider.g.dart';

@riverpod
PurchaseService purchaseService(PurchaseServiceRef ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return PurchaseService(firebaseService: firebaseService);
}

/// Derives premium status from the couple stream so the app can depend on a single AsyncValue for bool.
@riverpod
AsyncValue<bool> isPremium(IsPremiumRef ref) {
  return ref.watch(coupleProvider).when(
        data: (CoupleModel? c) => AsyncValue.data(c?.isPremium ?? false),
        loading: () => const AsyncValue.loading(),
        error: (Object e, StackTrace st) => AsyncValue.error(e, st),
      );
}

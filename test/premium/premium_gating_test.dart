import 'package:flutter_test/flutter_test.dart';

import 'package:ouros_app/features/auth/domain/couple_model.dart';
import 'package:ouros_app/features/gamification/domain/progression_plan.dart';

CoupleModel _couple({String tier = 'free', DateTime? expiry}) => CoupleModel(
      id: 'c1',
      members: const ['a', 'b'],
      subscriptionTier: tier,
      subscriptionExpiry: expiry,
    );

void main() {
  group('CoupleModel.isPremium', () {
    test('free tier is not premium', () {
      expect(_couple().isPremium, isFalse);
    });

    test('premium without expiry (lifetime) is premium', () {
      expect(_couple(tier: 'premium').isPremium, isTrue);
    });

    test('premium with future expiry is premium', () {
      final expiry = DateTime.now().add(const Duration(days: 30));
      expect(_couple(tier: 'premium', expiry: expiry).isPremium, isTrue);
    });

    test('premium with past expiry is not premium', () {
      final expiry = DateTime.now().subtract(const Duration(days: 1));
      expect(_couple(tier: 'premium', expiry: expiry).isPremium, isFalse);
    });

    test('free tier with future expiry is still not premium', () {
      final expiry = DateTime.now().add(const Duration(days: 30));
      expect(_couple(expiry: expiry).isPremium, isFalse);
    });
  });

  group('ProgressionPlan.isFeatureUnlocked', () {
    test('memories, blueprints and quick messages are free at 0 SP', () {
      for (final f in [
        FeatureID.memories,
        FeatureID.blueprints,
        FeatureID.quickMessages,
      ]) {
        expect(ProgressionPlan.isFeatureUnlocked(f, 0, false), isTrue);
      }
    });

    test('map view is locked for free user below required SP', () {
      final need = ProgressionPlan.spRequiredForFeature(FeatureID.mapView);
      expect(
        ProgressionPlan.isFeatureUnlocked(FeatureID.mapView, need - 1, false),
        isFalse,
      );
    });

    test('map view unlocks with premium regardless of SP', () {
      expect(
        ProgressionPlan.isFeatureUnlocked(FeatureID.mapView, 0, true),
        isTrue,
      );
    });

    test('map view unlocks with enough SP', () {
      final need = ProgressionPlan.spRequiredForFeature(FeatureID.mapView);
      expect(
        ProgressionPlan.isFeatureUnlocked(FeatureID.mapView, need, false),
        isTrue,
      );
    });
  });
}

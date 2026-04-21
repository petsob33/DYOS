import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_logger.dart';

/// Ad unit IDs use `ca-app-pub-…/…` (slash). App IDs use `~` — those go only in AndroidManifest, not here.
/// Override any unit via `--dart-define=ADS_ANDROID_BANNER_ID=…` etc.

/// Production banner (AdMob → Ad units → Banner). Empty env → this ID on Android.
const String _androidBannerProductionId = 'ca-app-pub-2401883970086774/4696756730';

/// Set when you create Interstitial / Rewarded units in AdMob (must be …/number, not …~app).
const String _androidInterstitialProductionId = 'ca-app-pub-2401883970086774/4776647787';
const String _androidRewardedProductionId = 'ca-app-pub-2401883970086774/1603822988';

const String _androidBannerTestId = 'ca-app-pub-3940256099942544/6300978111';
const String _iosBannerTestId = 'ca-app-pub-3940256099942544/2934735716';
const String _androidInterstitialTestId = 'ca-app-pub-3940256099942544/1033173712';
const String _iosInterstitialTestId = 'ca-app-pub-3940256099942544/4411468910';
const String _androidRewardedTestId = 'ca-app-pub-3940256099942544/5224354917';
const String _iosRewardedTestId = 'ca-app-pub-3940256099942544/1712485313';

const String _androidBannerIdFromEnv = String.fromEnvironment(
  'ADS_ANDROID_BANNER_ID',
  defaultValue: '',
);
const String _iosBannerIdFromEnv = String.fromEnvironment(
  'ADS_IOS_BANNER_ID',
  defaultValue: '',
);
const String _androidInterstitialIdFromEnv = String.fromEnvironment(
  'ADS_ANDROID_INTERSTITIAL_ID',
  defaultValue: '',
);
const String _iosInterstitialIdFromEnv = String.fromEnvironment(
  'ADS_IOS_INTERSTITIAL_ID',
  defaultValue: '',
);
const String _androidRewardedIdFromEnv = String.fromEnvironment(
  'ADS_ANDROID_REWARDED_ID',
  defaultValue: '',
);
const String _iosRewardedIdFromEnv = String.fromEnvironment(
  'ADS_IOS_REWARDED_ID',
  defaultValue: '',
);
const String _intimacyEventCounterKey = 'ad_intimacy_event_counter';

/// AdMob on iOS is off until you set [Info.plist] GADApplicationIdentifier and real units.
const bool _kEnableIosAds = false;

/// Call from the app entrypoint. Skips web; on iOS no-ops until iOS ads are enabled in this file.
Future<void> initializeGoogleMobileAdsSdk() async {
  if (kIsWeb) return;
  if (defaultTargetPlatform == TargetPlatform.iOS && !_kEnableIosAds) return;
  try {
    await MobileAds.instance.initialize();
  } on MissingPluginException catch (e) {
    AppLogger.debug('Google Mobile Ads plugin not ready yet: $e');
  } on PlatformException catch (e) {
    AppLogger.debug('Google Mobile Ads initialization failed: $e');
  }
}

final adServiceProvider = Provider<AdService>((ref) => AdService());

class AdService {
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized || kIsWeb) return;
    if (defaultTargetPlatform == TargetPlatform.iOS && !_kEnableIosAds) return;
    try {
      await MobileAds.instance.initialize();
      _initialized = true;
    } on MissingPluginException {
      // Happens after hot-restart right after adding plugin; full restart fixes it.
      _initialized = false;
    } on PlatformException {
      _initialized = false;
    }
  }

  String? bannerAdUnitId() {
    if (kIsWeb) return null;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        if (_androidBannerIdFromEnv.isNotEmpty) return _androidBannerIdFromEnv;
        return _androidBannerProductionId;
      case TargetPlatform.iOS:
        if (!_kEnableIosAds) return null;
        return _iosBannerIdFromEnv.isNotEmpty
            ? _iosBannerIdFromEnv
            : _iosBannerTestId;
      default:
        return null;
    }
  }

  String? _interstitialAdUnitId() {
    if (kIsWeb) return null;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        if (_androidInterstitialIdFromEnv.isNotEmpty) {
          return _androidInterstitialIdFromEnv;
        }
        if (_androidInterstitialProductionId.isNotEmpty) {
          return _androidInterstitialProductionId;
        }
        return _androidInterstitialTestId;
      case TargetPlatform.iOS:
        if (!_kEnableIosAds) return null;
        return _iosInterstitialIdFromEnv.isNotEmpty
            ? _iosInterstitialIdFromEnv
            : _iosInterstitialTestId;
      default:
        return null;
    }
  }

  String? _rewardedAdUnitId() {
    if (kIsWeb) return null;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        if (_androidRewardedIdFromEnv.isNotEmpty) {
          return _androidRewardedIdFromEnv;
        }
        if (_androidRewardedProductionId.isNotEmpty) {
          return _androidRewardedProductionId;
        }
        return _androidRewardedTestId;
      case TargetPlatform.iOS:
        if (!_kEnableIosAds) return null;
        return _iosRewardedIdFromEnv.isNotEmpty
            ? _iosRewardedIdFromEnv
            : _iosRewardedTestId;
      default:
        return null;
    }
  }

  Future<void> maybeShowAdAfterMemoryAdded({required bool isPremium}) async {
    if (isPremium) return;
    await _showInterstitialAd();
  }

  Future<void> maybeShowAdAfterIntimacyOrEventAdded({
    required bool isPremium,
  }) async {
    if (isPremium) return;
    final prefs = await SharedPreferences.getInstance();
    final currentCount = prefs.getInt(_intimacyEventCounterKey) ?? 0;
    final nextCount = currentCount + 1;
    if (nextCount >= 3) {
      await prefs.setInt(_intimacyEventCounterKey, 0);
      await _showInterstitialAd();
      return;
    }
    await prefs.setInt(_intimacyEventCounterKey, nextCount);
  }

  Future<bool> showRewardedAdForSp() async {
    final adUnitId = _rewardedAdUnitId();
    if (adUnitId == null) return false;
    await initialize();

    final rewarded = await _loadRewardedAd(adUnitId);
    if (rewarded == null) return false;

    bool rewardEarned = false;
    final completed = Completer<bool>();
    rewarded.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        if (!completed.isCompleted) completed.complete(rewardEarned);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        if (!completed.isCompleted) completed.complete(false);
      },
    );

    rewarded.show(
      onUserEarnedReward: (ad, reward) {
        rewardEarned = true;
      },
    );

    return completed.future;
  }

  Future<void> _showInterstitialAd() async {
    final adUnitId = _interstitialAdUnitId();
    if (adUnitId == null) return;
    await initialize();

    final interstitial = await _loadInterstitialAd(adUnitId);
    if (interstitial == null) return;

    final completed = Completer<void>();
    interstitial.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        if (!completed.isCompleted) completed.complete();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        if (!completed.isCompleted) completed.complete();
      },
    );

    interstitial.show();
    await completed.future;
  }

  Future<InterstitialAd?> _loadInterstitialAd(String adUnitId) async {
    final completer = Completer<InterstitialAd?>();
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => completer.complete(ad),
        onAdFailedToLoad: (error) => completer.complete(null),
      ),
    );
    return completer.future;
  }

  Future<RewardedAd?> _loadRewardedAd(String adUnitId) async {
    final completer = Completer<RewardedAd?>();
    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => completer.complete(ad),
        onAdFailedToLoad: (error) => completer.complete(null),
      ),
    );
    return completer.future;
  }
}

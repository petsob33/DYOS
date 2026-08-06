import 'dart:async';
import 'dart:developer' as developer;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'app.dart';
import 'core/services/app_logger.dart';
import 'firebase_options.dart';

/// Background handler for FCM – runs when app is terminated/background.
/// Must be top-level. Notification is shown by system if message has notification payload.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Optional: handle data payload; system shows notification from payload when in background
}

/// RevenueCat API key. Set via --dart-define=REVENUECAT_API_KEY=your_key
/// or leave empty to skip RevenueCat (e.g. for development without store).
const String _revenueCatApiKey = String.fromEnvironment(
  'REVENUECAT_API_KEY',
  defaultValue: '',
);

/// Enable Firebase App Check (requires the API enabled in Google Cloud for the project).
/// Android/iOS debug & profile always use the **debug** provider so native Firebase does not
/// log `No AppCheckProvider installed`. Release builds skip App Check unless this is true
/// (then Android uses Play Integrity).
const bool _enableAppCheck = bool.fromEnvironment(
  'ENABLE_APP_CHECK',
  defaultValue: false,
);

/// Web reCAPTCHA v3 key for App Check (required only on web when enabled).
const String _appCheckWebRecaptchaKey = String.fromEnvironment(
  'APP_CHECK_WEB_RECAPTCHA_KEY',
  defaultValue: '',
);

/// On a physical device, allow Play Integrity even in debug/profile (rare testing only).
const bool _appCheckAllowIntegrityInDebug = bool.fromEnvironment(
  'APP_CHECK_ALLOW_INTEGRITY_IN_DEBUG',
  defaultValue: false,
);

String _sanitizeLogMessage(String message) {
  return message
      .replaceAll(
        RegExp(r'([A-Za-z0-9._%+-]+)@([A-Za-z0-9.-]+\.[A-Za-z]{2,})'),
        '[REDACTED_EMAIL]',
      )
      .replaceAll(RegExp(r'\b(coupleId|userId|uid|token):\s*[^,\s]+'), r'$1:[REDACTED]')
      .replaceAll(RegExp(r'\bmessage:\s*.+$'), 'message:[REDACTED]');
}

/// Some emulators wrongly report [AndroidDeviceInfo.isPhysicalDevice] == true.
bool _androidLooksLikeEmulator(AndroidDeviceInfo info) {
  final blob =
      '${info.model} ${info.manufacturer} ${info.product} ${info.device} ${info.fingerprint}'
          .toLowerCase();
  return blob.contains('sdk_gphone') ||
      blob.contains('generic') ||
      blob.contains('emulator') ||
      blob.contains('ranchu') ||
      blob.contains('google_sdk');
}

void _configureSafeDebugLogging() {
  final sink = debugPrintSynchronously;
  debugPrint = (String? message, {int? wrapWidth}) {
    if (!kDebugMode || message == null || message.isEmpty) return;
    sink(_sanitizeLogMessage(message), wrapWidth: wrapWidth);
  };
}

Future<void> _configureAppCheck() async {
  try {
    if (kIsWeb) {
      if (!_enableAppCheck) {
        AppLogger.debug(
          'App Check off on web (default). Set ENABLE_APP_CHECK=true and '
          'APP_CHECK_WEB_RECAPTCHA_KEY when ready.',
        );
        return;
      }
      if (_appCheckWebRecaptchaKey.isEmpty) {
        AppLogger.debug('App Check skipped on web: APP_CHECK_WEB_RECAPTCHA_KEY is empty.');
        return;
      }
      await FirebaseAppCheck.instance.activate(
        webProvider: ReCaptchaV3Provider(_appCheckWebRecaptchaKey),
      );
      AppLogger.debug('App Check activated for web.');
      return;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      // `kReleaseMode` is true for profile too; only skip for real product release builds.
      final isProductRelease = kReleaseMode && !kProfileMode;
      if (isProductRelease && !_enableAppCheck) {
        AppLogger.debug(
          'App Check off (Android product release). Pass --dart-define=ENABLE_APP_CHECK=true '
          'for Play Integrity when backend enforcement is on.',
        );
        return;
      }
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final onRealDevice =
          androidInfo.isPhysicalDevice && !_androidLooksLikeEmulator(androidInfo);
      // Play Integrity fails on emulators (403 App attestation failed); always use debug there.
      final usePlayIntegrity = onRealDevice &&
          _enableAppCheck &&
          (isProductRelease || _appCheckAllowIntegrityInDebug);
      await FirebaseAppCheck.instance.activate(
        androidProvider:
            usePlayIntegrity ? AndroidProvider.playIntegrity : AndroidProvider.debug,
      );
      AppLogger.debug(
        usePlayIntegrity
            ? 'App Check: Android Play Integrity.'
            : 'App Check: Android debug provider '
                '(emulator or non-release; register token in Firebase Console → App Check if enforced).',
      );
      return;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      final isProductRelease = kReleaseMode && !kProfileMode;
      if (isProductRelease && !_enableAppCheck) {
        AppLogger.debug(
          'App Check off (Apple product release). Pass --dart-define=ENABLE_APP_CHECK=true to enable.',
        );
        return;
      }
      var onPhysicalApple = defaultTargetPlatform != TargetPlatform.iOS;
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        onPhysicalApple = (await DeviceInfoPlugin().iosInfo).isPhysicalDevice;
      }
      final useProductionApple = onPhysicalApple &&
          _enableAppCheck &&
          (isProductRelease || _appCheckAllowIntegrityInDebug);
      await FirebaseAppCheck.instance.activate(
        appleProvider:
            useProductionApple ? AppleProvider.deviceCheck : AppleProvider.debug,
      );
      AppLogger.debug(
        useProductionApple
            ? 'App Check: Apple DeviceCheck.'
            : 'App Check: Apple debug provider (simulator or non-release; register token if enforced).',
      );
      return;
    }

    AppLogger.debug('App Check: platform not configured, skipping activation.');
  } catch (e) {
    AppLogger.debug('App Check activation failed: $e');
  }
}

/// Crashlytics collection is disabled in debug builds (kDebugMode) so local
/// development/test crashes don't pollute the production dashboard; enabled
/// for profile and release.
Future<void> _configureCrashlytics() async {
  // firebase_crashlytics has no web platform implementation (its pubspec
  // only declares android/ios/macos) — any call on web throws
  // MissingPluginException, which is fatal here since it's unguarded.
  if (kIsWeb) return;

  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);

  FlutterError.onError = (FlutterErrorDetails details) {
    if (kDebugMode) {
      FlutterError.presentError(details);
    } else {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    }
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
}

Future<void> main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      _configureSafeDebugLogging();
      await Firebase.initializeApp(
        options: kIsWeb ? DefaultFirebaseOptions.web : null,
      );
      await _configureCrashlytics();
      await _configureAppCheck();
      await _configureRevenueCat();
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      runApp(const ProviderScope(child: OurOSRoot()));
    },
    (error, stack) {
      // Errors outside the Flutter framework and not caught by
      // PlatformDispatcher.instance.onError (e.g. thrown from async code
      // started before runZonedGuarded's zone takes over) land here.
      // Crashlytics has no web implementation, so skip it there instead of
      // throwing a second, truly-uncaught error while trying to report one.
      if (kIsWeb) return;
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    },
  );
}

Future<void> _configureRevenueCat() async {
  developer.log('Attempting to configure RevenueCat...', name: 'RevenueCat');
  if (_revenueCatApiKey.isEmpty) {
    developer.log('RevenueCat API Key is missing. Skipping configuration.', name: 'RevenueCat');
    return;
  }
  try {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    await Purchases.configure(
      PurchasesConfiguration(_revenueCatApiKey)..appUserID = uid,
    );
    developer.log('RevenueCat configured successfully.', name: 'RevenueCat');
  } catch (e) {
    developer.log('RevenueCat configure failed: $e', name: 'RevenueCat');
    AppLogger.debug('RevenueCat configure failed: $e');
  }
}

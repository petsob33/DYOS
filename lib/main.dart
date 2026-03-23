import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'app.dart';

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

/// Enable App Check client-side attestation.
/// Set via --dart-define=ENABLE_APP_CHECK=true in production.
const bool _enableAppCheck = bool.fromEnvironment(
  'ENABLE_APP_CHECK',
  defaultValue: false,
);

/// Web reCAPTCHA v3 key for App Check (required only on web when enabled).
const String _appCheckWebRecaptchaKey = String.fromEnvironment(
  'APP_CHECK_WEB_RECAPTCHA_KEY',
  defaultValue: '',
);

Future<void> _configureAppCheck() async {
  if (!_enableAppCheck) {
    debugPrint('App Check disabled (ENABLE_APP_CHECK=false).');
    return;
  }

  try {
    if (kIsWeb) {
      if (_appCheckWebRecaptchaKey.isEmpty) {
        debugPrint('App Check skipped on web: APP_CHECK_WEB_RECAPTCHA_KEY is empty.');
        return;
      }
      await FirebaseAppCheck.instance.activate(
        webProvider: ReCaptchaV3Provider(_appCheckWebRecaptchaKey),
      );
      debugPrint('App Check activated for web.');
      return;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.playIntegrity,
      );
      debugPrint('App Check activated for Android (Play Integrity).');
      return;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      await FirebaseAppCheck.instance.activate(
        appleProvider: AppleProvider.deviceCheck,
      );
      debugPrint('App Check activated for Apple platforms (DeviceCheck).');
      return;
    }

    debugPrint('App Check: platform not configured, skipping activation.');
  } catch (e) {
    debugPrint('App Check activation failed: $e');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await _configureAppCheck();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  if (_revenueCatApiKey.isNotEmpty) {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      await Purchases.configure(
        PurchasesConfiguration(_revenueCatApiKey)..appUserID = uid,
      );
    } catch (e) {
      debugPrint('RevenueCat configure failed: $e');
    }
  }
  runApp(const ProviderScope(child: OurOSRoot()));
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'app.dart';
import 'core/services/app_logger.dart';

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

String _sanitizeLogMessage(String message) {
  return message
      .replaceAll(
        RegExp(r'([A-Za-z0-9._%+-]+)@([A-Za-z0-9.-]+\.[A-Za-z]{2,})'),
        '[REDACTED_EMAIL]',
      )
      .replaceAll(RegExp(r'\b(coupleId|userId|uid|token):\s*[^,\s]+'), r'$1:[REDACTED]')
      .replaceAll(RegExp(r'\bmessage:\s*.+$'), 'message:[REDACTED]');
}

void _configureSafeDebugLogging() {
  final sink = debugPrintSynchronously;
  debugPrint = (String? message, {int? wrapWidth}) {
    if (!kDebugMode || message == null || message.isEmpty) return;
    sink(_sanitizeLogMessage(message), wrapWidth: wrapWidth);
  };
}

Future<void> _configureAppCheck() async {
  if (!_enableAppCheck) {
    AppLogger.debug('App Check disabled (ENABLE_APP_CHECK=false).');
    return;
  }

  try {
    if (kIsWeb) {
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
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.playIntegrity,
      );
      AppLogger.debug('App Check activated for Android (Play Integrity).');
      return;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      await FirebaseAppCheck.instance.activate(
        appleProvider: AppleProvider.deviceCheck,
      );
      AppLogger.debug('App Check activated for Apple platforms (DeviceCheck).');
      return;
    }

    AppLogger.debug('App Check: platform not configured, skipping activation.');
  } catch (e) {
    AppLogger.debug('App Check activation failed: $e');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _configureSafeDebugLogging();
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
      AppLogger.debug('RevenueCat configure failed: $e');
    }
  }
  runApp(const ProviderScope(child: OurOSRoot()));
}

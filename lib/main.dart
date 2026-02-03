import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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

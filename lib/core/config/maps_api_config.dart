import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';

/// Resolves the same API key used by Google Maps / Places native SDKs.
///
/// Android: `com.google.android.geo.API_KEY` from the merged manifest
/// (filled from `GOOGLE_MAPS_API_KEY` in `local.properties` / env).
/// iOS: `GOOGLE_PLACES_API_KEY` from Info.plist (xcconfig at build time).
///
/// Optional override: `--dart-define=GOOGLE_MAPS_API_KEY=...`
class MapsApiConfig {
  MapsApiConfig._();

  static const MethodChannel _channel = MethodChannel('com.dyos.app/maps_config');

  /// True if [key] looks like a real key (non-empty, not an Xcode placeholder).
  static bool isUsableKey(String? key) {
    if (key == null) return false;
    final t = key.trim();
    if (t.isEmpty) return false;
    if (t.startsWith(r'$(')) return false;
    if (t == 'your_key_here') return false;
    return true;
  }

  /// Resolved key for this install/build, or `null` if maps/places cannot run.
  static Future<String?> resolveGeoApiKey() async {
    if (kIsWeb) return null;
    if (!Platform.isAndroid && !Platform.isIOS) return null;

    try {
      final key = await _channel.invokeMethod<String>('getGeoApiKey');
      if (isUsableKey(key)) return key!.trim();
    } on PlatformException catch (_) {
      // Channel not registered (tests / unusual embedder).
    } catch (_) {}

    const fromDefine = String.fromEnvironment(
      'GOOGLE_MAPS_API_KEY',
      defaultValue: '',
    );
    if (fromDefine.trim().isNotEmpty) return fromDefine.trim();

    return null;
  }
}

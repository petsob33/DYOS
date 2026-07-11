import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geocoding/geocoding.dart' as native_geocoding;
import 'package:http/http.dart' as http;

/// A geocoded address result, platform-agnostic.
class GeocodedLocation {
  const GeocodedLocation({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}

/// Looks up [address] and returns matching coordinates.
///
/// On Android/iOS this delegates to the `geocoding` package (native SDKs).
/// On web, `geocoding` has no platform implementation at all (no
/// geocoding_web package exists), so this calls the Geocoding REST API
/// directly with the same Maps API key used for the JS SDK
/// (see MapsApiConfig - that key is HTTP-referrer restricted to this app's
/// domains, so it's fine to use client-side).
Future<List<GeocodedLocation>> geocodeAddress(
  String address, {
  required String? webApiKey,
}) async {
  if (kIsWeb) {
    if (webApiKey == null || webApiKey.isEmpty) return [];
    final uri = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
      'address': address,
      'key': webApiKey,
    });
    final response = await http.get(uri);
    if (response.statusCode != 200) return [];
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['status'] != 'OK') return [];
    final results = data['results'] as List<dynamic>? ?? [];
    return results.map((r) {
      final location = (r as Map<String, dynamic>)['geometry']['location'] as Map<String, dynamic>;
      return GeocodedLocation(
        latitude: (location['lat'] as num).toDouble(),
        longitude: (location['lng'] as num).toDouble(),
      );
    }).toList();
  }

  final locations = await native_geocoding.locationFromAddress(address);
  return locations
      .map((l) => GeocodedLocation(latitude: l.latitude, longitude: l.longitude))
      .toList();
}

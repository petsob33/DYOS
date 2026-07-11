import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_autocomplete/google_places_autocomplete.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/config/maps_api_config.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/services/geocoding_service.dart';
import '../../../../core/theme/app_theme.dart';

/// Default center (Prague) when no initial position
const double _defaultLat = 50.0755;
const double _defaultLng = 14.4378;
const double _defaultZoom = 10.0;

/// Full-screen screen to pick a place on the map.
/// User taps on the map to set a marker; can optionally enter a place name.
/// Returns a map with keys: name (String?), lat (double), lng (double).
Future<Map<String, dynamic>?> pickPlaceOnMap(
  BuildContext context, {
  Map<String, dynamic>? initialLocation,
}) async {
  return Navigator.of(context).push<Map<String, dynamic>>(
    MaterialPageRoute<Map<String, dynamic>>(
      builder: (context) => PickPlaceScreen(initialLocation: initialLocation),
    ),
  );
}

class PickPlaceScreen extends StatefulWidget {
  const PickPlaceScreen({super.key, this.initialLocation});

  final Map<String, dynamic>? initialLocation;

  @override
  State<PickPlaceScreen> createState() => _PickPlaceScreenState();
}

class _PickPlaceScreenState extends State<PickPlaceScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  GoogleMapController? _mapController;
  LatLng? _selectedPosition;
  final Set<Marker> _markers = {};
  bool _isSearching = false;
  bool _isGettingLocation = false;
  bool _mapsConfigResolved = false;
  bool _mapsSdkAvailable = false;
  String? _resolvedApiKey;
  List<Prediction> _predictions = [];
  bool _placesLoading = false;
  bool _placesReady = false;
  GooglePlacesAutocomplete? _places;

  @override
  void initState() {
    super.initState();
    final loc = widget.initialLocation;
    if (loc != null) {
      final lat = loc['lat'];
      final lng = loc['lng'];
      final name = loc['name'] as String?;
      if (lat is num && lng is num) {
        _selectedPosition = LatLng(lat.toDouble(), lng.toDouble());
        _updateMarker();
        if (name != null && name.isNotEmpty) {
          _nameController.text = name;
        }
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final geoKey = await MapsApiConfig.resolveGeoApiKey();
      if (!mounted) return;
      final mapsOk = MapsApiConfig.isUsableKey(geoKey);
      setState(() {
        _mapsConfigResolved = true;
        _mapsSdkAvailable = mapsOk;
        _resolvedApiKey = geoKey;
      });
      if (!mapsOk) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Add GOOGLE_MAPS_API_KEY to android/local.properties (Android) or GOOGLE_PLACES_API_KEY in ios Secrets.xcconfig, then rebuild. You can still search by address.',
              ),
              backgroundColor: AppTheme.colors.warning,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 6),
            ),
          );
        }
        return;
      }

      // google_places_autocomplete has no web platform implementation, and
      // dart:io's Platform (used below for isPhysicalDevice) throws on web -
      // skip predictions entirely there; typed-address search still works
      // via geocodeAddress's web REST fallback.
      if (kIsWeb) return;

      final deviceInfo = DeviceInfoPlugin();
      final isPhysicalDevice = Platform.isAndroid
          ? (await deviceInfo.androidInfo).isPhysicalDevice
          : (await deviceInfo.iosInfo).isPhysicalDevice;
      if (isPhysicalDevice) {
        if (mounted) setState(() => _placesReady = false);
        return;
      }
      _places = GooglePlacesAutocomplete(
        predictionsListener: (p) {
          if (mounted) setState(() => _predictions = p);
        },
        loadingListener: (loading) {
          if (mounted) setState(() => _placesLoading = loading);
        },
        onError: (error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Places: ${error.message}'),
                backgroundColor: AppTheme.colors.love,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 5),
                action: SnackBarAction(
                  label: 'OK',
                  textColor: Colors.white,
                  onPressed: () {},
                ),
              ),
            );
          }
        },
        debounceTime: 300,
      );
      try {
        await _places?.initialize();
        if (mounted) setState(() => _placesReady = true);
      } catch (e) {
        if (mounted) {
          setState(() => _placesReady = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Search suggestions unavailable. Use the search icon to find places.'),
              backgroundColor: AppTheme.colors.warning,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _places?.dispose();
    _mapController?.dispose();
    _mapController = null;
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onSelectPlace(Prediction prediction) async {
    final placeId = prediction.placeId;
    if (placeId == null || _places == null) return;
    setState(() => _isSearching = true);
    try {
      final details = await _places!.getPlaceDetails(placeId);
      if (!mounted) return;
      if (details?.location != null) {
        final latLng = LatLng(details!.location!.lat, details.location!.lng);
        setState(() {
          _selectedPosition = latLng;
          _predictions = [];
          _updateMarker();
          _nameController.text =
              details.formattedAddress ?? details.name ?? prediction.title ?? '';
        });
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(latLng, 16),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not load place details'),
            backgroundColor: AppTheme.colors.love,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _searchAddress() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    setState(() => _isSearching = true);
    try {
      final locations = await geocodeAddress(query, webApiKey: _resolvedApiKey);
      if (locations.isEmpty || !mounted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('No results found for this address'),
              backgroundColor: AppTheme.colors.love,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
        return;
      }
      final loc = locations.first;
      final latLng = LatLng(loc.latitude, loc.longitude);
      setState(() {
        _selectedPosition = latLng;
        _updateMarker();
        _nameController.text = query;
      });
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 16));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Search failed: ${e.toString()}'),
            backgroundColor: AppTheme.colors.love,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _goToMyLocation() async {
    setState(() => _isGettingLocation = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Location services are disabled'),
            backgroundColor: AppTheme.colors.love,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Location permission denied'),
              backgroundColor: AppTheme.colors.love,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      final latLng = LatLng(position.latitude, position.longitude);
      setState(() {
        _selectedPosition = latLng;
        _updateMarker();
      });
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 16));
    } catch (e) {
      if (mounted) {
        final message = e is MissingPluginException
            ? 'Restart the app to use My location.'
            : 'Could not get location: ${e.toString()}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppTheme.colors.love,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGettingLocation = false);
    }
  }

  void _updateMarker() {
    if (_selectedPosition == null) {
      _markers.clear();
    } else {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('selected'),
          position: _selectedPosition!,
          draggable: true,
          onDragEnd: (LatLng position) {
            setState(() {
              _selectedPosition = position;
              _updateMarker();
            });
          },
        ),
      );
    }
    setState(() {});
  }

  void _onMapTap(LatLng position) {
    setState(() {
      _selectedPosition = position;
      _updateMarker();
    });
  }

  Future<void> _confirm() async {
    if (_selectedPosition == null) return;
    final name = _nameController.text.trim();
    final result = <String, dynamic>{
      'lat': _selectedPosition!.latitude,
      'lng': _selectedPosition!.longitude,
    };
    if (name.isNotEmpty) {
      result['name'] = name;
    } else {
      result['name'] = '${_selectedPosition!.latitude.toStringAsFixed(4)}, ${_selectedPosition!.longitude.toStringAsFixed(4)}';
    }
    if (!mounted) return;
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final initialCamera = _selectedPosition != null
        ? CameraPosition(
            target: _selectedPosition!,
            zoom: _defaultZoom,
          )
        : CameraPosition(
            target: LatLng(_defaultLat, _defaultLng),
            zoom: _defaultZoom,
          );

    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      appBar: AppBar(
        backgroundColor: AppTheme.colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(PhosphorIconsBold.arrowLeft, color: AppTheme.colors.text),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
        ),
        title: Text(
          'Pick a place',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.colors.text,
              ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: AppTheme.colors.textSecondary.withValues(alpha: 0.12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  !_mapsConfigResolved
                      ? const Center(child: CircularProgressIndicator())
                      : _mapsSdkAvailable
                          ? GoogleMap(
                              initialCameraPosition: initialCamera,
                              markers: _markers,
                              onTap: _onMapTap,
                              onMapCreated: (GoogleMapController c) {
                                _mapController = c;
                                if (_selectedPosition != null) {
                                  _mapController?.animateCamera(
                                    CameraUpdate.newLatLng(_selectedPosition!),
                                  );
                                }
                              },
                              myLocationEnabled: true,
                              myLocationButtonEnabled: true,
                              mapToolbarEnabled: false,
                              liteModeEnabled: false,
                            )
                          : Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text(
                                  'Map preview needs a Google Maps API key in the native build (see docs/ANDROID_GOOGLE_API_KEY.md). Search by address works below.',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppTheme.colors.textSecondary,
                                      ),
                                ),
                              ),
                            ),
                  Positioned(
                    top: 8,
                    left: 8,
                    right: 8,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Material(
                                color: AppTheme.colors.card,
                                borderRadius: BorderRadius.circular(12),
                                child: TextField(
                                  controller: _searchController,
                                  decoration: InputDecoration(
                                    hintText: 'Search place or address...',
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                    suffixIcon: _placesLoading || _isSearching
                                        ? const Padding(
                                            padding: EdgeInsets.all(12),
                                            child: SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            ),
                                          )
                                        : IconButton(
                                            icon: Icon(
                                              PhosphorIconsBold.magnifyingGlass,
                                              color: AppTheme.colors.primary,
                                            ),
                                            onPressed: _isSearching ? null : _searchAddress,
                                          ),
                                  ),
                                  onChanged: _placesReady
                                      ? (value) => _places?.getPredictions(value)
                                      : null,
                                  onSubmitted: (_) => _searchAddress(),
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: AppTheme.colors.text,
                                      ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Material(
                              color: AppTheme.colors.card,
                              borderRadius: BorderRadius.circular(12),
                              child: IconButton(
                                onPressed: _isGettingLocation ? null : _goToMyLocation,
                                icon: _isGettingLocation
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : Icon(
                                        PhosphorIconsBold.navigationArrow,
                                        color: AppTheme.colors.primary,
                                      ),
                                tooltip: 'My location',
                              ),
                            ),
                          ],
                        ),
                        if (_predictions.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Material(
                            elevation: 4,
                            borderRadius: BorderRadius.circular(12),
                            color: AppTheme.colors.card,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 240),
                              child: ListView.separated(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                itemCount: _predictions.length,
                                separatorBuilder: (_, __) => Divider(
                                  height: 1,
                                  color: AppTheme.colors.textSecondary.withValues(alpha: 0.2),
                                ),
                                itemBuilder: (context, index) {
                                  final p = _predictions[index];
                                  return ListTile(
                                    leading: Icon(
                                      PhosphorIconsBold.mapPin,
                                      size: 20,
                                      color: AppTheme.colors.primary,
                                    ),
                                    title: Text(
                                      p.title ?? p.structuredFormatting?.mainText ?? '',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.colors.text,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: (p.description ?? p.structuredFormatting?.secondaryText ?? '')
                                        .isNotEmpty
                                        ? Text(
                                            p.description ?? p.structuredFormatting?.secondaryText ?? '',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  color: AppTheme.colors.textSecondary,
                                                ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          )
                                        : null,
                                    onTap: () => _onSelectPlace(p),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom card: instructions or selected position + name field + buttons
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppTheme.colors.card,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.colors.shadow,
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: _selectedPosition == null
                  ? Text(
                      'Tap on the map to set the memory location',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.colors.textSecondary,
                          ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Place name (optional)',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppTheme.colors.text,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: 'e.g. Restaurant, Park',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: AppTheme.colors.textSecondary.withValues(alpha: 0.2),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: AppTheme.colors.textSecondary.withValues(alpha: 0.2),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: AppTheme.colors.primary,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: AppTheme.colors.background,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                          ),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppTheme.colors.text,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.colors.textSecondary,
                                  side: BorderSide(
                                    color: AppTheme.colors.textSecondary.withValues(alpha: 0.5),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.md,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _confirm,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.colors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.md,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text('Confirm'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

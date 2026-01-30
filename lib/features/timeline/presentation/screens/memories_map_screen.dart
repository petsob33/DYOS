import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_autocomplete/google_places_autocomplete.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/memory_model.dart';
import '../memory_provider.dart';

/// Default center when no memories with location
const double _defaultLat = 50.0755;
const double _defaultLng = 14.4378;
const double _defaultZoom = 6.0;

/// Screen showing a map with markers for memories that have a location.
class MemoriesMapScreen extends ConsumerWidget {
  const MemoriesMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memoriesAsync = ref.watch(memoriesStreamProvider);

    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      appBar: AppBar(
        backgroundColor: AppTheme.colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(PhosphorIconsBold.arrowLeft, color: AppTheme.colors.text),
          onPressed: () => context.pop(),
          tooltip: 'Back',
        ),
        title: Text(
          'Memories map',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.colors.text,
              ),
        ),
      ),
      body: memoriesAsync.when(
        data: (memories) {
          final memoriesWithLocation = memories
              .where((m) {
                final loc = m.location;
                if (loc == null) return false;
                final lat = loc['lat'];
                final lng = loc['lng'];
                return lat is num && lng is num;
              })
              .toList();

          if (memoriesWithLocation.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    PhosphorIconsBold.mapPin,
                    size: 64,
                    color: AppTheme.colors.textSecondary.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'No memories with a place yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.colors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Add a place when creating a memory to see it here',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.colors.textSecondary,
                        ),
                  ),
                ],
              ),
            );
          }

          return _MemoriesMapContent(memories: memoriesWithLocation);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(
            'Error loading memories: $error',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.colors.love,
                ),
          ),
        ),
      ),
    );
  }
}

class _MemoriesMapContent extends StatefulWidget {
  const _MemoriesMapContent({required this.memories});

  final List<Memory> memories;

  @override
  State<_MemoriesMapContent> createState() => _MemoriesMapContentState();
}

class _MemoriesMapContentState extends State<_MemoriesMapContent> {
  final TextEditingController _searchController = TextEditingController();
  GoogleMapController? _mapController;
  Memory? _selectedMemory;
  bool _isSearching = false;
  bool _isGettingLocation = false;
  bool _mapReady = false;
  List<Prediction> _predictions = [];
  bool _placesLoading = false;
  bool _placesReady = false;
  GooglePlacesAutocomplete? _places;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      setState(() => _mapReady = true);
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
        setState(() => _predictions = []);
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(latLng, 14),
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
      final locations = await locationFromAddress(query);
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

  Set<Marker> _buildMarkers() {
    final Set<Marker> markers = {};
    for (final memory in widget.memories) {
      final loc = memory.location!;
      final lat = (loc['lat'] as num).toDouble();
      final lng = (loc['lng'] as num).toDouble();
      markers.add(
        Marker(
          markerId: MarkerId(memory.id),
          position: LatLng(lat, lng),
          onTap: () {
            setState(() => _selectedMemory = memory);
            context.push('/memory/detail', extra: memory);
          },
        ),
      );
    }
    return markers;
  }

  CameraPosition _initialCameraPosition() {
    if (widget.memories.isEmpty) {
      return CameraPosition(
        target: LatLng(_defaultLat, _defaultLng),
        zoom: _defaultZoom,
      );
    }
    double minLat = 90, maxLat = -90, minLng = 180, maxLng = -180;
    for (final memory in widget.memories) {
      final loc = memory.location!;
      final lat = (loc['lat'] as num).toDouble();
      final lng = (loc['lng'] as num).toDouble();
      if (lat < minLat) minLat = lat;
      if (lat > maxLat) maxLat = lat;
      if (lng < minLng) minLng = lng;
      if (lng > maxLng) maxLng = lng;
    }
    final centerLat = (minLat + maxLat) / 2;
    final centerLng = (minLng + maxLng) / 2;
    return CameraPosition(
      target: LatLng(centerLat, centerLng),
      zoom: _defaultZoom,
    );
  }

  void _fitBounds() {
    if (_mapController == null || widget.memories.isEmpty) return;
    double minLat = 90, maxLat = -90, minLng = 180, maxLng = -180;
    for (final memory in widget.memories) {
      final loc = memory.location!;
      final lat = (loc['lat'] as num).toDouble();
      final lng = (loc['lng'] as num).toDouble();
      if (lat < minLat) minLat = lat;
      if (lat > maxLat) maxLat = lat;
      if (lng < minLng) minLng = lng;
      if (lng > maxLng) maxLng = lng;
    }
    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        50,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          color: AppTheme.colors.textSecondary.withValues(alpha: 0.12),
          child: _mapReady
              ? GoogleMap(
                  initialCameraPosition: _initialCameraPosition(),
                  markers: _buildMarkers(),
                  onTap: (_) {
                    setState(() {
                      _selectedMemory = null;
                    });
                  },
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                    _fitBounds();
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  liteModeEnabled: false,
                )
              : const Center(child: CircularProgressIndicator()),
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
        if (_selectedMemory != null)
          _MemoryInfoCard(
            memory: _selectedMemory!,
            onClose: () {
              setState(() {
                _selectedMemory = null;
              });
            },
          ),
      ],
    );
  }
}

class _MemoryInfoCard extends StatelessWidget {
  const _MemoryInfoCard({required this.memory, required this.onClose});

  final Memory memory;
  final VoidCallback onClose;

  static String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final locationName = memory.location?['name'] as String?;
    final caption = memory.caption.isEmpty ? 'Untitled' : memory.caption;

    return Positioned(
      left: AppSpacing.lg,
      right: AppSpacing.lg,
      bottom: AppSpacing.lg,
      child: Material(
        elevation: 4,
        shadowColor: AppTheme.colors.shadow,
        borderRadius: BorderRadius.circular(24),
        color: AppTheme.colors.card,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      caption,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.colors.text,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: onClose,
                    icon: Icon(
                      PhosphorIconsBold.x,
                      color: AppTheme.colors.textSecondary,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                _formatDate(memory.date),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.colors.textSecondary,
                    ),
              ),
              if (locationName != null && locationName.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Icon(
                      PhosphorIconsBold.mapPin,
                      size: 14,
                      color: AppTheme.colors.primary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        locationName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.colors.textSecondary,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

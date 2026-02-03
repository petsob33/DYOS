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

// Import vašeho dialogu
import '../widgets/memory_detail_dialog.dart'; 

/// Default center when no memories with location
const double _defaultLat = 50.0755;
const double _defaultLng = 14.4378;
const double _defaultZoom = 6.0;

class MemoriesMapScreen extends ConsumerWidget {
  const MemoriesMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memoriesAsync = ref.watch(memoriesStreamProvider);

    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      resizeToAvoidBottomInset: false,
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
          final memoriesWithLocation = memories.where((m) {
            final loc = m.location;
            if (loc == null) return false;
            final lat = loc['lat'];
            final lng = loc['lng'];
            return lat is num && lng is num;
          }).toList();

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
                ],
              ),
            );
          }

          return _MemoriesMapContent(memories: memoriesWithLocation);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
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
  
  // ZDE JE ZPĚT STAV PRO VYBRANOU VZPOMÍNKU (pro malou kartu)
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
      
      _places = GooglePlacesAutocomplete(
        predictionsListener: (p) {
          if (mounted) setState(() => _predictions = p);
        },
        loadingListener: (loading) {
          if (mounted) setState(() => _placesLoading = loading);
        },
        onError: (error) {
           // Error handling
        },
        debounceTime: 300,
      );
      try {
        await _places?.initialize();
        if (mounted) setState(() => _placesReady = true);
      } catch (e) {
        if (mounted) setState(() => _placesReady = false);
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

  /// Najde nejbližší vzpomínku a vybere ji (zobrazí malou kartu)
  void _findAndSelectClosestMemory(double searchLat, double searchLng) {
    Memory? closestMemory;
    double minDistance = double.infinity;
    const double thresholdMeters = 200; 

    for (final memory in widget.memories) {
      final loc = memory.location;
      if (loc == null) continue;
      
      final memLat = (loc['lat'] as num).toDouble();
      final memLng = (loc['lng'] as num).toDouble();

      final distance = Geolocator.distanceBetween(
        searchLat, searchLng, memLat, memLng
      );

      if (distance < thresholdMeters && distance < minDistance) {
        minDistance = distance;
        closestMemory = memory;
      }
    }

    if (closestMemory != null) {
      setState(() {
        _selectedMemory = closestMemory; // Zobrazí malou kartu
      });
    }
  }

  Future<void> _onSelectPlace(Prediction prediction) async {
    final placeId = prediction.placeId;
    if (placeId == null || _places == null) return;
    setState(() => _isSearching = true);
    try {
      final details = await _places!.getPlaceDetails(placeId);
      if (!mounted) return;
      if (details?.location != null) {
        final lat = details!.location!.lat;
        final lng = details.location!.lng;
        final latLng = LatLng(lat, lng);
        
        setState(() => _predictions = []);
        FocusScope.of(context).unfocus();
        
        _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 16));
        _findAndSelectClosestMemory(lat, lng);
      }
    } catch (_) {
      // Error handling
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
      if (locations.isEmpty || !mounted) return;
      
      final loc = locations.first;
      final latLng = LatLng(loc.latitude, loc.longitude);
      
      FocusScope.of(context).unfocus();
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 16));
      _findAndSelectClosestMemory(loc.latitude, loc.longitude);
    } catch (e) {
      // Error handling
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _goToMyLocation() async {
    setState(() => _isGettingLocation = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition();
      final latLng = LatLng(position.latitude, position.longitude);
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 16));
    } catch (e) {
      // Error handling
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
          // ZMĚNA: Kliknutí na marker jen vybere vzpomínku (zobrazí malou kartu)
          onTap: () {
             setState(() {
               _selectedMemory = memory;
             });
          },
        ),
      );
    }
    return markers;
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
          southwest: LatLng(minLat - 0.05, minLng - 0.05),
          northeast: LatLng(maxLat + 0.05, maxLng + 0.05),
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
        // 1. MAPA
        Container(
          color: AppTheme.colors.textSecondary.withValues(alpha: 0.12),
          child: _mapReady
              ? GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(_defaultLat, _defaultLng),
                    zoom: _defaultZoom,
                  ),
                  markers: _buildMarkers(),
                  onTap: (_) {
                    // Kliknutí do mapy zruší výběr (schová kartu)
                    setState(() {
                      _selectedMemory = null;
                      _predictions = [];
                    });
                    FocusScope.of(context).unfocus();
                  },
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                    _fitBounds();
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                )
              : const Center(child: CircularProgressIndicator()),
        ),

        // 2. VYHLEDÁVÁNÍ (Nahoře)
        Positioned(
          top: 8,
          left: 8,
          right: 8,
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Material(
                        elevation: 4,
                        shadowColor: AppTheme.colors.shadow.withValues(alpha: 0.2),
                        color: AppTheme.colors.card,
                        borderRadius: BorderRadius.circular(12),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search place or address...',
                            hintStyle: TextStyle(color: AppTheme.colors.textSecondary),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
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
                              ? (value) {
                                  if (value.isEmpty) {
                                    setState(() => _predictions = []);
                                  } else {
                                    _places?.getPredictions(value);
                                  }
                                }
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
                      elevation: 4,
                      shadowColor: AppTheme.colors.shadow.withValues(alpha: 0.2),
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
        ),

        // 3. MALÁ KARTA (Dole) - Zobrazí se, když je vybrána vzpomínka
        if (_selectedMemory != null)
          _MemoryInfoCard(
            memory: _selectedMemory!,
            onClose: () {
              setState(() {
                _selectedMemory = null;
              });
            },
            // TADY KLIKNUTÍ OTEVŘE VELKÝ DETAIL
            onTap: () {
              MemoryDetailDialog.show(context, memory: _selectedMemory!);
            },
          ),
      ],
    );
  }
}

// --- WIDGET PRO MALOU KARTU DOLE ---
class _MemoryInfoCard extends StatelessWidget {
  const _MemoryInfoCard({
    required this.memory,
    required this.onClose,
    required this.onTap,
  });

  final Memory memory;
  final VoidCallback onClose;
  final VoidCallback onTap;

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
      child: SafeArea(
        child: Material(
          elevation: 8,
          shadowColor: AppTheme.colors.shadow.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(24),
          color: AppTheme.colors.card,
          child: InkWell(
            onTap: onTap, // Otevírá detail
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppTheme.colors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          memory.category.emoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              caption,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.colors.text,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              _formatDate(memory.date),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.colors.textSecondary,
                                  ),
                            ),
                          ],
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
                  
                  if (locationName != null && locationName.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10, 
                        vertical: 6
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.colors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            PhosphorIconsBold.mapPin,
                            size: 14,
                            color: AppTheme.colors.primary,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              locationName,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.colors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
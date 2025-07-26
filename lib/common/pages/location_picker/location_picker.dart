import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fusion/flutter_fusion.dart';
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:quber_taxi/common/services/mapbox_service.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';
import 'package:quber_taxi/theme/dimensions.dart';
import 'package:quber_taxi/utils/map/geolocator.dart';
import 'package:geolocator/geolocator.dart' as g;
import 'package:quber_taxi/utils/map/turf.dart';
import 'package:turf/turf.dart' as turf;
import 'dart:typed_data';

class LocationPicker extends StatefulWidget {

  const LocationPicker({super.key});

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {

  MapboxMap? _mapController;
  final _mapboxService = MapboxService();
  late turf.Polygon _havanaPolygon;
  
  // New state variables
  PointAnnotationManager? _pointAnnotationManager;
  PointAnnotation? _selectedPointAnnotation;
  bool _isLocationSelected = false;
  double? _selectedLng;
  double? _selectedLat;

  Future<void> _loadHavanaGeoJson() async {
    _havanaPolygon = await loadGeoJsonPolygon("assets/geojson/polygon/CiudadDeLaHabana.geojson");
  }

  @override
  void initState() {
    super.initState();
    _loadHavanaGeoJson();
  }

  void _onMapTap(Point point) async {
    final lng = point.coordinates.lng.toDouble();
    final lat = point.coordinates.lat.toDouble();
    
    // Check if inside of Havana
    if (!kDebugMode) {
      final isInside = isPointInPolygon(lng, lat, _havanaPolygon);
      if(!isInside) {
        showToast(context: context, message: AppLocalizations.of(context)!.destinationsLimitedToHavana);
        return;
      }
    }
    
    // Update selected location
    setState(() {
      _selectedLng = lng;
      _selectedLat = lat;
      _isLocationSelected = true;
    });
    
    // Add or update marker
    await _addOrUpdateMarker(lng, lat);
  }

  Future<void> _addOrUpdateMarker(double lng, double lat) async {
    if (_pointAnnotationManager == null) return;
    
    // Remove existing marker
    if (_selectedPointAnnotation != null) {
      await _pointAnnotationManager!.delete(_selectedPointAnnotation!);
    }
    
    // Create new marker
    final pointAnnotationOptions = PointAnnotationOptions(
      geometry: Point(coordinates: Position(lng, lat)),
      image: await _loadMarkerImage(),
      iconAnchor: IconAnchor.BOTTOM,
    );
    
    _selectedPointAnnotation = await _pointAnnotationManager!.create(pointAnnotationOptions);
  }

  Future<void> _selectLocation() async {
    if (!_isLocationSelected || _selectedLng == null || _selectedLat == null) return;
    
    // Return the place
    final mapboxPlace = await _mapboxService.getMapboxPlace(
        longitude: _selectedLng!, latitude: _selectedLat!
    );
    if(!context.mounted) return;
    context.pop(mapboxPlace);
  }

  @override
  Widget build(BuildContext context) {
    final dimensions = Theme.of(context).extension<DimensionExtension>()!;
    final cameraOptions = CameraOptions(
      center: Point(coordinates: Position(-82.3598, 23.1380)),
      pitch: 45,
      bearing: 0,
      zoom: 17,
    );
    return Scaffold(
      body: Stack(
        children: [
          MapWidget(
            styleUri: MapboxStyles.STANDARD,
            cameraOptions: cameraOptions,
            onMapCreated: (controller) async {
              // Update some mapbox component
              controller.location.updateSettings(LocationComponentSettings(enabled: true));
              controller.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
              _mapController = controller;
              
              // Initialize point annotation manager
              _pointAnnotationManager = await controller.annotations.createPointAnnotationManager();
            },
            onTapListener: (mapContext) {
              _onMapTap(mapContext.point);
            },
          ),
          // Bottom buttons row
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLocationSelected 
                        ? _selectLocation 
                        : () {
                            showToast(
                              context: context,
                              message: AppLocalizations.of(context)!.tapMapToSelectLocation
                            );
                          },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isLocationSelected 
                          ? Theme.of(context).colorScheme.primary 
                          : Theme.of(context).colorScheme.surface,
                        foregroundColor: _isLocationSelected 
                          ? Theme.of(context).colorScheme.onPrimary 
                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.38),
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(dimensions.buttonBorderRadius),
                        ),
                        elevation: _isLocationSelected ? 2 : 0,
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.selectLocation,
                        style: TextStyle(
                          fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  FloatingActionButton(
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(dimensions.buttonBorderRadius),
                      ),
                      onPressed: () async {
                        await requestLocationPermission(
                            context: context,
                            onPermissionGranted: () async {
                              final position = await g.Geolocator.getCurrentPosition();
                              // Check if inside of Havana
                              if (!kDebugMode) {
                                final isInside = isPointInPolygon(position.longitude, position.latitude, _havanaPolygon);
                                if(!context.mounted) return;
                                if(!isInside) {
                                  showToast(
                                      context: context,
                                      message: AppLocalizations.of(context)!.ubicationFailed
                                  );
                                  return;
                                }
                              }
                              _mapController!.easeTo(
                                  CameraOptions(center: Point(coordinates: Position(position.longitude, position.latitude))),
                                  MapAnimationOptions(duration: 500)
                              );
                            },
                            onPermissionDenied: () => showToast(context: context, message: AppLocalizations.of(context)!.permissionsDenied),
                            onPermissionDeniedForever: () =>
                                showToast(context: context, message: AppLocalizations.of(context)!.permissionDeniedPermanently)
                        );
                      },
                      child: Icon(
                          Icons.my_location_outlined,
                          color: Theme.of(context).iconTheme.color,
                          size: Theme.of(context).iconTheme.size
                      )
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<Uint8List> _loadMarkerImage() async {
    // Load the origin marker image
    final byteData = await rootBundle.load('assets/markers/route/x120/origin.png');
    return byteData.buffer.asUint8List();
  }
}
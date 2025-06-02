import 'package:flutter/material.dart';
import 'package:flutter_fusion/flutter_fusion.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:quber_taxi/common/services/mapbox_service.dart';
import 'package:quber_taxi/util/geolocator.dart';
import 'package:geolocator/geolocator.dart' as g;
import 'package:quber_taxi/util/turf.dart';
import 'package:turf/turf.dart' as turf;

class LocationPicker extends StatefulWidget {

  const LocationPicker({super.key});

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {

  MapboxMap? _mapController;
  final _mapboxService = MapboxService();
  late turf.Polygon _havanaPolygon;

  @override
  void initState() {
    super.initState();
    _loadHavanaGeoJson();
  }

  Future<void> _loadHavanaGeoJson() async {
    _havanaPolygon = await loadGeoJsonPolygon("assets/geojson/polygon/CiudadDeLaHabana.geojson");
  }

  @override
  Widget build(BuildContext context) {
    final cameraOptions = CameraOptions(
      center: Point(coordinates: Position(-82.3598, 23.1380)),
      pitch: 45,
      bearing: 0,
      zoom: 17,
    );
    return Stack(
        children: [
          MapWidget(
            styleUri: MapboxStyles.STANDARD,
            cameraOptions: cameraOptions,
            onMapCreated: (controller) {
              // Update some mapbox component
              controller.location.updateSettings(LocationComponentSettings(enabled: true));
              controller.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
              _mapController = controller;
            },
            onLongTapListener: (mapContext) async {
              final lng = mapContext.point.coordinates.lng;
              final lat = mapContext.point.coordinates.lat;
              final mapboxPlace = await _mapboxService.getMapboxPlace(
                  longitude: lng, latitude: lat
              );
              // Check if inside of Havana
              final isInside = isPointInPolygon(lng, lat, _havanaPolygon);
              if(!context.mounted) return;
              if(!isInside) {
                showToast(context: context, message: "Los destinos están limitados a La Habana");
                return;
              }
              Navigator.of(context).pop(mapboxPlace);
            },
          ),
          // Find my location
          Positioned(
              right: 20.0, bottom: 20.0,
              child: FloatingActionButton(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  onPressed: () async {
                    await requestLocationPermission(
                        context: context,
                        onPermissionGranted: () async {
                          final position = await g.Geolocator.getCurrentPosition();
                          // Check if inside of Havana
                          final isInside = isPointInPolygon(position.longitude, position.latitude, _havanaPolygon);
                          if(!context.mounted) return;
                          if(!isInside) {
                            showToast(
                                context: context,
                                message: "Su ubicacion actual esta fuera de los limites de La"" Habana"
                            );
                            return;
                          }
                          _mapController!.easeTo(
                              CameraOptions(center: Point(coordinates: Position(position.longitude, position.latitude))),
                              MapAnimationOptions(duration: 500)
                          );
                        },
                        onPermissionDenied: () => showToast(context: context, message: "Permiso de ubicación denegado"),
                        onPermissionDeniedForever: () =>
                            showToast(context: context, message: "Permiso de ubicación denegado permanentemente")
                    );
                  },
                  child: Icon(
                      Icons.my_location_outlined,
                      color: Theme.of(context).iconTheme.color,
                      size: Theme.of(context).iconTheme.size
                  )
              )
          )
        ]
    );
  }
}
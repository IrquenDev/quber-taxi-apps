import 'package:flutter/material.dart';
import 'package:flutter_fusion/flutter_fusion.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:quber_taxi/util/geolocator.dart';
import 'package:geolocator/geolocator.dart' as g;
import 'package:quber_taxi/util/turf.dart';
import 'package:turf/turf.dart' as turf;

class MapView extends StatefulWidget {

  const MapView({super.key, this.usingExtendedScaffold = false});

  final bool usingExtendedScaffold;

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {

  MapboxMap? _mapController;
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
          ),
          // Find my location
          Positioned(
              right: 20.0, bottom: widget.usingExtendedScaffold ? 100.0 : 20.0,
              child: FloatingActionButton(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
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
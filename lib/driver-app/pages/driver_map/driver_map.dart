import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fusion/flutter_fusion.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as g;
import 'package:quber_taxi/util/geolocator.dart';
import 'package:quber_taxi/driver-app/pages/driver_map/tripRequestBottomSheet.dart';

class DriverMap extends StatefulWidget {

  const DriverMap({super.key, this.position});

  final Position? position;

  @override
  State<DriverMap> createState() => _DriverMapState();
}

class _DriverMapState extends State<DriverMap> {

  // Default m3  BottomAppBar height. The length of the curved space under a centered FAB coincides with this value.
  final _bottomAppBarHeight = 80.0;
  late Position _position;
  MapboxMap? _mapController;

  @override
  void initState() {
    super.initState();
    _position =
        widget.position ?? Position(-82.3598, 23.1380); // National Capitol
  }

  @override
  Widget build(BuildContext context) {
    final cameraOptions = CameraOptions(
      center: Point(coordinates: _position),
      pitch: 45,
      bearing: 0,
      zoom: 17,
    );

    return StatusBarController(
      systemUiMode: SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
      builder: (_) =>
          Scaffold(
            extendBody: true,
            body: Stack(
                children: [
                  MapWidget(
                    styleUri: MapboxStyles.STANDARD,
                    cameraOptions: cameraOptions,
                    onMapCreated: (mapboxMap) {
                      // Update some mapbox component
                      mapboxMap.location.updateSettings(
                          LocationComponentSettings(enabled: true));
                      mapboxMap.scaleBar.updateSettings(
                          ScaleBarSettings(enabled: false));
                      _mapController = mapboxMap;
                    },
                  ),
                  // Find my location
                  Positioned(
                      right: 20.0, bottom: _bottomAppBarHeight + 20.0,
                      child: FloatingActionButton(
                          backgroundColor: Theme
                              .of(context)
                              .colorScheme
                              .primary,
                          onPressed: () async {
                            await requestLocationPermission(
                              context: context,
                              onPermissionGranted: () async {
                                final position = await g.Geolocator
                                    .getCurrentPosition();
                                _mapController!.easeTo(
                                    CameraOptions(center: Point(
                                        coordinates: Position(
                                            position.longitude,
                                            position.latitude))),
                                    MapAnimationOptions(duration: 500)
                                );
                              },
                              onPermissionDenied: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text(
                                      "Permiso de ubicación denegado")),
                                );
                              },
                              onPermissionDeniedForever: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text(
                                      "Permiso de ubicación denegado permanentemente")),
                                );
                              },
                            );
                          },
                          child: Icon(
                              Icons.my_location_outlined,
                              color: Theme
                                  .of(context)
                                  .iconTheme
                                  .color,
                              size: Theme
                                  .of(context)
                                  .iconTheme
                                  .size
                          ),
                      ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: const TripRequestBottomSheet(),
                    ),
                  ),
                ],
            ),
          ),
    );
  }
}

class WideYellowButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const WideYellowButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber.shade600,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            elevation: 4,
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
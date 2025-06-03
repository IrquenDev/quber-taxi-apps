import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as g;
import 'package:quber_taxi/util/geolocator.dart';
import 'package:quber_taxi/driver-app/pages/home/available_travels_sheet.dart';

class DriverHome extends StatefulWidget {
  const DriverHome({super.key, this.position});

  final Position? position;

  @override
  State<DriverHome> createState() => _DriverHomeState();
}

class _DriverHomeState extends State<DriverHome> {
  late Position _position;
  MapboxMap? _mapController;

  @override
  void initState() {
    super.initState();
    _position = widget.position ?? Position(-82.3598, 23.1380); // National Capitol
  }

  @override
  Widget build(BuildContext context) {
    final cameraOptions = CameraOptions(
      center: Point(coordinates: _position),
      pitch: 45,
      bearing: 0,
      zoom: 17,
    );

    return Material(
      child: Stack(
        children: [
          MapWidget(
            styleUri: MapboxStyles.STANDARD,
            cameraOptions: cameraOptions,
            onMapCreated: (mapboxMap) {
              // Update some mapbox component
              mapboxMap.location.updateSettings(LocationComponentSettings(enabled: true));
              mapboxMap.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
              _mapController = mapboxMap;
            },
          ),
          // Find my location
          Positioned(
            right: 20.0,
            bottom: 140.0,
            child: FloatingActionButton(
              backgroundColor: Theme.of(context).colorScheme.primary,
              onPressed: () async {
                await requestLocationPermission(
                  context: context,
                  onPermissionGranted: () async {
                    final position = await g.Geolocator.getCurrentPosition();
                    _mapController!.easeTo(
                        CameraOptions(center: Point(coordinates: Position(position.longitude, position.latitude))),
                        MapAnimationOptions(duration: 500));
                  },
                  onPermissionDenied: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Permiso de ubicación denegado")),
                    );
                  },
                  onPermissionDeniedForever: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Permiso de ubicación denegado permanentemente")),
                    );
                  }
                );
              },
              child: Icon(
                  Icons.my_location_outlined,
                  color: Theme.of(context).iconTheme.color,
                  size: Theme.of(context).iconTheme.size
              ),
            )
          ),
          Align(alignment: Alignment.bottomCenter, child: const AvailableTravelsSheet())
        ]
      )
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

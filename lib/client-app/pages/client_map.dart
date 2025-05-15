import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fusion/flutter_fusion.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as g;
import 'package:quber_taxi/util/geolocator.dart';

class ClientMap extends StatefulWidget {

  const ClientMap({super.key, this.position});

  final Position? position;

  @override
  State<ClientMap> createState() => _ClientMapState();
}

class _ClientMapState extends State<ClientMap> {

  // Default m3  BottomAppBar height. The length of the curved space under a centered FAB coincides with this value.
  final _bottomAppBarHeight = 80.0;
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

    return StatusBarController(
      systemUiMode: SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
      builder: (_) => Scaffold(
        extendBody: true,
        body: Stack(
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
                right: 20.0, bottom: _bottomAppBarHeight + 20.0,
                child: FloatingActionButton(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    onPressed: () async {
                      await requestLocationPermission(
                        context: context,
                        onPermissionGranted: () async {
                          final position = await g.Geolocator.getCurrentPosition();
                          _mapController!.easeTo(
                              CameraOptions(center: Point(coordinates: Position(position.longitude, position.latitude))),
                              MapAnimationOptions(duration: 500)
                          );
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
                        },
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
        ),
        floatingActionButton: FloatingActionButton(
          shape: CircleBorder(),
          backgroundColor: Theme.of(context).colorScheme.primary,
          onPressed: () => showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            ///TODO("Leo")
            /// - Build the modal bottom sheet ui from here.
            builder: (context) => const Center(child: Text("Your modal sheet here!!")),
          ),
          child: Icon(
              Icons.local_taxi,
              color: Theme.of(context).iconTheme.color,
              size: Theme.of(context).iconTheme.size
          )
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 12.0,
          color: Theme.of(context).colorScheme.primary,
          child: Row(
            spacing: _bottomAppBarHeight,
            children: [
              Flexible(flex: 1, child: Center(child: _BottomBarItem(icon: Icons.location_on, label: 'Mapa'))),
              Flexible(flex: 1, child: Center(child: _PointsDisplay())),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomBarItem extends StatelessWidget {

  final IconData icon;
  final String label;

  const _BottomBarItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon),
        Text(label)
      ]
    );
  }
}

class _PointsDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Text('56'),
        Text('Puntos Quber')
      ]
    );
  }
}
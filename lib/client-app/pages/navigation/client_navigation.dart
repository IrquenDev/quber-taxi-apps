import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as g;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:quber_taxi/client-app/pages/navigation/trip_info.dart';
import 'package:quber_taxi/util/geolocator.dart';
import 'package:turf/distance.dart' as td;
import 'package:turf/turf.dart' as turf;

class ClientNavigation extends StatefulWidget {

  const ClientNavigation({super.key});

  @override
  State<ClientNavigation> createState() => _ClientNavigationState();
}

class _ClientNavigationState extends State<ClientNavigation> {

  late final MapboxMap _mapController;
  final List _realTimeRoute = <g.Position>[];
  late final StreamSubscription<g.Position> _locationStream;
  num _distanceInKm = 0;

  void _startTrackingDistance() {
    _locationStream = g.Geolocator.getPositionStream(
        locationSettings: g.LocationSettings(distanceFilter: 5)
    ).listen(_onMove);
  }

  void _onMove(g.Position newPosition) {
    final last = _realTimeRoute.last;
    final point1 = turf.Point(coordinates: turf.Position(last.longitude, last.latitude));
    final point2 = turf.Point(coordinates: turf.Position(newPosition.longitude, newPosition.latitude));
    final segmentDistance = td.distance(point1, point2, Unit.kilometers);
    _realTimeRoute.add(newPosition);
    setState(() => _distanceInKm += segmentDistance);
  }

  @override
  void dispose() {
    _locationStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // Init camera options
    final cameraOptions = CameraOptions(
      center: Point(coordinates: Position(-82.3598, 23.1380)),
      pitch: 45,
      bearing: 0,
      zoom: 17,
    );

    return Scaffold(
      body: Stack(
          children: [
            // Map
            MapWidget(
                styleUri: MapboxStyles.STANDARD,
                cameraOptions: cameraOptions,
                onMapCreated: (controller) {
                  // Update some mapbox component
                  controller.location.updateSettings(LocationComponentSettings(enabled: true));
                  controller.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
                  _mapController = controller;
                }
            ),
            // Custom mini "sheet"
            Align(alignment: Alignment.bottomCenter, child: TripInfoBottomOverlay(distance: _distanceInKm))
          ]
      ),
      // @Temporal
      // Just for testing
      floatingActionButton: FloatingActionButton(
        /// TODO("yapmDev")
        /// - Reminder: Move this logic to initState()
          onPressed: () async {
            await requestLocationPermission(
                context: context,
                onPermissionGranted: () async{
                  final originCoords = await g.Geolocator.getCurrentPosition();
                  _mapController.easeTo(
                      CameraOptions(center: Point(coordinates: Position(originCoords.longitude, originCoords.latitude))),
                      MapAnimationOptions(duration: 500)
                  );
                  _realTimeRoute.add(originCoords);
                  _startTrackingDistance();
                }
            );
          },
          child: Icon(Icons.my_location_outlined)
      )
    );
  }
}
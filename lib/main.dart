import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as g; // both mapbox and geolocator share the class name Position.
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:quber_taxi/common/pages/map.dart';
import 'package:quber_taxi/theme/theme.dart';
import 'package:quber_taxi/util/geolocator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  String accessToken = const String.fromEnvironment("MAPBOX_ACCESS_TOKEN");
  MapboxOptions.setAccessToken(accessToken);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await requestLocationPermission(
              context: context,
              onPermissionGranted: () async {
                final position = await g.Geolocator.getCurrentPosition();
                if (!context.mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>
                      MapPage(
                        position: Position(position.longitude, position.latitude),
                        widgetLayerBuilder: (mapController) {
                          if(mapController == null) return null;
                          return <Positioned>[
                            Positioned(
                                right: 20, bottom: 20,
                                child: FloatingActionButton(
                                    onPressed: () {
                                      mapController.easeTo(CameraOptions(center: Point(coordinates: Position(
                                          position.longitude, position.latitude))),
                                          MapAnimationOptions(duration: 500)
                                      );
                                    },
                                child: Icon(Icons.not_listed_location_outlined),
                                )
                            )
                          ];
                        },
                      )
                  )
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
          child: const Text("Open Map"),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:quber_taxi/common/pages/map.dart';
import 'package:quber_taxi/theme/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  const String accessToken = String.fromEnvironment("MAPBOX_ACCESS_TOKEN");
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
        home: const MapPage()
    );
  }
}
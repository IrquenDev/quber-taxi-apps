import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:quber_taxi/client-app/pages/client_map.dart';
import 'package:quber_taxi/theme/theme.dart';

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
      home: const ClientMap(),
    );
  }
}
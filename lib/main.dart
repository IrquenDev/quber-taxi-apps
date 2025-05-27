import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:quber_taxi/client-app/pages/home/home.dart';
import 'package:quber_taxi/config/api_config.dart';
import 'package:quber_taxi/config/build_config.dart';
import 'package:quber_taxi/driver-app/pages/home/home.dart';
import 'package:quber_taxi/theme/theme.dart';
import 'package:quber_taxi/util/runtime.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  BuildConfig.loadConfig();
  MapboxOptions.setAccessToken(ApiConfig().mapboxAccessToken);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home:  isClientMode ? const ClientHome() : DriverHome(),
    );
  }
}
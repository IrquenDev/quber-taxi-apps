import 'dart:async';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:quber_taxi/config/api_config.dart';
import 'package:quber_taxi/config/build_config.dart';
import 'package:quber_taxi/storage/prefs_manager.dart';
import 'package:quber_taxi/utils/map/turf.dart';
import 'package:quber_taxi/utils/websocket/core/websocket_service.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'app.dart';

Future<void> main() async {
  // Wait for the flutter framework's bindings been initialized
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  // Lock screen orientation to portrait mode
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // Load and dispatch build configuration
  await BuildConfig.loadConfig();
  // Setup shared preferences storage
  await SharedPrefsManager.init();
  // Load Havana polygon
  await GeoBoundaries.loadHavanaPolygon();
  // Configure mapbox api
  MapboxOptions.setAccessToken(ApiConfig().mapboxAccessToken);
  // Setup websocket
  WebSocketService.instance.connect(baseUrl: ApiConfig().baseUrl);
  // Request location permission
  await Geolocator.requestPermission();
  // Remove splash
  FlutterNativeSplash.remove();
  //The project id for the dns is 12236, but as you can see I removed the number 6 so we can have it deactivated.
  //The problem here is that the free plan allows only 1000 errors capture, and we are over 200 without client usage, just in develop
  SentryFlutter.init(
        (options) => options
      ..dsn = 'https://5fc6d3f519f940929ab3d6b863651d30@app.glitchtip.com/12236'
      ..tracesSampleRate = 0.00 // Performance trace 1% of events
      ..enableAutoSessionTracking = false,
    appRunner: () => runApp(
      //Device Preview allows us to have a cool preview mode to test the responsiveness of all the screens
      DevicePreview(
        enabled: !kReleaseMode && false, //change this to false if you don't want to see the preview mode
        builder: (context) => App(),
      ),
    ),
  );
}

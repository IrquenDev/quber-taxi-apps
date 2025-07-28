import 'dart:async';
import 'package:flutter/material.dart';
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

  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  //Initialization Block
  BuildConfig.loadConfig();
  await SharedPrefsManager.init();
  await GeoBoundaries.loadHavanaPolygon();
  MapboxOptions.setAccessToken(ApiConfig().mapboxAccessToken);
  WebSocketService.instance.connect(baseUrl: ApiConfig().baseUrl);
  await Geolocator.requestPermission();
  FlutterNativeSplash.remove();


  SentryFlutter.init(
          (options) => options
        ..dsn='https://5fc6d3f519f940929ab3d6b863651d30@app.glitchtip.com/12236'
        ..tracesSampleRate=0.00 // Performance trace 1% of events
        ..enableAutoSessionTracking=false,
      appRunner: () => runApp(App())
  );
}
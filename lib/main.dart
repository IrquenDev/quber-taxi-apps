import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'app.dart';
import 'flavors.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:quber_taxi/config/api_config.dart';
import 'package:quber_taxi/config/build_config.dart';
import 'package:quber_taxi/storage/prefs_manager.dart';
import 'package:quber_taxi/utils/websocket/core/websocket_service.dart';

import 'app.dart';

Future<void> main() async {

  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  //Initialization Block
  BuildConfig.loadConfig();
  await SharedPrefsManager.init();
  MapboxOptions.setAccessToken(ApiConfig().mapboxAccessToken);
  WebSocketService.instance.connect(baseUrl: ApiConfig().baseUrl);
  await Geolocator.requestPermission();

  FlutterNativeSplash.remove();

  F.appFlavor = Flavor.values.firstWhere(
        (element) => element.name == appFlavor,
  );

  runApp(const App());
}
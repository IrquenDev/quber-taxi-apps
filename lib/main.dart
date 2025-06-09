import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:quber_taxi/client-app/pages/home/home.dart';
import 'package:quber_taxi/client-app/pages/navigation/client_navigation.dart';
import 'package:quber_taxi/config/api_config.dart';
import 'package:quber_taxi/config/build_config.dart';
import 'package:quber_taxi/theme/theme.dart';
import 'package:quber_taxi/driver-app/pages/home/home.dart';
import 'package:quber_taxi/util/runtime.dart';
import 'package:quber_taxi/websocket/core/websocket_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  BuildConfig.loadConfig();
  MapboxOptions.setAccessToken(ApiConfig().mapboxAccessToken);
  WebSocketService.instance.connect(baseUrl: ApiConfig().baseUrl);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieves the default theme for the platform.
    TextTheme textTheme = Theme.of(context).textTheme;
    // Use google_fonts package to use a downloadable font, based on the default platform's theme.
    // TextTheme textTheme = createTextTheme(context, "Roboto", "Roboto");
    MaterialTheme theme = MaterialTheme(textTheme);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme.light(),
      darkTheme: theme.dark(),
      // home: isClientMode ? const ClientHome() : DriverHome()
      home: ClientNavigation(),
    );
  }
}
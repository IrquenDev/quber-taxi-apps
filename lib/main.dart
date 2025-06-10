import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:network_checker/network_checker.dart';
import 'package:quber_taxi/config/api_config.dart';
import 'package:quber_taxi/config/build_config.dart';
import 'package:quber_taxi/routes/app_router.dart';
import 'package:quber_taxi/theme/theme.dart';
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
    return MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: theme.light(),
        darkTheme: theme.dark(),
        routerConfig: appRouter,
        builder: (context, child) => NetworkChecker(
            config: ConnectionConfig(
                pingUrl: '${ApiConfig().baseUrl}/network-checker',
                timeLimit: Duration(seconds: 3)
            ),
            // Delegate to child whether to use a network alert and decide it style and position. To do that, wrap
            // the child in a NetworkAlertTemplate.
            alertBuilder: null, // anyway it's null by default, it's just for you knowledge.
            child: child!
        )
      // home: ClientNavigation(),
    );
  }
}
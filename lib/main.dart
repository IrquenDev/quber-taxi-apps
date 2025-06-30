import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:network_checker/network_checker.dart';
import 'package:quber_taxi/config/api_config.dart';
import 'package:quber_taxi/config/build_config.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';
import 'package:quber_taxi/navigation/app_router.dart';
import 'package:quber_taxi/storage/prefs_manager.dart';
import 'package:quber_taxi/theme/theme.dart';
import 'package:quber_taxi/websocket/core/websocket_service.dart';

void main() async {

  // Tells the framework to wait to ensure WidgetBinding initialization before calling runApp().
  WidgetsFlutterBinding.ensureInitialized();

  // Loads and dispatches any configuration related with the running args.
  BuildConfig.loadConfig();

  // Prepares shared preferences I/O.
  await SharedPrefsManager.init();

  // Configures mapbox access token, need it for any request on Geocoding or Directions APIs.
  MapboxOptions.setAccessToken(ApiConfig().mapboxAccessToken);

  // Try opening a websocket connection. Although it's not a Future, this operation is asynchronous (it takes time,
  // so in our case we keep it  open from here and then subscribe to the different topics).
  WebSocketService.instance.connect(baseUrl: ApiConfig().baseUrl);

  // TODO("yapmDev": @Reminder)
  // - Probably will be needed it, when the app have to redirect to continue to the current navigation status
  // (depending on the trips_list status (if applicable)).
  //
  // Request user location permission to avoid exception during development.
  await Geolocator.requestPermission();

  // Start rendering our app.
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
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
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
            // Anyway it's null by default, it's just for you knowledge.
            alertBuilder: null,
            child: child!
        )
    );
  }
}
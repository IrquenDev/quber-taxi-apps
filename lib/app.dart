import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:network_checker/network_checker.dart';
import 'package:quber_taxi/storage/prefs_manager.dart';
import 'package:quber_taxi/theme/theme.dart';
import 'package:quber_taxi/utils/websocket/core/websocket_service.dart';

import 'config/api_config.dart';
import 'config/build_config.dart';
import 'l10n/app_localizations.dart';
import 'navigation/app_router.dart';

class App extends StatelessWidget {
  const App({super.key});


  @override
  Widget build(BuildContext context) {
    // Retrieves the default theme for the platform.
    TextTheme textTheme = Theme
        .of(context)
        .textTheme;
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
      builder: (context, child) =>
          NetworkChecker(
            config: ConnectionConfig(
              pingUrl: '${ApiConfig().baseUrl}/network-checker',
              timeLimit: const Duration(seconds: 3),
            ),
            alertBuilder: null,
            child: child!,
          ),
    );
  }
}

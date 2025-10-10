import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:quber_taxi/config/api_config.dart';
import 'package:quber_taxi/config/app_profile.dart';

/// This class is responsible for loading and managing the application's build configurations,
/// based on compiling args and asset files.
class BuildConfig {
  static late AppProfile appProfile;
  /// Loads and resolves build configurations.
  static void loadConfig() {
    appProfile = AppProfile.resolve();
    // Try to get from .env first, fallback to --dart-define if not found
    String definedBaseUrl = dotenv.env['BASE_URL'] ??
        const String.fromEnvironment(
            "BASE_URL",
            defaultValue: "http://qnecesitas.nat.cu/qubertaxiapi"
        );
    String definedMapboxAccessToken = dotenv.env['MAPBOX_ACCESS_TOKEN'] ??
        const String.fromEnvironment("MAPBOX_ACCESS_TOKEN", defaultValue: "");
    ApiConfig.populate(definedBaseUrl, definedMapboxAccessToken);
  }
}

/// Loads the configuration file from the assets folder.
///
/// Reads the JSON configuration file specified by [configFile]
/// and returns its contents as a string.
Future<String> loadConfigFromAssets(String configFile) async =>
    await rootBundle.loadString('assets/config_files/$configFile');
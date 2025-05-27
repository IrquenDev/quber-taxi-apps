import 'package:flutter/services.dart';
import 'package:quber_taxi/config/api_config.dart';
import 'package:quber_taxi/config/app_profile.dart';

/// This class is responsible for loading and managing the application's build configurations,
/// based on compiling args and asset files.
class BuildConfig {

  static late AppProfile appProfile;

  /// Loads and resolves build configurations.
  static void loadConfig() {
    String definedAppProfile = const String.fromEnvironment("APP_PROFILE", defaultValue: "CLIENT");
    appProfile = AppProfile.resolve(definedAppProfile);
    String definedBaseUrl = const String.fromEnvironment("BASE_URL", defaultValue: "https://qnecesitas.nat.cu");
    String definedMapboxAccessToken = const String.fromEnvironment("MAPBOX_ACCESS_TOKEN");
    ApiConfig.populate(definedBaseUrl, definedMapboxAccessToken);
  }
}

/// Loads the configuration file from the assets folder.
///
/// Reads the JSON configuration file specified by [configFile]
/// and returns its contents as a string.
Future<String> loadConfigFromAssets(String configFile) async =>
    await rootBundle.loadString('assets/config_files/$configFile');
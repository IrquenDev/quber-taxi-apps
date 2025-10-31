import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:quber_taxi/config/api_config.dart';
import 'package:quber_taxi/config/app_profile.dart';

/// This class is responsible for loading and managing the application's build configurations,
/// based on .env files.
class BuildConfig {
  static late AppProfile appProfile;

  /// Loads and resolves build configurations.
  /// First loads the main .env file from env/ directory to read the targetEnvironment,
  /// then loads the corresponding environment file (e.g., .env.dev, .env.prod).
  static Future<void> loadConfig() async {
    appProfile = AppProfile.resolve();
    // Load main .env file to get target environment
    await dotenv.load(fileName: "env/.env");
    final targetEnvironment = dotenv.env['targetEnvironment'];
    if (targetEnvironment == null || targetEnvironment.isEmpty) {
      throw StateError("Missing 'targetEnvironment' in env/.env file");
    }
    // Load the actual environment configuration file
    final envFileName = "env/.env.$targetEnvironment";
    await dotenv.load(fileName: envFileName, mergeWith: dotenv.env);
    final definedBaseUrl = dotenv.env['BASE_URL'];
    final definedMapboxAccessToken = dotenv.env['MAPBOX_ACCESS_TOKEN'];
    if (definedBaseUrl == null || definedMapboxAccessToken == null) {
      throw StateError("Missing environment parameters in $envFileName");
    }
    ApiConfig.populate(definedBaseUrl, definedMapboxAccessToken);
  }
}
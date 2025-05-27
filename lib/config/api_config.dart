import 'package:flutter/foundation.dart';

/// Singleton class that holds essential API credentials and baseUrl required for making network requests from any
/// service.
@immutable
class ApiConfig {

  static ApiConfig? _instance;

  /// The resolved baseUrl.
  final String baseUrl;

  /// The mapbox API access token.
  final String mapboxAccessToken;

  /// Access to the class instance. Needs a previous call on [populate].
  factory ApiConfig () {
    assert (_instance != null, "Try initializing first using the populate method.");
    return _instance!;
  }

  const ApiConfig._internal(this.baseUrl, this.mapboxAccessToken);

  /// Initialize the class from here, populating it with the necessary fields.
  static void populate(String baseUrl, String mapboxAccessToken) =>
      _instance ??= ApiConfig._internal(baseUrl, mapboxAccessToken);
}
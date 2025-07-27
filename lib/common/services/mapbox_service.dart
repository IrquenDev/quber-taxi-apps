import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:quber_taxi/common/models/mapbox_place.dart';
import 'package:quber_taxi/common/models/mapbox_route.dart';
import 'package:quber_taxi/config/api_config.dart';
import 'package:quber_taxi/enums/mapbox_place_type.dart';

/// A service for interacting with the Mapbox Directions and Geocoding APIs.
///
/// Provides methods for route generation, reverse geocoding,
/// autocomplete suggestions, and forward geocoding.
///
/// All responses are parsed into strongly typed models: [MapboxRoute] and [MapboxPlace].
@immutable
class MapboxService {
  /// API config to access the Mapbox access token and base URL.
  final _apiConfig = ApiConfig();

  /// Base URL for Mapbox Directions API (used to generate routes).
  final String _directionsApiBaseUrl = 'https://api.mapbox.com/directions/v5/mapbox/driving';

  /// Base URL for Mapbox Geocoding API (used to get or search places).
  final String _geocodingApiBaseUrl = 'https://api.mapbox.com/geocoding/v5/mapbox.places';

  /// Generates a driving route between the given origin and destination coordinates.
  ///
  /// Returns a [MapboxRoute] containing route geometry and metadata.
  ///
  /// Example:
  /// ```dart
  /// final route = await mapboxService.getRoute(
  ///   originLng: -82.358,
  ///   originLat: 23.124,
  ///   destinationLng: -82.360,
  ///   destinationLat: 23.130,
  /// );
  /// ```
  Future<MapboxRoute> getRoute({
    required num originLng,
    required num originLat,
    required num destinationLng,
    required num destinationLat,
  }) async {
    final url = '$_directionsApiBaseUrl/$originLng,$originLat;$destinationLng,$destinationLat'
        '?geometries=geojson'
        '&overview=full'
        '&access_token=${_apiConfig.mapboxAccessToken}';
    final response = await http.get(Uri.parse(url));
    return MapboxRoute.fromJson(jsonDecode(response.body));
  }

  /// Retrieves a [MapboxPlace] by performing a forward geocoding search.
  ///
  /// The [query] is combined with a default city context ("La Habana"),
  /// and optionally uses proximity coordinates to influence ranking.
  ///
  /// Returns `null` if no results are found.
  Future<MapboxPlace?> getLocationCoords({
    required String query,
    required List<MapboxPlaceType> types,
    List<num>? proximity,
  }) async {
    final encodedQuery = Uri.encodeComponent('$query, La Habana');
    const bbox = '-82.586995,22.934228,-82.081898,23.26079';
    final url = '$_geocodingApiBaseUrl/$encodedQuery.json'
        '?access_token=${_apiConfig.mapboxAccessToken}'
        '&country=cu'
        '&language=es'
        '&types=${types.map((type) => type.value).join(',')}'
        '${proximity != null ? '&proximity=${proximity[0]},${proximity[1]}' : ''}'
        '&bbox=$bbox'
        '&limit=1';
    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);
    final features = data['features'] as List<dynamic>;
    if (features.isEmpty) return null;
    return MapboxPlace.fromJson(features.first);
  }

  /// Gets the municipality name (as a [MapboxPlace]) for the given coordinates.
  ///
  /// Performs reverse geocoding and filters for features of type "locality".
  ///
  /// Returns `null` if no locality-level result is found.
  Future<MapboxPlace?> getMunicipalityName({
    required num longitude,
    required num latitude,
  }) async {
    final url = '$_geocodingApiBaseUrl/$longitude,$latitude.json'
        '?access_token=${_apiConfig.mapboxAccessToken}'
        '&language=es';
    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);
    final features = data['features'] as List<dynamic>;
    final localityFeature = features.firstWhere(
          (f) => f['place_type'] != null &&
          List.from(f['place_type']).contains('locality'),
      orElse: () => null,
    );
    if (localityFeature == null) return null;
    return MapboxPlace.fromJson(localityFeature);
  }

  /// Performs a basic reverse geocoding query for a [MapboxPlace]
  /// using latitude and longitude.
  ///
  /// Returns the first result from the API response.
  Future<MapboxPlace?> getMapboxPlace({
    required num longitude,
    required num latitude,
  }) async {
    final url = '$_geocodingApiBaseUrl/$longitude,$latitude.json'
        '?access_token=${_apiConfig.mapboxAccessToken}';
    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);
    final features = data['features'] as List<dynamic>;
    return MapboxPlace.fromJson(features.first);
  }

  /// Fetches a list of address/place suggestions from the Mapbox Geocoding API.
  ///
  /// Used for autocomplete functionality. The search is limited to Havana and
  /// biased toward Havana with a bounding box and proximity to central Havana.
  ///
  /// Returns a list of [MapboxPlace] suggestions.
  Future<List<MapboxPlace>> fetchSuggestions(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    const bbox = '-82.538978,22.932974,-82.074825,23.18125';
    const proximityLon = -82.3666;
    const proximityLat = 23.1136;
    final url = '$_geocodingApiBaseUrl/$encodedQuery.json'
        '?access_token=${_apiConfig.mapboxAccessToken}'
        '&autocomplete=true'
        '&proximity=$proximityLon,$proximityLat'
        '&bbox=$bbox'
        '&language=es'
        '&country=cu'
        '&limit=20';
    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);
    final features = data['features'] as List<dynamic>;
    return features.map((json) => MapboxPlace.fromJson(json)).toList();
  }
}
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:quber_taxi/common/models/mapbox_place.dart';
import 'package:quber_taxi/common/models/mapbox_route.dart';
import 'package:quber_taxi/config/api_config.dart';
import 'package:quber_taxi/enums/mapbox_place_type.dart';

@immutable
class MapboxService {

  final _apiConfig = ApiConfig();
  final String _directionsApiBaseUrl = 'https://api.mapbox.com/directions/v5/mapbox/driving';
  final String _geocodingApiBaseUrl = 'https://api.mapbox.com/geocoding/v5/mapbox.places';

  Future<MapboxRoute> getRoute({
    required num originLng,
    required num originLat,
    required num destinationLng,
    required num destinationLat
  }) async {
    final url = '$_directionsApiBaseUrl/$originLng,$originLat;$destinationLng,$destinationLat'
        '?geometries=geojson'
        '&overview=full'
        '&access_token=${_apiConfig.mapboxAccessToken}';
    final response = await http.get(Uri.parse(url));
    return MapboxRoute.fromJson(jsonDecode(response.body));
  }


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

  Future<MapboxPlace?> getMunicipalityName({required num longitude, required num latitude}) async {
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
    if (localityFeature == null) {
      return null;
    }
    return MapboxPlace.fromJson(localityFeature);
  }

  Future<MapboxPlace?> getMapboxPlace({required num longitude, required num latitude}) async {
    final url = '$_geocodingApiBaseUrl/$longitude,$latitude.json'
        '?access_token=${_apiConfig.mapboxAccessToken}';
    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);
    final features = data['features'] as List<dynamic>;
    return MapboxPlace.fromJson(features.first);
  }

  Future<List<MapboxPlace>> fetchSuggestions(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    const bbox = '-82.586995,22.934228,-82.081898,23.26079';
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
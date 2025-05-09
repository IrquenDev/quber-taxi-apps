import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:quber_taxi/common/models/mapbox_place.dart';
import 'package:quber_taxi/common/models/mapbox_route.dart';
import 'package:quber_taxi/enums/mapbox_place_type.dart';

@immutable
class MapboxService {

  const MapboxService();

  final String _baseUrl = 'https://api.mapbox.com/directions/v5/mapbox';
  final String _profile = 'driving'; // walking, cycling, etc.
  final String _accessToken = const String.fromEnvironment('MAPBOX_ACCESS_TOKEN');

  Future<MapboxRoute> getRoute({
    required num originLat,
    required num originLng,
    required num destinationLat,
    required num destinationLng,
  }) async {
    final url = '$_baseUrl/$_profile/$originLng,$originLat;$destinationLng,'
        '$destinationLat?geometries=geojson&overview=full&access_token=$_accessToken';
    final response = await http.get(Uri.parse(url));
    return MapboxRoute.fromJson(jsonDecode(response.body));
  }

  Future<MapboxPlace?> searchLocationCoords({
    required String query,
    required List<MapboxPlaceType> types,
    Position? proximity,
  }) async {
    final encodedQuery = Uri.encodeComponent(query);
    final url = 'https://api.mapbox.com/geocoding/v5/mapbox.places/$encodedQuery.json'
        '?access_token=$_accessToken'
        '&types=${types.map((type) => type.value).join(',')}'
        '${proximity != null ? '&proximity=${proximity.lng},${proximity.lat}' : ''}'
        '&limit=1';
    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);
    final features = data['features'] as List<dynamic>;
    if (features.isEmpty) return null;
    return MapboxPlace.fromJson(features.first);
  }

  Future<MapboxPlace> searchLocationName({
    required num longitude,
    required num latitude,
    required List<MapboxPlaceType> types,
  }) async {
    final url = 'https://api.mapbox.com/geocoding/v5/mapbox.places/$longitude,$latitude.json'
        '?access_token=$_accessToken'
        '&types=${types.map((type) => type.value).join(',')}'
        '&limit=1';
    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);
    final features = data['features'] as List<dynamic>;
    return MapboxPlace.fromJson(features.first);
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quber_taxi/common/models/mapbox_route.dart';

class MapboxService {

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
}
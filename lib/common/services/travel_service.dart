import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quber_taxi/common/models/travel.dart';
import 'package:quber_taxi/config/api_config.dart';
import 'package:quber_taxi/enums/taxi_type.dart';

class TravelService {

  final _apiConfig = ApiConfig();
  final _endpoint = "travels";

  Future<Travel> requestNewTravel({
    required int clientId,
    required String originName,
    required String destinationName,
    required List<num> originCoords,
    required int requiredSeats,
    required bool hasPets,
    required TaxiType taxiType,
    required num minDistance,
    required num maxDistance,
    required num minPrice,
    required num maxPrice
  }) async {
    final url = Uri.parse("${_apiConfig.baseUrl}/$_endpoint/$clientId");
    final headers = {'Content-Type': 'application/json'};
    final response = await http.post(
      url,
      headers: headers,
        body: jsonEncode({
          "originName": originName,
          "destinationName": destinationName,
          "originCoords": originCoords,
          "requiredSeats": requiredSeats,
          "hasPets": hasPets,
          "taxiType": taxiType.apiValue,
          "minDistance": minDistance,
          "maxDistance": maxDistance,
          "minPrice": minPrice,
          "maxPrice": maxPrice
        })
    );
    return Travel.fromJson(jsonDecode(response.body));
  }

  Future<List<Travel>> findAvailableTravels(int seats, TaxiType type) async {
    final url = Uri.parse('${_apiConfig.baseUrl}/$_endpoint?seats=$seats&type=${type.apiValue}');
    final response = await http.get(url);
    if (response.body.trim().isEmpty) {
      return [];
    }
    final List<dynamic> jsonList = jsonDecode(response.body);
    return jsonList.map((json) => Travel.fromJson(json)).toList();
  }

  Future<http.Response> assignTravelToDriver({
    required int travelId,
    required int driverId,
  }) async {
    final url = Uri.parse("${_apiConfig.baseUrl}/$_endpoint/$travelId/assignTo?driverId=$driverId");
    final headers = {'Content-Type': 'application/json'};
    return await http.patch(url, headers: headers);
  }
}
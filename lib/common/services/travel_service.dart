import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quber_taxi/common/models/travel.dart';
import 'package:quber_taxi/config/api_config.dart';
import 'package:quber_taxi/enums/taxi_type.dart';

class TravelService {

  final _apiConfig = ApiConfig();
  final _endpoint = "travels";

  Future<Travel> requestNewTravel({
    int clientId = 1, // just for testing, (obviously required a registered client with this specific id)
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
}
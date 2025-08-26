import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quber_taxi/common/models/quber_config.dart';
import 'package:quber_taxi/config/api_config.dart';
import 'package:quber_taxi/enums/taxi_type.dart';

class AdminService {

  final _apiConfig = ApiConfig();
  final _endpoint = "admin";

  Future<http.Response> updateConfig({
    required double driverCredit, 
    required Map<TaxiType, double> vehiclePrices,
    required String operatorPhone,
  }) async {
    final url = Uri.parse("${_apiConfig.baseUrl}/$_endpoint");
    final headers = {'Content-Type': 'application/json'};
    final vehiclePricesJson = vehiclePrices.map((key, value) => MapEntry(key.apiValue, value));
    return await http.post(url, headers: headers, body: jsonEncode({
      "driverCredit": driverCredit,
      "travelPrice": vehiclePricesJson,
      "operatorPhone": operatorPhone
    }));
  }

  Future<QuberConfig?> getQuberConfig() async {
    final url = Uri.parse('${_apiConfig.baseUrl}/$_endpoint');
    final response = await http.get(url);
    if(response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return QuberConfig.fromJson(json);
    }
    return null;
  }

  Future<http.Response> updatePassword(int adminId, String newPassword) {
    final url = Uri.parse("${_apiConfig.baseUrl}/$_endpoint/$adminId?newPassword=$newPassword");
    final headers = {'Content-Type': 'application/json'};
    return http.patch(url, headers: headers);
  }

  Future<http.Response> requestNewTravel({
    required String clientPhone,
    required String originName,
    required String destinationName,
    required List<num> originCoords,
    List<num>? destinationCoords,
    required int requiredSeats,
    required bool hasPets,
    required TaxiType taxiType,
    required double? fixedDistance,
    required double? minDistance,
    required double? maxDistance,
    required double? fixedPrice,
    required double? minPrice,
    required double? maxPrice,
  }) async {
    final url = Uri.parse("${_apiConfig
        .baseUrl}/$_endpoint/create-travel-request-offline/$clientPhone");
    final headers = {'Content-Type': 'application/json'};
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        "originName": originName,
        "destinationName": destinationName,
        "originCoords": originCoords,
        "destinationCoords": destinationCoords,
        "requiredSeats": requiredSeats,
        "hasPets": hasPets,
        "taxiType": taxiType.apiValue,
        "fixedDistance": fixedDistance,
        "minDistance": minDistance,
        "maxDistance": maxDistance,
        "fixedPrice": fixedPrice,
        "minPrice": minPrice,
        "maxPrice": maxPrice,
      }),
    );
    return response;
  }
}
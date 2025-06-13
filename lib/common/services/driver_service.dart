import 'package:http/http.dart' as http;
import 'package:quber_taxi/config/api_config.dart';

class DriverService {

  final _apiConfig = ApiConfig();
  final _endpoint = "drivers";

  Future<http.Response> acceptTravel({required int driverId, required int travelId}) async {
    final url = Uri.parse("${_apiConfig.baseUrl}/$_endpoint/$driverId?travelId=$travelId");
    final headers = {'Content-Type': 'application/json'};
    return await http.patch(url, headers: headers);
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quber_taxi/config/api_config.dart';
import 'package:quber_taxi/common/models/driver.dart';

class AccountService {

  final _apiConfig = ApiConfig();
  final _endpoint = "account";

  Future<http.Response> acceptTravel({required int driverId, required int travelId}) async {
    final url = Uri.parse("${_apiConfig.baseUrl}/$_endpoint/$driverId?travelId=$travelId");
    final headers = {'Content-Type': 'application/json'};
    return await http.patch(url, headers: headers);
  }

  Future<Driver> getDriverById(int id) async {
    final url = Uri.parse("${_apiConfig.baseUrl}/$_endpoint/driver/$id");
    final headers = {'Content-Type': 'application/json'};
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Driver.fromJson(json);
    } else {
      throw DriverNotFoundException('Driver with id $id not found. Status code: ${response.statusCode}');
    }
  }

}


class DriverNotFoundException implements Exception {
  final String message;
  DriverNotFoundException([this.message = 'Driver not found']);

  @override
  String toString() => 'DriverNotFoundException: $message';
}

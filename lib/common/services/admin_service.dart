import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quber_taxi/common/models/quber_config.dart';
import 'package:quber_taxi/config/api_config.dart';

class AdminService {

  final _apiConfig = ApiConfig();
  final _endpoint = "admin";

  Future<http.Response> updateConfig({required double travelPrice, required double driverCredit}) async {
    final url = Uri.parse("${_apiConfig.baseUrl}/$_endpoint");
    final headers = {'Content-Type': 'application/json'};
    return await http.post(url, headers: headers, body: jsonEncode({
      "travelPrice": travelPrice,
      "driverCredit": driverCredit
    }));
  }

  Future<QuberConfig?> getQuberConfigIfExists() async {
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
}
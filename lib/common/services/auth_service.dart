import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quber_taxi/common/models/client.dart';
import 'package:quber_taxi/common/models/driver.dart';
import 'package:quber_taxi/config/api_config.dart';
import 'package:quber_taxi/storage/session_manger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {

  final _endpoint = "${ApiConfig().baseUrl}/auth";
  final headers = {'Content-Type': 'application/json'};

  Future<bool> isSessionActive() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('sessionId');
    if (sessionId == null) return false;
    final url = Uri.parse("$_endpoint/session-status");
    final response = await http.post(url, headers: {'Cookie': 'JSESSIONID=$sessionId'});
    return response.statusCode == 200;
  }

  Future<http.Response> loginClient(String phone, String password) async {
    final url = Uri.parse("$_endpoint/login/client?phone=$phone&password=$password");
    final response = await http.post(url);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final client = Client.fromJson(json);
      SessionManager.instance.save(client);
    }
    return response;
  }

  Future<http.Response> loginDriver(String phone, String password) async {
    final url = Uri.parse("$_endpoint/login/driver?phone=$phone&password=$password");
    final response = await http.post(url);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final driver = Driver.fromJson(json);
      SessionManager.instance.save(driver);
    }
    return response;
  }

  Future<http.Response> logout() async {
    final url = Uri.parse("$_endpoint/logout");
    return await http.post(url);
  }

  Future<http.Response> requestPasswordReset(String phone) async {
    final url = Uri.parse("$_endpoint/password-reset/request?phone=$phone");
    return await http.post(url);
  }

  Future<http.Response> resetClientPassword({
    required String phone,
    required String code,
    required String newPassword,
  }) async {
    final url = Uri.parse("$_endpoint/password-reset/reset-client");
    final body = jsonEncode({
      "phone": phone,
      "code": code,
      "newPassword": newPassword,
    });
    return await http.post(url, headers: headers, body: body);
  }

  Future<http.Response> resetDriverPassword({
    required String phone,
    required String code,
    required String newPassword,
  }) async {
    final url = Uri.parse("$_endpoint/password-reset/reset-driver");
    final body = jsonEncode({
      "phone": phone,
      "code": code,
      "newPassword": newPassword,
    });
    return await http.post(url, headers: headers, body: body);
  }
}
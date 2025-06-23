import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quber_taxi/common/models/client.dart';
import 'package:quber_taxi/common/models/driver.dart';
import 'package:quber_taxi/config/api_config.dart';

class AccountService {

  final _endpoint = "${ApiConfig().baseUrl}/account";
  final headers = {'Content-Type': 'application/json'};

  Future<http.Response> registerClient(Map<String, dynamic> clientData) async {
    final url = Uri.parse("$_endpoint/register/client");
    final body = jsonEncode(clientData);
    return await http.post(url, headers: headers, body: body);
  }

  Future<http.Response> registerDriver(Map<String, dynamic> driverData) async {
    final url = Uri.parse("$_endpoint/register/driver");
    final body = jsonEncode(driverData);
    return await http.post(url, headers: headers, body: body);
  }

  Future<http.Response> deleteClient(int id) async {
    final url = Uri.parse("$_endpoint/delete/client/$id");
    return await http.delete(url);
  }

  Future<http.Response> deleteDriver(int id) async {
    final url = Uri.parse("$_endpoint/delete/driver/$id");
    return await http.delete(url);
  }

  Future<Client> getClientById(int id) async {
    final url = Uri.parse("$_endpoint/client/$id");
    final response =  await http.get(url);
    final json = jsonDecode(response.body);
    return Client.fromJson(json);
  }

  Future<Driver> getDriverById(int id) async {
    final url = Uri.parse("$_endpoint/driver/$id");
    final response =  await http.get(url);
    final json = jsonDecode(response.body);
    return Driver.fromJson(json);
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:quber_taxi/common/models/client.dart';
import 'package:quber_taxi/common/models/driver.dart';
import 'package:quber_taxi/config/api_config.dart';
import 'package:quber_taxi/enums/taxi_type.dart';

class AccountService {

  final _endpoint = "${ApiConfig().baseUrl}/account";

  Future<http.Response> registerClient({
    required String name,
    required String phone,
    required String password,
    required XFile? image
  }) async {
    final url = Uri.parse("$_endpoint/register/client");
    final request = http.MultipartRequest("POST", url);
    request.fields['name'] = name;
    request.fields['phone'] = phone;
    request.fields['password'] = password;
    if(image != null) {
      String imagePath = image.path;
      final mimeType = lookupMimeType(imagePath);
      final contentType = mimeType != null ? MediaType.parse(mimeType) : MediaType('application', 'octet-stream');
      final multipartFile = await http.MultipartFile.fromPath("image", imagePath, contentType: contentType);
      request.files.add(multipartFile);
    }
    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  Future<http.Response> registerDriver({
    required String name,
    required String phone,
    required String password,
    required String plate,
    required TaxiType type,
    required int seats,
    required XFile? taxiImage,
  }) async {
    final url = Uri.parse("$_endpoint/register/driver");
    final request = http.MultipartRequest("POST", url);
    request.fields['name'] = name;
    request.fields['phone'] = phone;
    request.fields['password'] = password;
    request.fields['plate'] = plate;
    request.fields['seats'] = seats.toString();
    request.fields['type'] = type.apiValue;
    if(taxiImage != null) {
      String imagePath = taxiImage.path;
      final mimeType = lookupMimeType(imagePath);
      final contentType = mimeType != null ? MediaType.parse(mimeType) : MediaType('application', 'octet-stream');
      final multipartFile = await http.MultipartFile.fromPath("taxiImage", taxiImage.path, contentType: contentType);
      request.files.add(multipartFile);
    }
    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
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
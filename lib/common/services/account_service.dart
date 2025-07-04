import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:quber_taxi/common/models/client.dart';
import 'package:quber_taxi/common/models/driver.dart';
import 'package:quber_taxi/config/api_config.dart';
import 'package:quber_taxi/enums/taxi_type.dart';
import 'package:quber_taxi/utils/image/image_utils.dart';

class AccountService {

  final _endpoint = "${ApiConfig().baseUrl}/account";

  Future<http.Response> registerClient({
    required String name,
    required String phone,
    required String password,
    required Uint8List faceIdImage,
    XFile? profileImage,
  }) async {
    final url = Uri.parse("$_endpoint/register/client");
    final request = http.MultipartRequest("POST", url);
    request.fields['name'] = name;
    request.fields['phone'] = phone;
    request.fields['password'] = password;
    request.files.add(_getMultipartFileFromUint8List(faceIdImage, "faceIdImage", "upload.jpg"));
    if(profileImage != null) {
      request.files.add(await _getMultipartFileFromXFile(profileImage, "profileImage"));
    }
    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  Future<http.Response> registerDriver({
    required String name,
    required String phone,
    required String password,
    required String plate,
    required TaxiType type ,
    required int seats,
    required Uint8List faceIdImage,
    required XFile taxiImage,
    required XFile licenseImage,
  }) async {
    final url = Uri.parse("$_endpoint/register/driver");
    final request = http.MultipartRequest("POST", url);
    request.fields['name'] = name;
    request.fields['phone'] = phone;
    request.fields['password'] = password;
    request.fields['plate'] = plate;
    request.fields['type'] = type.apiValue;
    request.fields['seats'] = seats.toString();
    request.files.add(_getMultipartFileFromUint8List(faceIdImage, "faceIdImage", "upload.jpg"));
    request.files.add(await _getMultipartFileFromXFile(taxiImage, "taxiImage"));
    request.files.add(await _getMultipartFileFromXFile(licenseImage, "licenseImage"));
    final streamedResponse = await request.send();
    final response =  await http.Response.fromStream(streamedResponse);
    print(response.statusCode);
    print(response.body);
    return response;
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

  http.MultipartFile _getMultipartFileFromUint8List(Uint8List file, String value, String filename) {
    final faceMimeType = lookupMimeType('', headerBytes: file);
    final faceContentType = faceMimeType != null
        ? MediaType.parse(faceMimeType)
        : MediaType('application', 'octet-stream');
    final fixedFaceIdImage = fixImageOrientation(file);
    final multipartFile = http.MultipartFile.fromBytes(
        value,
        fixedFaceIdImage,
        filename: filename,
        contentType: faceContentType
    );
    return multipartFile;
  }

  Future<http.MultipartFile> _getMultipartFileFromXFile(XFile file, String value) async {
    String filePath = file.path;
    final profileMimeType = lookupMimeType(filePath);
    final profileContentType = profileMimeType != null
        ? MediaType.parse(profileMimeType)
        : MediaType('application', 'octet-stream');
    final multipartFile = await http.MultipartFile.fromPath(value, filePath, contentType: profileContentType);
    return multipartFile;
  }
}
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:quber_taxi/common/models/driver.dart';
import 'package:quber_taxi/config/api_config.dart';
import 'package:quber_taxi/enums/taxi_type.dart';
import 'package:quber_taxi/storage/onboarding_prefs_manager.dart';
import 'package:quber_taxi/utils/image/image_utils.dart';

/// A service class that manages account-related operations such as
/// client and driver registration and retrieval of driver data.
///
/// Handles multipart requests for file uploads (face ID, profile, taxi, license images)
/// and ensures proper MIME types and orientation are applied.
class AccountService {

  // Base endpoint for account-related operations.
  final _endpoint = "${ApiConfig().baseUrl}/account";

  /// Registers a new client account by sending a multipart POST request.
  ///
  /// Requires [name], [phone], [password], and a [faceIdImage] in raw bytes.
  /// Optionally accepts a [profileImage] selected from the device.
  ///
  /// Returns the HTTP response from the server.
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
    request.files.add(
      _getMultipartFileFromUint8List(faceIdImage, "faceIdImage", "upload.jpg"),
    );
    if (profileImage != null) {
      request.files.add(await _getMultipartFileFromXFile(profileImage, "profileImage"));
    }
    // Check if any information was saved during onboarding.
    final onboardingData = OnboardingPrefsManager.instance.getOnboardingData();
    if(onboardingData != null) {
      final referralCode = onboardingData["referralCode"];
      if(referralCode != null && referralCode.isNotEmpty) {
        request.fields['referralCode'] = referralCode;
      }
      final referralSource = onboardingData["referralSource"];
      if(referralSource != null) {
        request.fields['referralSource'] = referralSource;
      }
    }
    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  /// Registers a new driver account by sending a multipart POST request.
  ///
  /// Requires driver's [name], [phone], [password], [plate], [type], [seats],
  /// and images for [faceIdImage], [taxiImage], and [licenseImage].
  ///
  /// Returns the HTTP response from the server.
  Future<http.Response> registerDriver({
    required String name,
    required String phone,
    required String password,
    required String plate,
    required TaxiType type,
    required int seats,
    required Uint8List faceIdImage,
    required XFile taxiImage,
    // required XFile licenseImage,
  }) async {
    final url = Uri.parse("$_endpoint/register/driver");
    final request = http.MultipartRequest("POST", url);
    request.fields['name'] = name;
    request.fields['phone'] = phone;
    request.fields['password'] = password;
    request.fields['plate'] = plate;
    request.fields['type'] = type.apiValue;
    request.fields['seats'] = seats.toString();
    request.files.add(
      _getMultipartFileFromUint8List(faceIdImage, "faceIdImage", "upload.jpg"),
    );
    request.files.add(await _getMultipartFileFromXFile(taxiImage, "taxiImage"));
    // request.files.add(await _getMultipartFileFromXFile(licenseImage, "licenseImage"));
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return response;
  }

  /// Fetches a [Driver] object by its [id] from the backend.
  ///
  /// Performs a GET request and parses the response as JSON.
  Future<http.Response> findDriver(int id) async {
    final url = Uri.parse("$_endpoint/driver/$id");
    return await http.get(url);
  }

  Future<List<Driver>> findAllDrivers() async {
    final url = Uri.parse('$_endpoint/driver/all');
    final response = await http.get(url);
    if (response.body.trim().isEmpty) {
      return [];
    }
    final List<dynamic> jsonList = jsonDecode(response.body);
    return jsonList.map((json) => Driver.fromJson(json)).toList();
  }

  Future<http.Response> updateClient(
      int clientId,
      String name,
      String phone,
      XFile? profileImage,
      bool shouldUpdateImage
  ) async {
    final url = Uri.parse("$_endpoint/update/client/$clientId");
    final request = http.MultipartRequest("POST", url);
    request.fields['name'] = name;
    request.fields['phone'] = phone;
    request.fields['shouldUpdateImage'] = shouldUpdateImage.toString();
    if (shouldUpdateImage) {
      if(profileImage != null) {
        request.files.add(await _getMultipartFileFromXFile(profileImage, "profileImage"));
      }
    }
    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  Future<http.Response> updateClientPassword(int clientId, String password) async {
    final url = Uri.parse("$_endpoint/client/$clientId?password=$password");
    return await http.patch(url);
  }

  Future<http.Response> updateDriver(
      int driverId,
      String name,
      String phone,
      int seats,
      String plate,
      XFile? taxiImage,
      bool shouldUpdateImage
      ) async {
    final url = Uri.parse("$_endpoint/update/driver/$driverId");
    final request = http.MultipartRequest("POST", url);
    request.fields['name'] = name;
    request.fields['phone'] = phone;
    request.fields['seats'] = seats.toString();
    request.fields['plate'] = plate;
    request.fields['shouldUpdateImage'] = shouldUpdateImage.toString();

    if (shouldUpdateImage) {
      if (taxiImage != null) {
        request.files.add(await _getMultipartFileFromXFile(taxiImage, "taxiImage"));
      }
    }
    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  Future<http.Response> updateDriverPassword(int driverId, String password)
  async {
    final url = Uri.parse("$_endpoint/driver/$driverId?password=$password");
    return await http.patch(url);
  }


  /// Converts a [Uint8List] (e.g. raw image bytes) into a [http.MultipartFile].
  ///
  /// Optionally corrects image orientation before uploading.
  ///
  /// Used for face ID image uploads during registration.
  http.MultipartFile _getMultipartFileFromUint8List(Uint8List file, String value, String filename) {
    final faceMimeType = lookupMimeType('', headerBytes: file);
    final faceContentType = faceMimeType != null
        ? MediaType.parse(faceMimeType)
        : MediaType('application', 'octet-stream');
    final fixedFaceIdImage = fixImageOrientation(file);
    return http.MultipartFile.fromBytes(
      value,
      fixedFaceIdImage,
      filename: filename,
      contentType: faceContentType,
    );
  }

  /// Converts an [XFile] into a [http.MultipartFile] for multipart upload.
  ///
  /// Attempts to resolve MIME type based on file extension.
  Future<http.MultipartFile> _getMultipartFileFromXFile(XFile file, String value) async {
    final filePath = file.path;
    final profileMimeType = lookupMimeType(filePath);
    final profileContentType = profileMimeType != null
        ? MediaType.parse(profileMimeType)
        : MediaType('application', 'octet-stream');
    return await http.MultipartFile.fromPath(
      value,
      filePath,
      contentType: profileContentType,
    );
  }
}
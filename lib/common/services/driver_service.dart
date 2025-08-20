import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quber_taxi/config/api_config.dart';

/// A service class responsible for driver-specific backend operations.
///
/// Currently handles the process of accepting travel requests.
class DriverService {

  /// API configuration instance to retrieve base URL.
  final _apiConfig = ApiConfig();

  /// Base path for all driver-related endpoints.
  final _endpoint = "drivers";

  /// Sends a request for the driver with [driverId] to accept a travel with [travelId].
  ///
  /// Performs a PATCH request to:
  /// `/drivers/{driverId}?travelId={travelId}`
  ///
  /// The backend is expected to assign the travel to the driver and mark it as accepted.
  ///
  /// Returns the full HTTP response, allowing the caller to inspect the result.
  ///
  /// Example:
  /// ```dart
  /// final response = await driverService.acceptTravel(driverId: 42, travelId: 101);
  /// if (response.statusCode == 200) {
  ///   // Success
  /// }
  /// ```
  Future<http.Response> acceptTravel({
    required int driverId,
    required int travelId,
  }) async {
    final url = Uri.parse("${_apiConfig.baseUrl}/$_endpoint/$driverId?travelId=$travelId");
    final headers = {'Content-Type': 'application/json'};
    return await http.post(url, headers: headers);
  }

  Future<http.Response> changeState({required int driverId}) async {
    final url = Uri.parse("${_apiConfig.baseUrl}/$_endpoint/$driverId");
    final headers = {'Content-Type': 'application/json'};
    return await http.patch(url, headers: headers);
  }

  /// Recharges the credit for the driver with [driverId] by the specified [amount].
  ///
  /// Performs a POST request to:
  /// `/drivers/{driverId}/recharge`
  ///
  /// The request body contains the amount to recharge.
  ///
  /// Returns the full HTTP response, allowing the caller to inspect the result.
  ///
  /// Example:
  /// ```dart
  /// final response = await driverService.rechargeCredit(driverId: 123, amount: 50.0);
  /// if (response.statusCode == 200) {
  ///   // Success
  /// }
  /// ```
  Future<http.Response> rechargeCredit({
    required int driverId,
    required double amount,
  }) async {
    final url = Uri.parse("${_apiConfig.baseUrl}/$_endpoint/$driverId/recharge");
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'amount': amount});
    return await http.post(url, headers: headers, body: body);
  }

  /// Reports a client for not showing up or making contact.
  ///
  /// Performs a POST request to:
  /// `/drivers/{driverId}/reports?clientId={clientId}`
  ///
  /// The backend is expected to create a client report.
  ///
  /// Returns the full HTTP response, allowing the caller to inspect the result.
  ///
  /// Example:
  /// ```dart
  /// final response = await driverService.reportClient(driverId: 42, clientId: 101);
  /// if (response.statusCode == 200) {
  ///   // Success
  /// }
  /// ```
  Future<http.Response> reportClient({
    required int driverId,
    required int clientId,
    required String reason,
  }) async {
    final url = Uri.parse("${_apiConfig.baseUrl}/reports"
        "?driverId=$driverId"
        "&clientId=$clientId"
        "&reason=$reason"
    );
    final headers = {'Content-Type': 'application/json'};
    return await http.post(url, headers: headers);
  }
}
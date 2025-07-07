import 'package:http/http.dart' as http;
import 'package:quber_taxi/config/api_config.dart';
import 'package:quber_taxi/enums/driver_account_state.dart';

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
    return await http.patch(url, headers: headers);
  }

  Future<http.Response> changeState({
    required int driverId,
    required DriverAccountState state,
  }) async {
    final url = Uri.parse("${_apiConfig.baseUrl}/$_endpoint/$driverId?state=${state.apiValue}");
    final headers = {'Content-Type': 'application/json'};
    return await http.patch(url, headers: headers);
  }
}
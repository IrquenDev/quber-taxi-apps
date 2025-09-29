import 'package:http/http.dart' as http;
import 'package:quber_taxi/config/api_config.dart';

/// A service class that handles SOS emergency alert creation.
///
/// This service sends the alert to the backend API using provided IDs as URL parameters.
class SosAlertService {
  /// API configuration instance.
  final _apiConfig = ApiConfig();

  /// Base endpoint for SOS alert operations.
  final _endpoint = "sos-alerts";

  /// Creates a new SOS alert in the system.
  ///
  /// Sends the alert with [travelId], [clientId], and [driverId] as URL parameters.
  Future<http.Response> createSosAlert({
    required int travelId,
    required int clientId,
    required int driverId,
  }) async {
    final uri = Uri.parse('${_apiConfig.baseUrl}/$_endpoint').replace(
      queryParameters: {
        'travelId': travelId.toString(),
        'clientId': clientId.toString(),
        'driverId': driverId.toString(),
      },
    );
    final response = await http.post(uri);
    return response;
  }
}

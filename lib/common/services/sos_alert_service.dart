import 'package:http/http.dart' as http;
import 'package:quber_taxi/config/api_config.dart';
import 'package:quber_taxi/navigation/backup_navigation_manager.dart';

/// A service class that handles SOS emergency alert creation.
///
/// This service automatically extracts travel data from the BackupNavigationManager
/// and sends the alert to the backend API with the required IDs as URL parameters.
class SosAlertService {
  /// API configuration instance.
  final _apiConfig = ApiConfig();

  /// Base endpoint for SOS alert operations.
  final _endpoint = "sos-alerts";

  /// Creates a new SOS alert in the system.
  ///
  /// Automatically extracts travel data from BackupNavigationManager and sends
  /// the alert with travelId, clientId, and driverId as URL parameters.
  Future<http.Response> createSosAlert() async {
    final travel = BackupNavigationManager.instance.getSavedTravel();
    final uri = Uri.parse('${_apiConfig.baseUrl}/$_endpoint').replace(
      queryParameters: {
        'travelId': travel.id.toString(),
        'clientId': travel.client.id.toString(),
        'driverId': travel.driver!.id.toString(),
      },
    );
    final response = await http.post(uri);
    return response;
  }
}

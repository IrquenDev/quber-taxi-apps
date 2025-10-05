import 'package:http/http.dart' as http;
import 'package:quber_taxi/config/api_config.dart';

/// A service class responsible for client-specific backend operations.
///
/// Handles client state management operations for admin functionality.
class ClientService {

  /// API configuration instance to retrieve base URL.
  final _apiConfig = ApiConfig();

  /// Base path for all client-related endpoints.
  final _endpoint = "clients";

  /// Changes the state of a client with [clientId].
  ///
  /// Performs a PATCH request to:
  /// `/clients/{clientId}`
  ///
  /// The backend is expected to toggle the client's account state
  /// (block/unblock the account).
  ///
  /// Returns the full HTTP response, allowing the caller to inspect the result.
  ///
  /// Example:
  /// ```dart
  /// final response = await clientService.changeState(clientId: 42);
  /// if (response.statusCode == 200) {
  ///   // Success
  /// }
  /// ```
  Future<http.Response> changeState({required int clientId}) async {
    final url = Uri.parse("${_apiConfig.baseUrl}/$_endpoint/$clientId");
    final headers = {'Content-Type': 'application/json'};
    return await http.patch(url, headers: headers);
  }
}

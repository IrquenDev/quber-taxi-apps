import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quber_taxi/common/models/admin.dart';
import 'package:quber_taxi/common/models/client.dart';
import 'package:quber_taxi/common/models/driver.dart';
import 'package:quber_taxi/config/api_config.dart';
import 'package:quber_taxi/storage/session_manger.dart';
import 'package:quber_taxi/utils/runtime.dart' as runtime;

/// A service responsible for handling user authentication for clients, drivers, and admins.
///
/// Performs login operations using HTTP requests and persists user sessions
/// via the [SessionManager] after successful authentication.
///
/// Each login method returns the full HTTP response, allowing
/// the caller to handle status codes or errors.
class AuthService {
  /// Base endpoint for authentication-related operations.
  final _endpoint = "${ApiConfig().baseUrl}/auth";

  /*
  /// Checks if a session is still active by validating the session ID cookie.
  ///
  /// This method is commented out but may be used to verify
  /// if a user has a valid backend session.
  Future<bool> isSessionActive() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('sessionId');
    if (sessionId == null) return false;
    final url = Uri.parse("$_endpoint/session-status");
    final response = await http.post(
      url,
      headers: {'Cookie': 'JSESSIONID=$sessionId'},
    );
    return response.statusCode == 200;
  }
  */

  /// Attempts to log in a client using [phone] and [password].
  ///
  /// On success (HTTP 200), parses the response into a [Client]
  /// and saves the session via [SessionManager].
  Future<http.Response> loginClient(String phone, String password) async {
    final url = Uri.parse("$_endpoint/login/client?phone=$phone&password=$password");
    final response = await http.post(url);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final client = Client.fromJson(json);
      await SessionManager.instance.save(client);
    }
    return response;
  }

  /// Attempts to log in a driver using [phone] and [password].
  ///
  /// On success (HTTP 200), parses the response into a [Driver]
  /// and saves the session via [SessionManager].
  Future<http.Response> loginDriver(String phone, String password) async {
    final url = Uri.parse("$_endpoint/login/driver?phone=$phone&password=$password");
    final response = await http.post(url);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final driver = Driver.fromJson(json);
      await SessionManager.instance.save(driver);
    }
    return response;
  }

  /// Attempts to log in an admin using [phone] and [password].
  ///
  /// On success (HTTP 200), parses the response into an [Admin]
  /// and saves the session via [SessionManager].
  Future<http.Response> loginAdmin(String phone, String password) async {
    final url = Uri.parse("$_endpoint/login/admin?phone=$phone&password=$password");
    final response = await http.post(url);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final admin = Admin.fromJson(json);
      SessionManager.instance.save(admin);
    }
    return response;
  }

  Future<http.Response> requestPasswordReset(String phone) async {
    final url = Uri.parse("$_endpoint/password-reset/request?phone=$phone");
    final response = await http.post(url);
    return response;
  }

  Future<http.Response> resetPassword({
    required String phone,
    required String code,
    required String newPassword,
  }) async {
    final isDriver = runtime.isDriverMode;
    final path = isDriver ? '/reset-driver' : '/reset-client';
    final url = Uri.parse("$_endpoint/password-reset$path");
    final body = jsonEncode({
      "phone": phone,
      "code": code,
      "newPassword": newPassword,
    });
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: body,
    );
    return response;
  }


}
import 'dart:convert';
import 'package:quber_taxi/common/models/travel.dart';
import 'package:quber_taxi/storage/prefs_manager.dart';

/// Manages backup navigation for client search_driver flow only.
class BackupNavigationManager {

  BackupNavigationManager._internal();

  static final BackupNavigationManager instance = BackupNavigationManager._internal();

  // Keys are client-scoped and specific to search_driver
  static const String _shouldRedirectKey = 'client_sd_shouldRedirect';
  static const String _routeKey = 'client_sd_route';
  static const String _travelKey = 'client_sd_travel';

  final SharedPrefsManager _prefsManager = SharedPrefsManager.instance;

  /// Clears stored backup state for search_driver flow.
  Future<void> clear() async {
    await _prefsManager.remove(_routeKey);
    await _prefsManager.remove(_travelKey);
    await _prefsManager.remove(_shouldRedirectKey);
  }

  /// Stores backup data for search_driver: route and travelId.
  Future<bool> saveSearchDriver({required String route, required Travel travel}) async {
    final a = await _prefsManager.setString(_routeKey, route);
    final b = await _prefsManager.setString(_travelKey, jsonEncode(travel.toJson()));
    final c = await _prefsManager.setBool(_shouldRedirectKey, true);
    return (a == true && b == true && c == true);
  }

  /// Returns stored Travel for search_driver when redirection is required.
  Travel getSearchDriverTravel() {
    if (!shouldRedirect()) {
      throw StateError('Attempt to get travel when no redirection is required');
    }
    final raw = _prefsManager.getString(_travelKey);
    if (raw == null) {
      throw StateError('No travel found despite redirection is required');
    }
    return Travel.fromJson(jsonDecode(raw));
  }

  /// Returns the saved route (for debugging/telemetry purposes).
  String? getSavedRoute() => _prefsManager.getString(_routeKey);

  // No requestedAt storage. Use Travel.requestedDate from backend when needed.

  /// Whether the app should redirect to search_driver on startup.
  bool shouldRedirect() => _prefsManager.getBool(_shouldRedirectKey) ?? false;
}



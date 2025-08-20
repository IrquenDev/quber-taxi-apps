import 'dart:convert';
import 'dart:async';
import 'package:quber_taxi/common/models/travel.dart';
import 'package:quber_taxi/storage/prefs_manager.dart';

/// Manages backup navigation for client flows using a single generic entry.
class BackupNavigationManager {

  BackupNavigationManager._internal();

  static final BackupNavigationManager instance = BackupNavigationManager._internal();

  static const String _shouldRedirectKey = 'client_bu_shouldRedirect';
  static const String _routeKey = 'client_bu_route';
  static const String _travelKey = 'client_bu_travel';

  final SharedPrefsManager _prefsManager = SharedPrefsManager.instance;

  /// Clears stored backup state.
  Future<void> clear() async {
    await _prefsManager.remove(_routeKey);
    await _prefsManager.remove(_travelKey);
    await _prefsManager.remove(_shouldRedirectKey);
  }

  /// Returns stored Travel when redirection is required.
  Travel getSavedTravel() {
    if (!shouldRestorePage()) {
      throw StateError('Attempt to get travel when no redirection is required');
    }
    final raw = _prefsManager.getString(_travelKey);
    if (raw == null) {
      throw StateError('No travel found despite redirection is required');
    }
    return Travel.fromJson(jsonDecode(raw));
  }

  /// Returns the saved route (used to decide which page to restore).
  String? getSavedRoute() => _prefsManager.getString(_routeKey);

  /// Stores backup data: route and travel.
  Future<bool> save({required String route, required Travel travel}) async {
    final a = await _prefsManager.setString(_routeKey, route);
    final b = await _prefsManager.setString(_travelKey, jsonEncode(travel.toJson()));
    final c = await _prefsManager.setBool(_shouldRedirectKey, true);
    return (a == true && b == true && c == true);
  }

  /// Whether the app should redirect on startup.
  bool shouldRestorePage() {
    final shouldRedirect = _prefsManager.getBool(_shouldRedirectKey) ?? false;
    if (!shouldRedirect) return false;
    // Check if travel has expired (more than 24 hours)
    if (_isTravelExpired()) {
      // Clear expired backup data
      clear();
      return false;
    }
    return true;
  }

  /// Checks if the stored travel has expired (more than 24 hours since requested).
  /// Call only inside shouldRestorePage.
  bool _isTravelExpired() {
    try {
      final raw = _prefsManager.getString(_travelKey);
      if (raw == null) return true;
      final travel = Travel.fromJson(jsonDecode(raw));
      final now = DateTime.now();
      final timeDifference = now.difference(travel.requestedDate);
      // Check if more than 24 hours have passed
      return timeDifference.inHours >= 24;
    } catch (e) {
      // If there's any error parsing the travel, consider it expired
      return true;
    }
  }
}
import 'dart:convert';
import 'package:quber_taxi/common/models/encodable.dart';
import 'package:quber_taxi/storage/prefs_manager.dart';

/// A singleton class that manages the user's login session using [SharedPrefsManager].
class SessionManager {

  // Private constructor for singleton pattern.
  SessionManager._internal();

  /// Singleton instance of [SessionManager].
  static final SessionManager instance = SessionManager._internal();

  /// Key used to store the session state (true if user is logged in).
  static const _isSessionOk = "isSessionOk";

  /// Key used to store the logged in user (JSON-encoded string).
  static const _loggedInUser = "loggedInUser";

  /// Internal list of keys used by the session (useful for clearing all session data).
  final _keys = const [_isSessionOk, _loggedInUser];

  /// Internal reference to the shared preferences manager.
  ///
  /// Assumes [SharedPrefsManager.init] has already been called.
  final SharedPrefsManager _prefsManager = SharedPrefsManager.instance;

  /// Returns true if a valid session exists.
  ///
  /// A session is considered valid if the `_isSessionOk` flag is set to true.
  bool isSessionOk() => _prefsManager.getBool(_isSessionOk) ?? false;

  /// Returns the currently logged-in user as a decoded JSON object.
  ///
  /// The returned object must be cast manually to its correct type. For example:
  /// ```dart
  /// final client = Client.fromJson(loggedInUser);
  /// ```
  ///
  /// Types handled: [Client], [Driver], [Admin].
  ///
  /// Throws a [StateError] if no session is currently active or if that's true, but no logged in user related data
  /// has been found.
  dynamic getLoggedInUserAsRawType() {
    if (isSessionOk()) {
      final raw = _prefsManager.getString(_loggedInUser);
      if (raw != null) {
        return jsonDecode(raw);
      }
      throw StateError("No logged in user data found despite session being active");
    }
    throw StateError("Attempt to get a logged in user while there is no session active");
  }

  /// Saves a user object to shared preferences and marks the session as active.
  ///
  /// Returns true if both the user and session flag were successfully stored.
  Future<bool> save(Encodable user) async {
    final userSaved = await _setLoggedInUser(user);
    if (userSaved) {
      final flagSaved = await _prefsManager.setBool(_isSessionOk, true);
      return flagSaved ? true : false;
    }
    return false;
  }

  /// Clears all session-related keys from shared preferences.
  Future<void> clear() async {
    for (final key in _keys) {
      await _prefsManager.remove(key);
    }
  }

  /// Internal method to JSON-encode and store the user object.
  Future<bool> _setLoggedInUser(Encodable user) {
    return _prefsManager.setString(_loggedInUser, jsonEncode(user.toJson()));
  }
}
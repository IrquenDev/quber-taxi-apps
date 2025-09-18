import 'package:quber_taxi/storage/prefs_manager.dart';

class ConfigPrefsManager {

  // Private constructor for singleton pattern.
  ConfigPrefsManager._internal();

  /// Singleton instance of [SessionPrefsManager].
  static final ConfigPrefsManager instance = ConfigPrefsManager._internal();

  static const _operatorPhone = "operatorPhone";

  /// Internal reference to the shared preferences manager.
  ///
  /// Assumes [SharedPrefsManager.init] has already been called.
  final SharedPrefsManager _prefsManager = SharedPrefsManager.instance;

  String? getOperatorPhone() => _prefsManager.getString(_operatorPhone);

  Future<void> saveOperatorPhone(String phone) async => await _prefsManager.setString(_operatorPhone, phone);

  /// Clears all session-related keys from shared preferences.
  Future<void> clear() async => await _prefsManager.remove(_operatorPhone);
}
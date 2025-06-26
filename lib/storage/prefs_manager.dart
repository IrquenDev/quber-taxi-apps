import 'package:shared_preferences/shared_preferences.dart';

/// A singleton manager for SharedPreferences, providing safe and efficient
/// access to key-value pairs throughout the app.
///
/// Use [SharedPrefsManager.init] to initialize the singleton before accessing it
/// via [SharedPrefsManager.instance]. This ensures the underlying
/// [SharedPreferences] object is properly loaded before use.
///
/// Example:
/// ```dart
/// await SharedPrefsManager.init();
/// final prefs = SharedPrefsManager.instance;
/// prefs.setString('key', 'value');
/// ```
class SharedPrefsManager {
  static SharedPrefsManager? _instance;

  final SharedPreferences _prefs;

  /// Private constructor. Use [init] to create the singleton.
  const SharedPrefsManager._internal(this._prefs);

  /// Whether the singleton has been initialized.
  static bool get isInitialized => _instance != null;

  /// Initializes the singleton instance asynchronously.
  ///
  /// This must be called before accessing [instance].
  static Future<void> init() async {
    if (isInitialized) return;
    final prefs = await SharedPreferences.getInstance();
    _instance = SharedPrefsManager._internal(prefs);
  }

  /// Provides access to the singleton instance after initialization.
  ///
  /// Throws a [StateError] if accessed before calling [init].
  static SharedPrefsManager get instance {
    if (!isInitialized) {
      throw StateError(
          "SharedPrefsManager not initialized. Call SharedPrefsManager.init() first."
      );
    }
    return _instance!;
  }

  /// Retrieves a string value for the given [key], or null if not found.
  String? getString(String key) => _prefs.getString(key);

  /// Saves a string [value] under the given [key].
  Future<bool> setString(String key, String value) => _prefs.setString(key, value);

  /// Retrieves a boolean value for the given [key], or null if not found.
  bool? getBool(String key) => _prefs.getBool(key);

  /// Saves a boolean [value] under the given [key].
  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);

  /// Removes the value associated with the given [key].
  Future<bool> remove(String key) => _prefs.remove(key);
}
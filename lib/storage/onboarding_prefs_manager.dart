import 'dart:convert';
import 'package:quber_taxi/storage/prefs_manager.dart';

class OnboardingPrefsManager {

  // Private constructor for singleton pattern.
  OnboardingPrefsManager._internal();

  /// Singleton instance of [OnboardingPrefsManager].
  static final OnboardingPrefsManager instance = OnboardingPrefsManager._internal();

  static const _isOnboardingDone = "isOnboardingDone";

  static const _onboardingData = "onboardingData";

  /// Internal reference to the shared preferences manager.
  ///
  /// Assumes [SharedPrefsManager.init] has already been called.
  final SharedPrefsManager _prefsManager = SharedPrefsManager.instance;

  bool isOnboardingDone() => _prefsManager.getBool(_isOnboardingDone) ?? false;

  Map<String, String>? getOnboardingData() {
    if (isOnboardingDone()) {
      final raw = _prefsManager.getString(_onboardingData);
      if (raw != null) {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          return decoded.map((key, value) => MapEntry(key.toString(), value.toString()));
        }
      }
      return null;
    }
    throw StateError("Attempt to get onboarding data while it doesn't done yet");
  }

  Future<bool> saveData(Map<String, String> onboardingData) async {
    final dataSaved = await _setOnboardingData(onboardingData);
    if (dataSaved) {
      final flagSaved = await _prefsManager.setBool(_isOnboardingDone, true);
      return flagSaved ? true : false;
    } else {
      return false;
    }
  }

  /// Internal method to JSON-encode and store the onboarding data.
  Future<bool> _setOnboardingData(Map<String, String> onboardingData) {
    return _prefsManager.setString(_onboardingData, jsonEncode(onboardingData));
  }
}
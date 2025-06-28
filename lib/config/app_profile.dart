/// Provides the profile of the application that is currently running.
enum AppProfile {

  /// Refers to the Driver App.
  driver,

  /// Refers to the Client App.
  client,

  /// Refers to the Admin App.
  admin;

  /// Returns the uppercase string value associated with the app profile.
  String get value => name.toUpperCase();

  /// Resolves an [AppProfile] from a given string value (case-insensitive).
  static AppProfile resolve(String value) {
    return AppProfile.values.firstWhere(
          (e) => e.value == value.toUpperCase(),
      orElse: () => throw StateError("No supported profile: $value")
    );
  }
}
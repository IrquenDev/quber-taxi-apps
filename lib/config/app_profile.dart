import 'package:flutter/services.dart';

/// Provides the profile of the application that is currently running.
enum AppProfile {

  /// Refers to the Driver App.
  driver,

  /// Refers to the Client App.
  client,

  /// Refers to the Admin App.
  admin;

  /// Resolves an [AppProfile] from a given string value (case-insensitive).
  static AppProfile resolve() {
    return AppProfile.values.firstWhere((e) => e.name == appFlavor);
  }
}
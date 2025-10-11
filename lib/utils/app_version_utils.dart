import 'package:package_info_plus/package_info_plus.dart';

class AppVersionUtils {
  static String? _currentVersion;

  /// Gets the current app version
  static Future<String> getCurrentVersion() async {
    if (_currentVersion != null) return _currentVersion!;
    
    final packageInfo = await PackageInfo.fromPlatform();
    _currentVersion = packageInfo.version;
    return _currentVersion!;
  }

  /// Compares two version strings
  /// Returns:
  /// - negative number if version1 < version2
  /// - 0 if version1 == version2  
  /// - positive number if version1 > version2
  static int compareVersions(String version1, String version2) {
    final v1Parts = version1.split('.').map(int.parse).toList();
    final v2Parts = version2.split('.').map(int.parse).toList();
    
    // Ensure both lists have the same length by padding with zeros
    final maxLength = v1Parts.length > v2Parts.length ? v1Parts.length : v2Parts.length;
    
    while (v1Parts.length < maxLength) {
      v1Parts.add(0);
    }
    while (v2Parts.length < maxLength) {
      v2Parts.add(0);
    }
    
    for (int i = 0; i < maxLength; i++) {
      final comparison = v1Parts[i].compareTo(v2Parts[i]);
      if (comparison != 0) return comparison;
    }
    
    return 0;
  }

  /// Checks if current app version is less than the required version
  static Future<bool> isCurrentVersionLessThan(String requiredVersion) async {
    final currentVersion = await getCurrentVersion();
    return compareVersions(currentVersion, requiredVersion) < 0;
  }

  /// Checks if current app version is greater than or equal to the required version
  static Future<bool> isCurrentVersionGreaterOrEqual(String requiredVersion) async {
    final currentVersion = await getCurrentVersion();
    return compareVersions(currentVersion, requiredVersion) >= 0;
  }
} 
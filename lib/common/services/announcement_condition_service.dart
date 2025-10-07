import 'package:quber_taxi/common/models/announcement_metadata.dart';
import 'package:quber_taxi/common/models/app_announcement.dart';
import 'package:quber_taxi/utils/app_version_utils.dart';

/// Service to handle conditional announcement logic
class AnnouncementConditionService {

  /// Filters a list of announcements based on their conditions
  static Future<List<AppAnnouncement>> filterConditionalAnnouncements(List<AppAnnouncement> announcements) async {
    final List<AppAnnouncement> filteredAnnouncements = [];
    for (final announcement in announcements) {
      if (await _shouldShowConditionalAnnouncement(announcement)) {
        filteredAnnouncements.add(announcement);
      }
    }
    return filteredAnnouncements;
  }
  
  /// Checks if a conditional announcement should be shown based on its conditions
  static Future<bool> _shouldShowConditionalAnnouncement(AppAnnouncement announcement) async {
    // Get metadata directly (now it's already of type AnnouncementMetadata?)
    final metadata = announcement.metadata ?? const AnnouncementMetadata();
    // If not conditional, always show
    if (!metadata.conditional) return true;
    // If conditional, check app version condition
    return await _checkAppVersionCondition(metadata.appVersion);
  }

  /// Checks if the app version condition is met
  /// Returns true if the announcement should be shown based on app version
  static Future<bool> _checkAppVersionCondition(String? appVersion) async {
    // If no appVersion specified, condition is met (show announcement)
    if (appVersion == null || appVersion.isEmpty) {
      return true;
    }
    try {
      // Show announcement if current app version is less than required version
      return await AppVersionUtils.isCurrentVersionLessThan(appVersion);
    } catch (e) {
      // If version comparison fails, don't show the announcement to be safe
      return false;
    }
  }
}

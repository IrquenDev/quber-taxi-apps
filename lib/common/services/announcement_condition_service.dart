import 'package:quber_taxi/common/models/announcement_metadata.dart';
import 'package:quber_taxi/common/models/app_announcement.dart';
import 'package:quber_taxi/utils/app_version_utils.dart';

/// Service to handle conditional announcement logic
class AnnouncementConditionService {
  
  /// Checks if a conditional announcement should be shown based on its conditions
  static Future<bool> shouldShowConditionalAnnouncement(AppAnnouncement announcement) async {
    // Parse metadata to get conditional settings
    final metadata = AnnouncementMetadata.fromMetadata(announcement.metadata);
    
    // If not conditional, always show
    if (!metadata.conditionalAnnouncement) return true;
    
    // If conditional, check app version condition
    return await _checkAppVersionCondition(metadata);
  }

  /// Checks if the app version condition is met
  /// Returns true if the announcement should be shown based on app version
  static Future<bool> _checkAppVersionCondition(AnnouncementMetadata metadata) async {
    // If no appVersion specified, condition is met (show announcement)
    if (metadata.appVersion == null || metadata.appVersion!.isEmpty) {
      return true;
    }
    
    try {
      // Show announcement if current app version is less than required version
      return await AppVersionUtils.isCurrentVersionLessThan(metadata.appVersion!);
    } catch (e) {
      // If version comparison fails, don't show the announcement to be safe
      print('Error comparing app versions: $e');
      return false;
    }
  }

  /// Filters a list of announcements based on their conditions
  static Future<List<AppAnnouncement>> filterConditionalAnnouncements(
    List<AppAnnouncement> announcements
  ) async {
    final List<AppAnnouncement> filteredAnnouncements = [];
    
    for (final announcement in announcements) {
      if (await shouldShowConditionalAnnouncement(announcement)) {
        filteredAnnouncements.add(announcement);
      }
    }
    
    return filteredAnnouncements;
  }
} 
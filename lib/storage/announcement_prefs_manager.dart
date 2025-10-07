import 'package:quber_taxi/storage/prefs_manager.dart';

/// A singleton manager for announcement-related preferences using [SharedPrefsManager].
/// 
/// Handles caching of viewed announcement IDs to prevent showing the same announcements
/// multiple times to users.
class AnnouncementPrefsManager {
  // Private constructor for singleton pattern
  AnnouncementPrefsManager._internal();

  /// Singleton instance of [AnnouncementPrefsManager]
  static final AnnouncementPrefsManager instance = AnnouncementPrefsManager._internal();

  /// Key prefix for storing viewed announcement IDs
  static const String _viewedAnnouncementsKey = "viewed_announcements";

  /// Internal reference to the shared preferences manager
  final SharedPrefsManager _prefsManager = SharedPrefsManager.instance;

  /// Gets the set of viewed announcement IDs
  Set<int> getViewedAnnouncementIds() {
    final viewedIdsString = _prefsManager.getString(_viewedAnnouncementsKey);
    if (viewedIdsString == null || viewedIdsString.isEmpty) {
      return <int>{};
    }
    
    try {
      final idsList = viewedIdsString.split(',').map(int.parse).toSet();
      return idsList;
    } catch (e) {
      // If parsing fails, return empty set
      return <int>{};
    }
  }

  /// Marks an announcement as viewed by adding its ID to the cache
  Future<bool> markAnnouncementAsViewed(int announcementId) async {
    final viewedIds = getViewedAnnouncementIds();
    viewedIds.add(announcementId);
    
    final idsString = viewedIds.join(',');
    return await _prefsManager.setString(_viewedAnnouncementsKey, idsString);
  }

  /// Marks multiple announcements as viewed
  Future<bool> markAnnouncementsAsViewed(List<int> announcementIds) async {
    final viewedIds = getViewedAnnouncementIds();
    viewedIds.addAll(announcementIds);
    
    final idsString = viewedIds.join(',');
    return await _prefsManager.setString(_viewedAnnouncementsKey, idsString);
  }

  /// Clears all viewed announcement IDs from cache
  Future<bool> clearViewedAnnouncements() async {
    return await _prefsManager.remove(_viewedAnnouncementsKey);
  }

  /// Checks if a specific announcement has been viewed
  bool hasViewedAnnouncement(int announcementId) {
    final viewedIds = getViewedAnnouncementIds();
    return viewedIds.contains(announcementId);
  }
}

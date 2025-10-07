import 'package:flutter/material.dart';
import 'package:quber_taxi/common/models/app_announcement.dart';
import 'package:quber_taxi/common/pages/app_announcement/announcement.dart';
import 'package:quber_taxi/common/services/app_announcement_service.dart';
import 'package:quber_taxi/storage/announcement_prefs_manager.dart';
import 'package:quber_taxi/utils/websocket/impl/announcement_handler.dart';

/// A wrapper widget that manages announcement display over the main app content.
/// 
/// This widget uses a Stack to overlay announcements on top of the main app
/// while keeping the app content visible underneath.
class AnnouncementWrapper extends StatefulWidget {
  /// The main app content that will be displayed underneath announcements
  final Widget child;

  const AnnouncementWrapper({
    super.key,
    required this.child,
  });

  @override
  State<AnnouncementWrapper> createState() => _AnnouncementWrapperState();
}

class _AnnouncementWrapperState extends State<AnnouncementWrapper> {
  bool _showAnnouncements = true;
  AnnouncementWebSocketHandler? _announcementHandler;

  @override
  void initState() {
    super.initState();
    _activateAnnouncementHandler();
  }

  @override
  void dispose() {
    _announcementHandler?.deactivate();
    super.dispose();
  }

  void _activateAnnouncementHandler() {
    _announcementHandler = AnnouncementWebSocketHandler(
      onNewAnnouncement: (announcement) {
        // Trigger immediate UI update for new announcements
        setState(() {
          _showAnnouncements = true;
        });
      },
    )..activate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    body: Stack(
      children: [
        // Main app content - always visible underneath
        widget.child,
        // Future announcement display
        if (_showAnnouncements)
          FutureBuilder<List<AppAnnouncement>>(
            future: _getAnnouncements(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox.shrink();
              }
              if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                return const SizedBox.shrink();
              }
              // Show all announcements with callback to hide them
              return AppAnnouncementPage(
                announcements: snapshot.data!,
                onDone: () {
                  setState(() {
                    _showAnnouncements = false;
                  });
                },
                onCacheAnnouncements: (announcementIds) {
                  // Cache the viewed announcement IDs
                  AnnouncementPrefsManager.instance.markAnnouncementsAsViewed(announcementIds);
                },
              );
            },
          ),
      ],
    ),
    );
  }

  /// Gets announcements from the service and filters out already viewed ones
  Future<List<AppAnnouncement>> _getAnnouncements() async {
    final announcementService = AppAnnouncementService();
    final allAnnouncements = await announcementService.getActiveAnnouncements();
    
    // Get viewed announcement IDs from cache
    final viewedIds = AnnouncementPrefsManager.instance.getViewedAnnouncementIds();
    
    // Filter out already viewed announcements
    final unviewedAnnouncements = allAnnouncements.where((announcement) {
      return !viewedIds.contains(announcement.id);
    }).toList();
    
    // Sort announcements: non-dismissible first, then dismissible
    unviewedAnnouncements.sort((a, b) {
      if (a.isDismissible == b.isDismissible) return 0;
      return a.isDismissible ? 1 : -1; // false (non-dismissible) comes first
    });
    
    return unviewedAnnouncements;
  }
}

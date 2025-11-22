import 'dart:convert';
import 'package:quber_taxi/common/models/app_announcement.dart';
import 'package:quber_taxi/config/build_config.dart';
import 'package:quber_taxi/utils/websocket/core/websocket_handler.dart';

/// A WebSocket handler that listens for new announcements in real-time.
///
/// This handler subscribes to `/topic/announcements/{profile}/new` and triggers
/// a callback when new announcements are received from the backend.
/// This is used for immediate reaction to new announcements, while the main
/// announcement filtering is handled via REST API in the wrapper widget.
///
/// Usage:
/// ```dart
/// final handler = AnnouncementWebSocketHandler(
///   onNewAnnouncements: (announcements) {
///     // Trigger immediate UI update for new announcements
///   },
/// );
/// handler.activate();
/// ```
///
/// The expected message format is a single JSON [AppAnnouncement] object.
class AnnouncementWebSocketHandler extends WebSocketHandler<AppAnnouncement> {

  /// Callback executed when a new announcement is received
  final void Function(AppAnnouncement announcement) onNewAnnouncement;

  /// Creates a new handler to listen for announcements
  AnnouncementWebSocketHandler({
    required this.onNewAnnouncement,
  });

  /// The WebSocket topic for receiving new announcements
  /// Format: `/topic/announcements/{profile}/new`
  @override
  String get topic {
    final profile = BuildConfig.appProfile.apiValue;
    return "/topic/announcements/$profile/new";
  }

  /// Whether this handler requires delivery acknowledgement
  /// Set to false since the API won't track these messages for queuing
  @override
  bool get ackRequired => false;

  /// Parses the incoming raw JSON string into a single [AppAnnouncement] object
  @override
  AppAnnouncement parseMessage(String raw) {
    final Map<String, dynamic> jsonMap = jsonDecode(raw);
    return AppAnnouncement.fromJson(jsonMap);
  }

  /// Dispatches the parsed [AppAnnouncement] object to the provided callback
  @override
  void handleMessage(AppAnnouncement parsed) => onNewAnnouncement(parsed);
}

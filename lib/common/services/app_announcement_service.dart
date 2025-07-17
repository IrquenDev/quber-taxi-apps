import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quber_taxi/common/models/app_announcement.dart';
import 'package:quber_taxi/config/api_config.dart';

/// A service responsible for handling app announcements from the backend.
///
/// Fetches announcements from the `/announcements` endpoint and provides
/// methods to retrieve and parse them into [AppAnnouncement] objects.
class AppAnnouncementService {
  /// Base endpoint for announcement-related operations.
  final _endpoint = "${ApiConfig().baseUrl}/announcements";

  /// Retrieves all announcements from the backend.
  ///
  /// Returns a [Future<http.Response>] containing the raw HTTP response.
  /// On success (HTTP 200), the response body contains a JSON array of announcements.
  Future<http.Response> getAllAnnouncements() async {
    final url = Uri.parse(_endpoint);
    final response = await http.get(url);
    return response;
  }

  /// Retrieves all announcements and parses them into [AppAnnouncement] objects.
  ///
  /// Returns a [Future<List<AppAnnouncement>>] containing the parsed announcements.
  /// Returns an empty list if the request fails or if there are no announcements.
  Future<List<AppAnnouncement>> getAnnouncementsList() async {
    try {
      final response = await getAllAnnouncements();
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => AppAnnouncement.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      // Log error or handle it as needed
      return [];
    }
  }

  /// Retrieves announcements that are currently active/visible.
  ///
  /// This method can be extended to filter announcements based on
  /// additional criteria like date ranges, user preferences, etc.
  Future<List<AppAnnouncement>> getActiveAnnouncements() async {
    final announcements = await getAnnouncementsList();
    // For now, return all announcements
    // Future enhancement: filter by date, user preferences, etc.
    return announcements;
  }
} 
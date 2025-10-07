import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quber_taxi/common/models/app_announcement.dart';
import 'package:quber_taxi/common/services/announcement_condition_service.dart';
import 'package:quber_taxi/config/api_config.dart';
import 'package:quber_taxi/config/app_profile.dart';
import 'package:quber_taxi/config/build_config.dart';

/// A service responsible for handling app announcements from the backend.
///
/// Fetches announcements from the `/announcements` endpoint and provides
/// methods to retrieve and parse them into [AppAnnouncement] objects.
class AppAnnouncementService {
  /// Base endpoint for announcement-related operations.
  final _baseEndpoint = "${ApiConfig().baseUrl}/announcements";

  /// Retrieves all announcements from the backend.
  ///
  /// Returns a [Future<http.Response>] containing the raw HTTP response.
  /// On success (HTTP 200), the response body contains a JSON array of announcements.
  Future<http.Response> _getAllAnnouncements() async {
    final endpoint = switch (BuildConfig.appProfile) {
      AppProfile.driver => "$_baseEndpoint/driver",
      AppProfile.client => "$_baseEndpoint/client",
      AppProfile.admin => "$_baseEndpoint/admin",
    };
    final url = Uri.parse(endpoint);
    final response = await http.get(url);
    return response;
  }

  /// Retrieves all announcements and parses them into [AppAnnouncement] objects.
  ///
  /// Returns a [Future<List<AppAnnouncement>>] containing the parsed announcements.
  /// Returns an empty list if the request fails or if there are no announcements.
  Future<List<AppAnnouncement>> _getAnnouncementsList() async {
    try {
      final response = await _getAllAnnouncements();
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => AppAnnouncement.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Retrieves announcements that are currently active/visible.
  ///
  /// This method filters announcements based on conditional logic,
  /// including app version requirements and other criteria.
  Future<List<AppAnnouncement>> getActiveAnnouncements() async {
    final announcements = await _getAnnouncementsList();
    // Filter announcements based on conditional logic
    final filteredAnnouncements = await AnnouncementConditionService.filterConditionalAnnouncements(announcements);
    return filteredAnnouncements;
  }
}

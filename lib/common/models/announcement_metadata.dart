import 'package:flutter/foundation.dart';
import 'package:quber_taxi/common/models/encodable.dart';

@immutable
class AnnouncementMetadata implements Encodable {
  final String? appVersion;
  final bool conditionalAnnouncement;

  const AnnouncementMetadata({
    this.appVersion,
    this.conditionalAnnouncement = false,
  });

  @override
  Map<String, dynamic> toJson() => {
    "appVersion": appVersion,
    "conditionalAnnouncement": conditionalAnnouncement,
  };

  factory AnnouncementMetadata.fromJson(Map<String, dynamic> json) {
    return AnnouncementMetadata(
      appVersion: json["appVersion"],
      conditionalAnnouncement: json["conditionalAnnouncement"] ?? false,
    );
  }

  // Helper method to create from generic metadata map
  factory AnnouncementMetadata.fromMetadata(Map<String, dynamic>? metadata) {
    if (metadata == null) return const AnnouncementMetadata();
    return AnnouncementMetadata.fromJson(metadata);
  }
} 
import 'package:flutter/foundation.dart';
import 'package:quber_taxi/common/models/encodable.dart';

@immutable
class AnnouncementMetadata implements Encodable {
  final String? appVersion;
  final bool conditional;

  const AnnouncementMetadata({
    this.appVersion,
    this.conditional = false,
  });

  @override
  Map<String, dynamic> toJson() => {
    "appVersion": appVersion,
    "conditionalAnnouncement": conditional,
  };

  factory AnnouncementMetadata.fromJson(Map<String, dynamic> json) {
    return AnnouncementMetadata(
      appVersion: json["appVersion"],
      conditional: json["conditional"] ?? false,
    );
  }
} 
import 'package:flutter/foundation.dart';
import 'package:quber_taxi/common/models/encodable.dart';
import 'package:quber_taxi/enums/linkable_type.dart';

@immutable
class AppAnnouncement implements Encodable {
  final int id;
  final String title;
  final String? description;
  final String? imageUrl;
  final String? backgroundColor;
  final String? linkableText;
  final String? linkableUrl;
  final LinkableType linkableType;
  final bool isDismissible;
  final Map<String, dynamic>? metadata;

  const AppAnnouncement({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    this.backgroundColor,
    this.linkableText,
    this.linkableUrl,
    this.linkableType = LinkableType.NONE,
    this.isDismissible = false,
    this.metadata,
  });

  @override
  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "imageUrl": imageUrl,
    "backgroundColor": backgroundColor,
    "linkableText": linkableText,
    "linkableUrl": linkableUrl,
    "linkableType": linkableType.value,
    "isDismissible": isDismissible,
    "metadata": metadata,
  };

  factory AppAnnouncement.fromJson(Map<String, dynamic> json) {
    return AppAnnouncement(
      id: json["id"],
      title: json["title"],
      description: json["description"],
      imageUrl: json["imageUrl"],
      backgroundColor: json["backgroundColor"],
      linkableText: json["linkableText"],
      linkableUrl: json["linkableUrl"],
      linkableType: LinkableTypeExtension.fromString(json["linkableType"] ?? "NONE"),
      isDismissible: json["dismissible"] ?? false,
      metadata: json["metadata"] != null ? Map<String, dynamic>.from(json["metadata"]) : null,
    );
  }
} 
import 'package:flutter/foundation.dart';
import 'package:quber_taxi/common/models/encodable.dart';

@immutable
class Review implements Encodable{

  final int id;
  final String comment;
  final int rating;
  final DateTime timestamp;
  final ClientReview client;

  const Review({
    required this.id,
    required this.comment,
    required this.rating,
    required this.timestamp,
    required this.client,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
        id: json['id'],
        comment: json['comment'],
        rating: json['rating'],
        timestamp: (DateTime.parse(json['timestamp'])),
        client: ClientReview.fromJson(json['client'])
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    "id": id,
    "comment": comment,
    "rating": rating,
    "timestamp": timestamp.toIso8601String(),
    "client": client.toJson()
  };
}

@immutable
class ClientReview implements Encodable{

  final int id;
  final String name;
  final String imageUrl;

  const ClientReview({
    required this.id,
    required this.name,
    required this.imageUrl
  });

  factory ClientReview.fromJson(Map<String, dynamic> json) => ClientReview(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'] ?? ""
  );

  @override
  Map<String, dynamic> toJson() => {"id": id, "name": name, "imageUrl": imageUrl};
}
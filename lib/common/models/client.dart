import 'package:flutter/foundation.dart';

@immutable
class Client {

  final int id;
  final String name;
  final String phone;

  const Client({required this.id, required this.name, required this.phone});

  Map<String, dynamic> toJson() => {"id": id, "name": name, "phone": phone};

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(id: json["id"], name: json["name"], phone: json["phone"]);
  }
}
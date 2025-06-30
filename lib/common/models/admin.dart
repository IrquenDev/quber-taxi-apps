import 'package:flutter/foundation.dart';

@immutable
class Admin {

  final int id;
  final String name;
  final String phone;

  const Admin({required this.id, required this.name, required this.phone});

  Map<String, dynamic> toJson() => {"id": id, "name": name, "phone": phone};

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(id: json["id"], name: json["name"], phone: json["phone"]);
  }
}
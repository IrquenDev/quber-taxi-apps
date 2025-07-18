import 'package:flutter/foundation.dart';
import 'package:quber_taxi/common/models/encodable.dart';

@immutable
class Admin implements Encodable{

  final int id;
  final String name;
  final String phone;

  const Admin({required this.id, required this.name, required this.phone});

  @override
  Map<String, dynamic> toJson() => {"id": id, "name": name, "phone": phone};

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(id: json["id"], name: json["name"], phone: json["phone"]);
  }
}
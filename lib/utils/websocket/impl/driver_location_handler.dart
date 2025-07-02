import 'dart:convert';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:quber_taxi/utils/websocket/core/websocket_handler.dart';

class DriverLocationHandler extends WebSocketHandler<Position> {
  final int driverId;
  final void Function(Position coords) onLocation;

  DriverLocationHandler({
    required this.driverId,
    required this.onLocation,
  });

  @override
  String get topic => "/topic/drivers/$driverId/location";

  @override
  Position parseMessage(String raw) {
    final data = jsonDecode(raw);
    return Position(data["longitude"] as num, data["latitude"] as num);
  }

  @override
  void handleMessage(Position parsed) => onLocation(parsed);
}
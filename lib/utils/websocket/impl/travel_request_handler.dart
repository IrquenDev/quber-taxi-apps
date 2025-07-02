import 'dart:convert';
import 'package:quber_taxi/common/models/travel.dart';
import 'package:quber_taxi/utils/websocket/core/websocket_handler.dart';

class TravelRequestHandler extends WebSocketHandler<Travel> {
  final int driverId;
  final void Function(Travel coords) onNewTravel;

  TravelRequestHandler({
    required this.driverId,
    required this.onNewTravel,
  });

  @override
  String get topic => "/topic/new-travel-request/$driverId";

  @override
  Travel parseMessage(String raw) {
    final data = jsonDecode(raw);
    return Travel.fromJson(data);
  }

  @override
  void handleMessage(Travel parsed) => onNewTravel(parsed);
}
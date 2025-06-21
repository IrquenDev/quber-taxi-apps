import 'dart:convert';
import 'package:quber_taxi/common/models/travel.dart';
import 'package:quber_taxi/websocket/core/websocket_handler.dart';

/// A WebSocket handler that listens for when a travel's state change .
class TravelStateHandler extends WebSocketHandler <Travel> {

  final int travelId;
  final void Function(Travel travel) onMessage;

  TravelStateHandler({required this.travelId, required this.onMessage});

  @override
  String get topic => '/topic/travels/$travelId/state';

  @override
  void handleMessage(Travel parsed) => onMessage(parsed);

  @override
  parseMessage(String raw) => Travel.fromJson(jsonDecode(raw));
}
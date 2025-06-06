import 'dart:convert';

import 'package:quber_taxi/common/models/travel.dart';
import 'package:quber_taxi/config/api_config.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

late StompClient stompClient;

void connectToWebSocket(int travelId, void Function(Travel travel) onAccepted) {
  stompClient = StompClient(
    config: StompConfig.sockJS(
      url: '${ApiConfig().baseUrl}/ws',
      onConnect: (StompFrame frame) {
        stompClient.subscribe(
          destination: '/topic/travels/$travelId',
          callback: (frame) {
            print(jsonDecode(frame.body!));
            final travel = Travel.fromJson(jsonDecode(frame.body!));
            onAccepted(travel);
          }
        );
      },
      onWebSocketError: (dynamic error) => print('WebSocket Error: $error'),
    ),
  );

  stompClient.activate();
}

void disconnectSocket() {
  stompClient.deactivate();
}
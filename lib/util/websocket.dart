import 'dart:convert';

import 'package:quber_taxi/config/api_config.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

late StompClient stompClient;

void connectToWebSocket(int travelId, void Function(Map<String, dynamic>) onAccepted) {
  stompClient = StompClient(
    config: StompConfig.sockJS(
      url: '${ApiConfig().baseUrl}/ws',
      onConnect: (StompFrame frame) {
        stompClient.subscribe(
          destination: '/topic/travels/$travelId',
          callback: (frame) {
            final data = frame.body;
            if (data != null) {
              final travelMap = jsonDecode(data);
              if (travelMap['state'] == 'ACCEPTED') {
                onAccepted(travelMap);
              }
            }
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
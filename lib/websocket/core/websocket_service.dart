import 'dart:convert';
import 'package:stomp_dart_client/stomp_dart_client.dart';

/// A singleton service for managing WebSocket (STOMP over SockJS) connections.
///
/// Provides methods to connect, disconnect, subscribe to topics, unsubscribe,
/// and send messages. All topic subscriptions are tracked internally to allow
/// clean teardown and reconnection logic.
class WebSocketService {

  /// Singleton instance
  static final WebSocketService instance = WebSocketService._internal();

  /// Private constructor
  WebSocketService._internal();

  late StompClient _client;
  final Map<String, StompUnsubscribe> _subscriptions = {};
  final Map<String, void Function(String)> _pendingSubscriptions = {};
  bool _isConnected = false;

  /// Returns whether the WebSocket client is connected.
  bool get isConnected => _isConnected;

  /// Connects the WebSocket client to the backend.
  ///
  /// Should be called once, ideally at app startup. If already connected,
  /// this does nothing.
  void connect({required String baseUrl, String? authToken}) {
    if (_isConnected) return;

    _client = StompClient(
      config: StompConfig.sockJS(
        url: '$baseUrl/ws',
        onConnect: _onConnect,
        onWebSocketError: (error) {
          // Handles WebSocket connection errors
          print('WebSocket error: $error');
        },
        onStompError: (frame) {
          // Handles STOMP protocol-level errors
          print('STOMP error: ${frame.body}');
        },
        onDisconnect: (frame) {
          _isConnected = false;
          print('Disconnected from WebSocket.');
        },
        stompConnectHeaders: authToken != null
            ? {'Authorization': 'Bearer $authToken'}
            : {},
        webSocketConnectHeaders: authToken != null
            ? {'Authorization': 'Bearer $authToken'}
            : {},
        onWebSocketDone: () {
          // Fires when socket is closed (gracefully or by error)
          _isConnected = false;
          print('WebSocket connection closed.');
        },
        onDebugMessage: (msg) {
          // Useful during development to see protocol activity
          print('WS DEBUG: $msg');
        },
        heartbeatOutgoing: const Duration(seconds: 10),
        heartbeatIncoming: const Duration(seconds: 10),
      ),
    );

    _client.activate();
  }

  /// Disconnects from the WebSocket and clears all active subscriptions.
  void disconnect() {
    if (_isConnected) {
      _client.deactivate();
      _subscriptions.clear();
      _pendingSubscriptions.clear();
      _isConnected = false;
    }
  }

  /// Subscribes to a topic and handles incoming messages with the provided callback.
  ///
  /// If already subscribed to the topic, it will be replaced.
  void subscribe(String topic, void Function(String message) onMessage) {
    if (!_isConnected) {
      print('Attempted to subscribe while WebSocket is not connected.');
      _pendingSubscriptions[topic] = onMessage;
      return;
    }

    // If already subscribed, unsubscribe first
    if (_subscriptions.containsKey(topic)) {
      _subscriptions[topic]!();
    }

    final sub = _client.subscribe(
      destination: topic,
      callback: (frame) {
        if (frame.body != null) {
          onMessage(frame.body!);
        }
      },
    );

    _subscriptions[topic] = sub;
  }

  /// Unsubscribes from a specific topic.
  void unsubscribe(String topic) {
    if (_subscriptions.containsKey(topic)) {
      _subscriptions[topic]!(); // Call the unsubscribe function
      _subscriptions.remove(topic);
    }
  }

  /// Sends a message to a destination endpoint on the server.
  /// In our case (Spring API), the destination is composed of the app prefix ("/app") plus the mapped route of the
  /// endpoint (@MessageMapper) in the WebsocketDestinationMapperController.
  void send(String destination, dynamic body) {
    if (!_isConnected) {
      print('Attempted to send while WebSocket is not connected.');
      return;
    }
    final encoded = jsonEncode(body);
    _client.send(destination: destination, body: encoded);
  }

  /// Callback for when the STOMP client successfully connects.
  void _onConnect(StompFrame frame) {
    _isConnected = true;
    _handlePendingSubscriptions();
    print('WebSocket connected.');
    // Optionally re-subscribe to previous topics here (if needed in future)
  }

  void _handlePendingSubscriptions() {
    _pendingSubscriptions.forEach((topic,onMessage) => subscribe(topic, onMessage));
    _pendingSubscriptions.clear();
  }
}
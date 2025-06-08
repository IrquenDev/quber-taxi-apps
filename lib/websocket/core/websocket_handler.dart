import 'package:quber_taxi/websocket/core/websocket_service.dart';

/// A base class for WebSocket handlers that manage the lifecycle of a single topic subscription
/// and provide typed parsing and dispatching of messages.
///
/// Extend this class to implement specific WebSocket use cases. Override:
/// - `topic`: the destination string the handler listens to
/// - `parseMessage`: to convert the raw message to a concrete type
/// - `handleMessage`: to act upon the parsed message
abstract class WebSocketHandler<T> {

  /// Internal reference to the singleton WebSocket service.
  final websocketService = WebSocketService.instance;

  bool _isActive = false;

  /// Whether this handler is currently subscribed.
  bool get isActive => _isActive;

  /// The topic (destination) to which this handler subscribes.
  String get topic;

  /// Called when a message has been successfully parsed.
  void handleMessage(T parsed);

  /// Converts the raw message payload into the typed form [T].
  T parseMessage(String raw);

  // Internal method triggered when a message is received
  void _onMessage(String raw) {
    final parsed = parseMessage(raw);
    handleMessage(parsed);
  }

  /// Activates the handler by subscribing to the topic and wiring up the internal message pipeline.
  void activate() {
    if (_isActive) return;
    websocketService.subscribe(topic, _onMessage);
    _isActive = true;
  }

  /// Deactivates the handler by unsubscribing from the topic.
  void deactivate() {
    if (!_isActive) return;
    websocketService.unsubscribe(topic);
    _isActive = false;
  }
}
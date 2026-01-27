import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketService {
  WebSocketChannel? _channel;
  bool _isConnected = false;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  final int _maxReconnectAttempts = 5;
  final Duration _reconnectDelay = const Duration(seconds: 5);

  // Callbacks
  Function(dynamic message)? onMessageReceived;
  Function()? onConnected;
  Function(String error)? onError;
  Function()? onDisconnected;

  bool get isConnected => _isConnected;
  int get reconnectAttempts => _reconnectAttempts;

  Future<void> connect(String url) async {
    if (_isConnected) return;

    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));

      _channel?.stream.listen(
        (message) {
          _handleMessage(message);
        },
        onError: (error) {
          _handleError('WebSocket error: $error');
        },
        onDone: () {
          _handleDisconnect();
        },
      );

      _isConnected = true;
      _reconnectAttempts = 0;
      _reconnectTimer?.cancel();

      if (kDebugMode) {
        print('WebSocket connected to: $url');
      }

      onConnected?.call();
    } catch (e) {
      _handleError('Failed to connect WebSocket: $e');
      _scheduleReconnect(url);
    }
  }

  void _handleMessage(dynamic message) {
    try {
      final data = message is String ? jsonDecode(message) : message;
      if (kDebugMode) {
        print('WebSocket message received: $data');
      }
      onMessageReceived?.call(data);
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing WebSocket message: $e');
      }
      onError?.call('Error parsing message: $e');
    }
  }

  void _handleError(String error) {
    if (kDebugMode) {
      print('WebSocket error: $error');
    }
    _isConnected = false;
    onError?.call(error);
  }

  void _handleDisconnect() {
    if (kDebugMode) {
      print('WebSocket disconnected');
    }
    _isConnected = false;
    onDisconnected?.call();
  }

  void _scheduleReconnect(String url) {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      if (kDebugMode) {
        print('Max reconnect attempts reached. Giving up.');
      }
      return;
    }

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_reconnectDelay, () {
      _reconnectAttempts++;
      if (kDebugMode) {
        print(
          'Attempting to reconnect... ($_reconnectAttempts/$_maxReconnectAttempts)',
        );
      }
      connect(url);
    });
  }

  void sendMessage(dynamic message) {
    if (!_isConnected || _channel == null) {
      if (kDebugMode) {
        print('Cannot send message: WebSocket not connected');
      }
      return;
    }

    try {
      final jsonMessage = jsonEncode(message);
      _channel?.sink.add(jsonMessage);
      if (kDebugMode) {
        print('WebSocket message sent: $message');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending WebSocket message: $e');
      }
      onError?.call('Error sending message: $e');
    }
  }

  Future<void> disconnect() async {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _reconnectAttempts = 0;

    if (_channel != null) {
      await _channel?.sink.close(status.goingAway);
      _channel = null;
    }

    _isConnected = false;

    if (kDebugMode) {
      print('WebSocket disconnected');
    }

    onDisconnected?.call();
  }

  void dispose() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    disconnect();
  }
}

// Specific WebSocket service for call status updates
class CallWebSocketService extends WebSocketService {
  String? _callId;

  void connectForCall(String callId, String baseUrl) {
    _callId = callId;
    final url = '$baseUrl/ws/calls/$callId';
    connect(url);
  }

  void sendCallEvent(String eventType, {Map<String, dynamic>? data}) {
    final message = {
      'type': eventType,
      'callId': _callId,
      'timestamp': DateTime.now().toIso8601String(),
      if (data != null) ...data,
    };
    sendMessage(message);
  }

  void sendCallAccepted() => sendCallEvent('call_accepted');
  void sendCallRejected() => sendCallEvent('call_rejected');
  void sendCallEnded() => sendCallEvent('call_ended');
  void sendCallMissed() => sendCallEvent('call_missed');
}

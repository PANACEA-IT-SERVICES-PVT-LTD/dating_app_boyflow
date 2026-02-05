import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

enum CallState { idle, calling, connected, ended }

class CallCredentials {
  final String callId;
  final String channelName;
  final String agoraToken;
  final String receiverId;
  final String callType; // 'audio' or 'video'

  CallCredentials({
    required this.callId,
    required this.channelName,
    required this.agoraToken,
    required this.receiverId,
    required this.callType,
  });

  factory CallCredentials.fromJson(Map<String, dynamic> json) {
    return CallCredentials(
      callId: json['callId'] as String,
      channelName: json['channelName'] as String,
      agoraToken: json['agoraToken'] as String,
      receiverId: json['receiverId'] as String,
      callType: json['callType'] as String,
    );
  }
}

class CallController extends ChangeNotifier {
  CallState _state = CallState.idle;
  CallCredentials? _credentials;
  WebSocketChannel? _webSocketChannel;
  bool _isWebSocketConnected = false;
  Timer? _callTimer;
  int _callDuration = 0;
  String? _error;

  // Getters
  CallState get state => _state;
  CallCredentials? get credentials => _credentials;
  bool get isWebSocketConnected => _isWebSocketConnected;
  int get callDuration => _callDuration;
  String? get error => _error;
  bool get isCallActive =>
      _state == CallState.calling || _state == CallState.connected;

  // State transitions
  void _setState(CallState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  // Initialize outgoing call
  void startOutgoingCall(CallCredentials credentials) {
    _credentials = credentials;
    _setState(CallState.calling);
    _connectWebSocket();
    _startCallTimer();
  }

  // Call accepted by recipient
  void onCallAccepted() {
    _setState(CallState.connected);
  }

  // Call rejected or missed
  void onCallEnded({String? reason}) {
    _setState(CallState.ended);
    _cleanup();
    _error = reason;
    notifyListeners();
  }

  // User manually ends call
  void endCall() {
    _setState(CallState.ended);
    _cleanup();
  }

  // WebSocket connection management
  void _connectWebSocket() {
    try {
      // TODO: Replace with actual WebSocket URL from your backend
      final wsUrl = Uri.parse(
        'wss://your-backend.com/ws/calls/${_credentials?.callId}',
      );
      _webSocketChannel = WebSocketChannel.connect(wsUrl);

      _webSocketChannel?.stream.listen(
        (message) {
          _handleWebSocketMessage(message);
        },
        onError: (error) {
          if (kDebugMode) {
            print('WebSocket error: $error');
          }
          _isWebSocketConnected = false;
          notifyListeners();
        },
        onDone: () {
          _isWebSocketConnected = false;
          notifyListeners();
        },
      );

      _isWebSocketConnected = true;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to connect WebSocket: $e');
      }
      _isWebSocketConnected = false;
      notifyListeners();
    }
  }

  void _handleWebSocketMessage(dynamic message) {
    try {
      final data = message is String ? jsonDecode(message) : message;
      final eventType = data['type'] as String?;

      switch (eventType) {
        case 'call_accepted':
          onCallAccepted();
          break;
        case 'call_rejected':
          onCallEnded(reason: 'Call rejected by recipient');
          break;
        case 'call_missed':
          onCallEnded(reason: 'Call missed');
          break;
        case 'call_ended':
          onCallEnded(reason: 'Call ended by recipient');
          break;
        default:
          if (kDebugMode) {
            print('Unknown WebSocket event: $eventType');
          }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error handling WebSocket message: $e');
      }
    }
  }

  void _startCallTimer() {
    _callTimer?.cancel();
    _callDuration = 0;
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _callDuration++;
      notifyListeners();
    });
  }

  void _cleanup() {
    _callTimer?.cancel();
    _callTimer = null;
    _callDuration = 0;
    _closeWebSocket();
  }

  void _closeWebSocket() {
    if (_webSocketChannel != null) {
      _webSocketChannel?.sink.close(status.goingAway);
      _webSocketChannel = null;
      _isWebSocketConnected = false;
    }
  }

  // Reset controller to initial state
  void reset() {
    _cleanup();
    _state = CallState.idle;
    _credentials = null;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }
}

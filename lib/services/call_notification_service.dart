import 'dart:async';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../views/screens/incoming_call_screen.dart';

class CallNotificationService {
  static final CallNotificationService _instance =
      CallNotificationService._internal();
  factory CallNotificationService() => _instance;
  CallNotificationService._internal();

  StreamController<IncomingCallData>? _callStreamController;
  Stream<IncomingCallData>? _callStream;

  // Current active call data
  IncomingCallData? _currentCall;

  Stream<IncomingCallData> get callStream {
    _callStreamController ??= StreamController<IncomingCallData>();
    _callStream ??= _callStreamController!.stream.asBroadcastStream();
    return _callStream!;
  }

  // Simulate receiving an incoming call (in real app, this would come from WebSocket/push notification)
  void simulateIncomingCall({
    required String callerName,
    required String callerId,
    required String channelName,
    required int callerUid,
    required bool isVideoCall,
  }) {
    _currentCall = IncomingCallData(
      callerName: callerName,
      callerId: callerId,
      channelName: channelName,
      callerUid: callerUid,
      isVideoCall: isVideoCall,
    );

    _callStreamController?.add(_currentCall!);
  }

  // Accept the current call
  IncomingCallData? acceptCurrentCall() {
    final call = _currentCall;
    _currentCall = null;
    return call;
  }

  // Decline the current call
  void declineCurrentCall() {
    _currentCall = null;
  }

  // Check if there's an active incoming call
  bool get hasIncomingCall => _currentCall != null;
  IncomingCallData? get currentCall => _currentCall;
}

class IncomingCallData {
  final String callerName;
  final String callerId;
  final String channelName;
  final int callerUid;
  final bool isVideoCall;

  IncomingCallData({
    required this.callerName,
    required this.callerId,
    required this.channelName,
    required this.callerUid,
    required this.isVideoCall,
  });
}

// Widget to handle incoming call notifications
class CallNotificationHandler extends StatefulWidget {
  final Widget child;
  final Function(IncomingCallData) onCallAccepted;

  const CallNotificationHandler({
    Key? key,
    required this.child,
    required this.onCallAccepted,
  }) : super(key: key);

  @override
  State<CallNotificationHandler> createState() =>
      _CallNotificationHandlerState();
}

class _CallNotificationHandlerState extends State<CallNotificationHandler> {
  final _callService = CallNotificationService();
  IncomingCallData? _incomingCall;

  @override
  void initState() {
    super.initState();
    _callService.callStream.listen(_handleIncomingCall);
  }

  void _handleIncomingCall(IncomingCallData call) {
    setState(() {
      _incomingCall = call;
    });
  }

  void _acceptCall() {
    final call = _callService.acceptCurrentCall();
    if (call != null) {
      setState(() {
        _incomingCall = null;
      });
      widget.onCallAccepted(call);
    }
  }

  void _declineCall() {
    _callService.declineCurrentCall();
    setState(() {
      _incomingCall = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        // Incoming call overlay
        if (_incomingCall != null)
          Positioned.fill(
            child: IncomingCallScreen(
              callerName: _incomingCall!.callerName,
              callerId: _incomingCall!.callerId,
              channelName: _incomingCall!.channelName,
              callerUid: _incomingCall!.callerUid,
              isVideoCall: _incomingCall!.isVideoCall,
              onAccept: _acceptCall,
              onDecline: _declineCall,
            ),
          ),
      ],
    );
  }
}

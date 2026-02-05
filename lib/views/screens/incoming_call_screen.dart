import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'dart:async';
import 'dart:io' show Platform;

// Import the entities
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';

class IncomingCallScreen extends StatefulWidget {
  static const String routeName = '/incoming-call';

  final String callerName;
  final String callerAvatar;
  final String callType; // 'audio' or 'video'
  final String callId;

  const IncomingCallScreen({
    Key? key,
    required this.callerName,
    required this.callerAvatar,
    required this.callType,
    required this.callId,
  }) : super(key: key);

  @override
  _IncomingCallScreenState createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen> {
  bool _isDeclined = false;
  bool _isAnswered = false;

  @override
  void initState() {
    super.initState();

    // Show incoming call notification using callkit
    _showIncomingCallNotification();
  }

  void _showIncomingCallNotification() {
    final paramsMap = <String, dynamic>{
      'id': widget.callId,
      'nameCaller': widget.callerName,
      'appName': 'Boy Flow',
      'avatar': widget.callerAvatar,
      'handle': widget.callId,
      'type': widget.callType == 'video' ? 1 : 0, // 1 for video, 0 for voice
      'extra': {
        'channelName': 'call_${widget.callId}',
        'isVideoCall': widget.callType == 'video',
      },
      'android': {
        'isCustomNotification': true,
        'backgroundColor': '#E91EC7', // Using app's color
        'backgroundUrl': '',
        'isShowLogo': false,
        'logo': '',
        'isShowFullscreen': true,
        'ringtone': '', // Use default ringtone
      },
      'ios': {
        'iconName': 'AppIcon',
        'handleType': 'generic',
        'supportsVideo': widget.callType == 'video',
        'maximumCallGroups': 2,
        'maximumCallsPerCallGroup': 1,
        'supportsDTMF': true,
        'supportsHolding': false,
        'supportsGrouping': false,
        'supportsUngrouping': false,
        'ringtoneSound': 'system_ringtone_default',
      },
    };

    FlutterCallkitIncoming.showCallkitIncoming(
      CallKitParams.fromJson(paramsMap),
    );
  }

  void _answerCall() {
    setState(() {
      _isAnswered = true;
    });

    // Hide the incoming call notification
    FlutterCallkitIncoming.endAllCalls();

    // Navigate to call screen
    Navigator.pushReplacementNamed(
      context,
      '/call-screen', // Replace with your actual call screen route
      arguments: {
        'callerName': widget.callerName,
        'callType': widget.callType,
        'callId': widget.callId,
      },
    );
  }

  void _declineCall() {
    setState(() {
      _isDeclined = true;
    });

    // End the call in the system
    FlutterCallkitIncoming.endAllCalls();

    // Navigate back
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Caller avatar
              CircleAvatar(
                radius: 60,
                backgroundImage: widget.callerAvatar.startsWith('http')
                    ? NetworkImage(widget.callerAvatar) as ImageProvider
                    : const AssetImage('assets/default_avatar.png'),
                backgroundColor: Colors.grey[300],
                child: widget.callerAvatar.isEmpty
                    ? const Icon(Icons.person, size: 50, color: Colors.grey)
                    : null,
              ),

              const SizedBox(height: 30),

              // Caller name
              Text(
                widget.callerName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 10),

              // Call type
              Text(
                widget.callType == 'video' ? 'Video Call' : 'Audio Call',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),

              const SizedBox(height: 50),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Decline button
                  FloatingActionButton(
                    onPressed: _isAnswered || _isDeclined ? null : _declineCall,
                    backgroundColor: Colors.red,
                    child: const Icon(Icons.call_end, color: Colors.white),
                  ),

                  // Answer button
                  FloatingActionButton(
                    onPressed: _isAnswered || _isDeclined ? null : _answerCall,
                    backgroundColor: Colors.green,
                    child: widget.callType == 'video'
                        ? const Icon(Icons.videocam, color: Colors.white)
                        : const Icon(Icons.phone, color: Colors.white),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Status text
              Text(
                _isAnswered
                    ? 'Connecting...'
                    : _isDeclined
                    ? 'Call declined'
                    : 'Incoming ${widget.callType} call',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

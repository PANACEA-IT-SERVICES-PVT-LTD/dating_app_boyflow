import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/api_controller.dart';
import '../../models/call_state.dart';
import '../../services/call_manager.dart';
import '../screens/call_page.dart';

class OutgoingCallScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;
  final String channelName;
  final String callType; // 'audio' or 'video'
  final String callId;

  const OutgoingCallScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
    required this.channelName,
    required this.callType,
    required this.callId,
  });

  @override
  State<OutgoingCallScreen> createState() => _OutgoingCallScreenState();
}

class _OutgoingCallScreenState extends State<OutgoingCallScreen> {
  Timer? _callTimer;
  Timer? _timeoutTimer;
  int _elapsedSeconds = 0;
  bool _callEnded = false;
  bool _isCallCanceled = false;
  String _callStatus =
      'calling'; // 'calling', 'connected', 'rejected', 'missed', 'ended'

  @override
  void initState() {
    super.initState();
    // Set call state to outgoing when screen initializes
    final callManager = CallManager();
    callManager.setState(CallState.outgoing, callId: widget.callId);
    _startCallTimer();
    _listenForCallUpdates();
  }

  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_callEnded) {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });
  }

  void _listenForCallUpdates() {
    // Start polling for call status updates
    _pollCallStatus();

    // Set up timeout timer (30 seconds)
    _setupTimeout();
  }

  void _setupTimeout() {
    _timeoutTimer = Timer(const Duration(seconds: 30), () {
      if (!_callEnded && !_isCallCanceled && _callStatus == 'calling') {
        _handleTimeout();
      }
    });
  }

  void _handleTimeout() {
    if (_callEnded || _isCallCanceled) return;

    // End the call session on timeout
    _endCallSession();

    // Update UI
    setState(() {
      _callStatus = 'missed';
    });

    // Show timeout message
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No response, call ended')));

      // Navigate back after a delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    }
  }

  void _pollCallStatus() async {
    while (!_callEnded && _callStatus == 'calling') {
      await Future.delayed(const Duration(seconds: 2)); // Poll every 2 seconds

      if (_callEnded) break;

      try {
        final apiController = Provider.of<ApiController>(
          context,
          listen: false,
        );
        final response = await apiController.checkCallStatus(
          callId: widget.callId,
        );

        if (response['success'] == true && response['data'] != null) {
          final status = response['data']['status']?.toString() ?? 'unknown';

          if (status == 'accepted') {
            _handleCallAccepted(response['data']);
            break;
          } else if (status == 'rejected' ||
              status == 'missed' ||
              status == 'cancelled') {
            _handleCallRejected(status);
            break;
          } else if (status == 'ongoing') {
            // Continue waiting
            continue;
          }
        }
      } catch (e) {
        // Handle error - could be network issue
        print('Error polling call status: $e');
        // Continue polling
      }
    }
  }

  void _handleCallAccepted(Map<String, dynamic> data) {
    // Update call manager state
    final callManager = CallManager();
    callManager.setState(CallState.connected, callId: widget.callId);

    setState(() {
      _callStatus = 'connected';
    });

    // Navigate to actual call screen after acceptance
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => CallPage(
              channelName: widget.channelName,
              enableVideo: widget.callType == 'video',
              isInitiator: true,
            ),
          ),
        );
      }
    });
  }

  void _handleCallRejected(String status) {
    // Update call manager state
    final callManager = CallManager();
    callManager.setState(CallState.ended, callId: widget.callId);

    setState(() {
      _callStatus = status;
    });

    // Show message and return to previous screen after delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  void _endCall() {
    if (_callEnded || _isCallCanceled) return;
    _isCallCanceled = true;
    _callEnded = true;
    _callTimer?.cancel();
    _timeoutTimer?.cancel();

    // End the call session
    _endCallSession();
  }

  void _endCallSession() async {
    // In real implementation, call /calls/end API
    try {
      final apiController = Provider.of<ApiController>(context, listen: false);
      await apiController.endCall(
        receiverId: widget.receiverId,
        duration: _elapsedSeconds,
        callType: widget.callType,
        callId: widget.callId,
      );
    } catch (e) {
      print('Error ending call: $e');
    }
  }

  void _navigateBack() {
    if (mounted) {
      Navigator.pop(context);
    }
  }

  String _formatTime(int seconds) {
    final minutes = (seconds / 60).floor();
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Receiver profile image/avatar
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.grey[300],
                  child: Icon(
                    widget.callType == 'video'
                        ? Icons.videocam
                        : Icons.phone_callback,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Receiver name
              Text(
                widget.receiverName,
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              // Call status
              Text(
                _getStatusText(),
                style: const TextStyle(fontSize: 18, color: Colors.white70),
              ),
              const SizedBox(height: 10),

              // Elapsed time
              Text(
                _formatTime(_elapsedSeconds),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 50),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // End call button
                  GestureDetector(
                    onTap: _endCall,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      child: const Icon(
                        Icons.call_end,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Hint text
              if (_callStatus == 'calling')
                const Text(
                  'Waiting for response...',
                  style: TextStyle(fontSize: 14, color: Colors.white30),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusText() {
    switch (_callStatus) {
      case 'calling':
        return 'Calling...';
      case 'connected':
        return 'Connected';
      case 'rejected':
        return 'Rejected';
      case 'missed':
        return 'Missed';
      case 'ended':
        return 'Call Ended';
      default:
        return 'Calling...';
    }
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    _timeoutTimer?.cancel();
    // Reset call manager state if the call wasn't connected
    if (!_callEnded && _callStatus != 'connected') {
      final callManager = CallManager();
      callManager.reset();
    }
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Boy_flow/controllers/call_controller.dart';
import 'package:Boy_flow/services/agora_service.dart';
import 'package:Boy_flow/views/screens/incall_screen.dart';

class OutgoingCallScreen extends StatefulWidget {
  final String receiverName;
  final String receiverImage;
  final String callType; // 'audio' or 'video'
  final CallCredentials credentials;

  const OutgoingCallScreen({
    Key? key,
    required this.receiverName,
    required this.receiverImage,
    required this.callType,
    required this.credentials,
  }) : super(key: key);

  @override
  State<OutgoingCallScreen> createState() => _OutgoingCallScreenState();
}

class _OutgoingCallScreenState extends State<OutgoingCallScreen> {
  late CallController _callController;
  late AgoraService _agoraService;
  bool _isConnecting = true;

  @override
  void initState() {
    super.initState();
    _callController = Provider.of<CallController>(context, listen: false);
    _agoraService = AgoraService();

    _initializeCall();
  }

  Future<void> _initializeCall() async {
    try {
      // Start the outgoing call in controller
      _callController.startOutgoingCall(widget.credentials);

      // Initialize Agora service
      await _agoraService.initialize();

      // Set up Agora callbacks
      _agoraService.onJoinChannelSuccess = () {
        setState(() {
          _isConnecting = false;
        });
      };

      _agoraService.onError = (error) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Call error: $error')));
          _endCall();
        }
      };

      _agoraService.onUserJoined = (uid) {
        // Remote user joined, navigate to in-call screen
        if (mounted) {
          _navigateToInCallScreen();
        }
      };

      // Start preview for video calls
      if (widget.callType == 'video') {
        await _agoraService.startPreview();
      }

      // Join Agora channel
      await _agoraService.joinChannel(
        channelName: widget.credentials.channelName,
        token: widget.credentials.agoraToken,
        uid: 0, // Local user ID
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize call: $e')),
        );
        _endCall();
      }
    }
  }

  void _navigateToInCallScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => InCallScreen(
          receiverName: widget.receiverName,
          receiverImage: widget.receiverImage,
          callType: widget.callType,
          credentials: widget.credentials,
        ),
      ),
    );
  }

  void _cancelCall() {
    _endCall();
    Navigator.pop(context);
  }

  void _endCall() {
    _callController.endCall();
    _agoraService.dispose();
  }

  @override
  void dispose() {
    _endCall();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<CallController>(
        builder: (context, callController, child) {
          return Stack(
            children: [
              // Background with blur effect
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: widget.receiverImage.startsWith('http')
                        ? NetworkImage(widget.receiverImage)
                        : AssetImage(widget.receiverImage) as ImageProvider,
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.6),
                      BlendMode.darken,
                    ),
                  ),
                ),
              ),

              // Main content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Profile image
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 4,
                        ),
                        image: DecorationImage(
                          image: widget.receiverImage.startsWith('http')
                              ? NetworkImage(widget.receiverImage)
                              : AssetImage(widget.receiverImage)
                                    as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: _isConnecting
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            )
                          : null,
                    ),

                    const SizedBox(height: 30),

                    // Receiver name
                    Text(
                      widget.receiverName,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Call status
                    Text(
                      _getStatusText(callController.state),
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Call type indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.callType == 'video'
                                ? Icons.videocam
                                : Icons.call,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.callType == 'video'
                                ? 'Video Call'
                                : 'Audio Call',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Call timer
                    if (callController.callDuration > 0)
                      Text(
                        _formatDuration(callController.callDuration),
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),

              // Bottom controls
              Positioned(
                bottom: 50,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Cancel call button
                    Container(
                      width: 70,
                      height: 70,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.call_end,
                          color: Colors.white,
                          size: 30,
                        ),
                        onPressed: _cancelCall,
                      ),
                    ),
                  ],
                ),
              ),

              // Connection status indicator
              if (_isConnecting)
                const Positioned(
                  top: 50,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      'Connecting...',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  String _getStatusText(CallState state) {
    switch (state) {
      case CallState.calling:
        return 'Calling...';
      case CallState.connected:
        return 'Connected';
      case CallState.ended:
        return 'Call Ended';
      case CallState.idle:
        return '';
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

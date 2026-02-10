import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../agora_config.dart';

class IncomingCallScreen extends StatefulWidget {
  final String callerName;
  final String callerId;
  final String channelName;
  final int callerUid;
  final bool isVideoCall;
  final Function onAccept;
  final Function onDecline;

  const IncomingCallScreen({
    Key? key,
    required this.callerName,
    required this.callerId,
    required this.channelName,
    required this.callerUid,
    required this.isVideoCall,
    required this.onAccept,
    required this.onDecline,
  }) : super(key: key);

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _ringAnimation;
  bool _isRinging = true;

  @override
  void initState() {
    super.initState();
    _initAnimation();
    // Simulate ringing with vibration pattern
    _simulateRinging();
  }

  void _initAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _ringAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  void _simulateRinging() {
    // In a real app, you'd trigger device vibration here
    // For now, we'll just use the visual animation
  }

  void _stopRinging() {
    _isRinging = false;
    _animationController.stop();
  }

  @override
  void dispose() {
    _stopRinging();
    _animationController.dispose();
    super.dispose();
  }

  void _acceptCall() {
    _stopRinging();
    widget.onAccept();
  }

  void _declineCall() {
    _stopRinging();
    widget.onDecline();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  widget.isVideoCall
                      ? Colors.blue.shade900
                      : Colors.green.shade900,
                  Colors.black,
                ],
              ),
            ),
          ),

          // Animated caller info
          Center(
            child: ScaleTransition(
              scale: _ringAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Caller avatar
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                      border: Border.all(
                        color: _isRinging
                            ? (widget.isVideoCall ? Colors.blue : Colors.green)
                            : Colors.white,
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      widget.isVideoCall ? Icons.videocam : Icons.phone,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Caller name
                  Text(
                    widget.callerName,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Call type indicator
                  Text(
                    widget.isVideoCall ? 'Video Call' : 'Audio Call',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 50),

                  // Ringing indicator
                  if (_isRinging)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        3,
                        (index) => AnimatedContainer(
                          duration: Duration(milliseconds: 300 + (index * 100)),
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Call controls at bottom
          Positioned(
            bottom: 80,
            left: 30,
            right: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Decline button (red)
                Column(
                  children: [
                    FloatingActionButton(
                      onPressed: _declineCall,
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      heroTag: "decline",
                      child: const Icon(Icons.call_end, size: 30),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Decline',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),

                // Accept button (green/blue)
                Column(
                  children: [
                    FloatingActionButton(
                      onPressed: _acceptCall,
                      backgroundColor: widget.isVideoCall
                          ? Colors.blue
                          : Colors.green,
                      foregroundColor: Colors.white,
                      heroTag: "accept",
                      child: Icon(
                        widget.isVideoCall ? Icons.videocam : Icons.phone,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Accept',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Status bar
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.isVideoCall ? Icons.videocam : Icons.phone,
                  color: Colors.white.withOpacity(0.7),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Incoming ${widget.isVideoCall ? 'Video' : 'Audio'} Call',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

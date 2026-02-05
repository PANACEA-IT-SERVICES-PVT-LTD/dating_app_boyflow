import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:Boy_flow/controllers/call_controller.dart';
import 'package:Boy_flow/services/agora_service.dart';

class InCallScreen extends StatefulWidget {
  final String receiverName;
  final String receiverImage;
  final String callType; // 'audio' or 'video'
  final CallCredentials credentials;

  const InCallScreen({
    Key? key,
    required this.receiverName,
    required this.receiverImage,
    required this.callType,
    required this.credentials,
  }) : super(key: key);

  @override
  State<InCallScreen> createState() => _InCallScreenState();
}

class _InCallScreenState extends State<InCallScreen> {
  late CallController _callController;
  late AgoraService _agoraService;
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  bool _isSpeakerOn = false;
  bool _showControls = true;
  late Future<void> _initializeFuture;

  @override
  void initState() {
    super.initState();
    _callController = Provider.of<CallController>(context, listen: false);
    _agoraService = AgoraService();

    _initializeFuture = _initializeCall();

    // Auto-hide controls after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  Future<void> _initializeCall() async {
    try {
      // Set up Agora callbacks
      _agoraService.onUserOffline = (uid) {
        if (mounted) {
          _endCall();
        }
      };

      _agoraService.onError = (error) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Call error: $error')));
          _endCall();
        }
      };

      // Call is already joined in outgoing call screen, just set the controller state
      _callController.onCallAccepted();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize call: $e')),
        );
        _endCall();
      }
    }
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    _agoraService.toggleMute();
  }

  void _toggleVideo() {
    setState(() {
      _isVideoEnabled = !_isVideoEnabled;
    });
    _agoraService.toggleVideo();
  }

  void _switchCamera() {
    _agoraService.switchCamera();
  }

  void _toggleSpeaker() {
    setState(() {
      _isSpeakerOn = !_isSpeakerOn;
    });
    // TODO: Implement speaker toggle logic
  }

  void _endCall() {
    _callController.endCall();
    _agoraService.dispose();
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _agoraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 60),
                  const SizedBox(height: 20),
                  Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _endCall,
                    child: const Text('End Call'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // Remote video view
              if (widget.callType == 'video' && _agoraService.isJoined)
                _agoraService.remoteUid != null
                    ? AgoraVideoView(
                        controller: VideoViewController(
                          rtcEngine: _agoraService.engine!,
                          canvas: VideoCanvas(uid: _agoraService.remoteUid!),
                        ),
                      )
                    : Container(
                        color: Colors.grey[900],
                        child: const Center(
                          child: Text(
                            'Waiting for video...',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      )
              else
                // For audio calls or no video, show profile image
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: widget.receiverImage.startsWith('http')
                          ? NetworkImage(widget.receiverImage)
                          : AssetImage(widget.receiverImage) as ImageProvider,
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.3),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.person, size: 100, color: Colors.white70),
                  ),
                ),

              // Local video preview (picture-in-picture)
              if (widget.callType == 'video' && _isVideoEnabled)
                Positioned(
                  top: 50,
                  right: 20,
                  child: Container(
                    width: 120,
                    height: 160,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _agoraService.isJoined
                        ? AgoraVideoView(
                            controller: VideoViewController(
                              rtcEngine: _agoraService.engine!,
                              canvas: const VideoCanvas(uid: 0),
                            ),
                          )
                        : Container(
                            color: Colors.grey[800],
                            child: const Icon(
                              Icons.videocam_off,
                              color: Colors.white70,
                            ),
                          ),
                  ),
                ),

              // Top information bar
              if (_showControls)
                Positioned(
                  top: 50,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Call duration
                        Text(
                          _formatDuration(_callController.callDuration),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        // Call type indicator
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
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
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                widget.callType == 'video' ? 'Video' : 'Audio',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Signal strength indicator
                        Row(
                          children: [
                            Icon(
                              Icons.signal_cellular_alt,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'Good',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

              // Receiver name and info
              Positioned(
                top: 100,
                left: 0,
                right: 0,
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        widget.receiverName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Connected',
                        style: TextStyle(color: Colors.green, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom controls
              if (_showControls)
                Positioned(
                  bottom: 50,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Mute button
                        _buildControlButton(
                          icon: _isMuted ? Icons.mic_off : Icons.mic,
                          color: _isMuted ? Colors.red : Colors.white70,
                          onPressed: _toggleMute,
                        ),

                        // Video toggle (video calls only)
                        if (widget.callType == 'video')
                          _buildControlButton(
                            icon: _isVideoEnabled
                                ? Icons.videocam
                                : Icons.videocam_off,
                            color: _isVideoEnabled
                                ? Colors.white70
                                : Colors.red,
                            onPressed: _toggleVideo,
                          ),

                        // Switch camera (video calls only)
                        if (widget.callType == 'video' && _isVideoEnabled)
                          _buildControlButton(
                            icon: Icons.cameraswitch,
                            color: Colors.white70,
                            onPressed: _switchCamera,
                          ),

                        // Speaker toggle
                        _buildControlButton(
                          icon: _isSpeakerOn
                              ? Icons.volume_up
                              : Icons.volume_down,
                          color: _isSpeakerOn ? Colors.blue : Colors.white70,
                          onPressed: _toggleSpeaker,
                        ),

                        // End call button
                        _buildControlButton(
                          icon: Icons.call_end,
                          color: Colors.red,
                          size: 35,
                          onPressed: _endCall,
                        ),
                      ],
                    ),
                  ),
                ),

              // Tap to show controls
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showControls = !_showControls;
                  });
                  if (_showControls) {
                    // Auto-hide after 3 seconds
                    Future.delayed(const Duration(seconds: 3), () {
                      if (mounted) {
                        setState(() {
                          _showControls = false;
                        });
                      }
                    });
                  }
                },
                child: Container(color: Colors.transparent),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    double size = 25,
  }) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: size),
        onPressed: onPressed,
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

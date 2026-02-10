import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../agora_config.dart';

class CallScreen extends StatefulWidget {
  final String channelName;
  final String callType; // 'audio' or 'video'
  final String receiverName;

  const CallScreen({
    Key? key,
    required this.channelName,
    required this.callType,
    required this.receiverName,
  }) : super(key: key);

  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  bool _isMuted = false;
  late final RtcEngine _engine;
  bool _joined = false;
  int? remoteUid;
  bool _isCameraOff = false;

  @override
  void initState() {
    super.initState();
    initAgora();
    _simulateConnection();
  }

  @override
  void dispose() {
    _engine.release();
    super.dispose();
  }

  Future<void> initAgora() async {
    // Request permissions
    await [Permission.camera, Permission.microphone].request();

    // Create and initialize engine
    _engine = createAgoraRtcEngine();
    await _engine.initialize(
      RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );

    // Set client role
    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

    // Enable media based on call type
    if (widget.callType == 'video') {
      await _engine.enableVideo();
      await _engine.startPreview();
    } else {
      await _engine.enableAudio();
    }

    // Register event handlers
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          print("SUCCESS: JOINED CHANNEL ${connection.channelId}");
          setState(() => _joined = true);
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          print("SUCCESS: REMOTE USER $remoteUid JOINED");
          setState(() => this.remoteUid = remoteUid);
        },
        onUserOffline: (connection, remoteUid, reason) {
          print("INFO: USER $remoteUid LEFT");
          setState(() => this.remoteUid = null);
        },
        onError: (err, msg) {
          print("ERROR: AGORA ERROR $err: $msg");
        },
      ),
    );

    // Join the channel
    await _engine.joinChannel(
      token: "",
      channelId: widget.channelName,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  Future<void> _simulateConnection() async {
    // Simulate call connection process
    await Future.delayed(const Duration(seconds: 1));
    // Connection state is now handled by Agora events
  }

  Future<void> _toggleMute() async {
    if (mounted) {
      setState(() {
        _isMuted = !_isMuted;
      });
      _engine.muteLocalAudioStream(_isMuted);
    }
  }

  Future<void> _toggleCamera() async {
    if (mounted) {
      setState(() {
        _isCameraOff = !_isCameraOff;
      });
      _engine.muteLocalVideoStream(_isCameraOff);
    }
  }

  Future<void> _endCall() async {
    if (mounted) {
      await _engine.leaveChannel();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main video area
          Stack(
            children: [
              // Remote video (main view)
              if (_joined && remoteUid != null)
                AgoraVideoView(
                  controller: VideoViewController.remote(
                    rtcEngine: _engine,
                    canvas: VideoCanvas(uid: remoteUid!),
                    connection: RtcConnection(channelId: widget.channelName),
                  ),
                )
              else
                Container(
                  color: Colors.black,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.callType == 'video' ? Icons.videocam : Icons.phone,
                          size: 80,
                          color: Colors.white38,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _joined
                              ? (remoteUid != null
                                  ? 'Call Connected with ${widget.receiverName}'
                                  : 'Waiting for ${widget.receiverName} to join...')
                              : 'Connecting to ${widget.channelName}...',
                          style: TextStyle(
                            fontSize: 18,
                            color: _joined && remoteUid != null 
                                ? Colors.green 
                                : Colors.white70,
                            fontWeight: _joined && remoteUid != null 
                                ? FontWeight.bold 
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Local video preview (small)
              if (_joined && widget.callType == 'video')
                Positioned(
                  top: 50,
                  right: 20,
                  child: Container(
                    width: 100,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.black26,
                    ),
                    child: _isCameraOff
                        ? const Center(
                            child: Icon(
                              Icons.videocam_off,
                              color: Colors.white70,
                              size: 40,
                            ),
                          )
                        : AgoraVideoView(
                            controller: VideoViewController(
                              rtcEngine: _engine,
                              canvas: const VideoCanvas(uid: 0),
                            ),
                          ),
                  ),
                ),
            ],
          ),

          // Top info bar
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
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
                  Text(
                    _joined 
                        ? (remoteUid != null 
                            ? '${widget.callType.toUpperCase()} CALL CONNECTED' 
                            : '${widget.callType.toUpperCase()} CALL CONNECTING...')
                        : '${widget.callType.toUpperCase()} CALL INITIATING...',
                    style: TextStyle(
                      color: _joined && remoteUid != null 
                          ? Colors.green 
                          : Colors.white70,
                      fontSize: 16,
                      fontWeight: _joined && remoteUid != null 
                          ? FontWeight.bold 
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom control panel
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Mute button
                GestureDetector(
                  onTap: _toggleMute,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isMuted ? Icons.mic_off : Icons.mic,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),

                // End call button
                GestureDetector(
                  onTap: _endCall,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.call_end,
                      color: Colors.white,
                      size: 35,
                    ),
                  ),
                ),

                // Camera toggle (for video calls)
                if (widget.callType == 'video')
                  GestureDetector(
                    onTap: _toggleCamera,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: _isCameraOff ? Colors.red : Colors.grey[700],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isCameraOff ? Icons.videocam_off : Icons.videocam,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  )
                else
                  // Speaker toggle (for audio calls)
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[700],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.volume_up,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Connecting indicator
          Positioned(
            bottom: 150,
            left: 0,
            right: 0,
            child: const LinearProgressIndicator(
              backgroundColor: Colors.grey,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ),
        ],
      ),
    );
  }
}
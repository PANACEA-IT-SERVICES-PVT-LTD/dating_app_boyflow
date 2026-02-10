import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'agora_config.dart';
import 'services/boy_app_agora_manager.dart';

class AgoraVideoCallScreen extends StatefulWidget {
  final String channelName;
  final int uid;
  final bool isCaller;
  final int remoteUserId;
  final String remoteUserName;
  final bool isVideoCall;

  const AgoraVideoCallScreen({
    Key? key,
    this.channelName = 'friends_call_123',
    this.uid = boyAppUid, // Fixed unique UID for boy app
    this.isCaller = true,
    required this.remoteUserId,
    required this.remoteUserName,
    this.isVideoCall = true,
  }) : super(key: key);

  @override
  State<AgoraVideoCallScreen> createState() => _AgoraVideoCallScreenState();
}

class _AgoraVideoCallScreenState extends State<AgoraVideoCallScreen> {
  final _agoraManager = BoyAppAgoraManager();
  int? remoteUid;
  bool _joined = false;
  bool _isMuted = false;
  bool _isCameraOff = false;

  RtcEngine get _engine => _agoraManager.engine!;

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  @override
  void dispose() {
    // Don't release the engine here since it's shared
    // The engine will be managed by the BoyAppAgoraManager
    super.dispose();
  }

  Future<void> initAgora() async {
    // Request permissions
    await [Permission.camera, Permission.microphone].request();

    // Initialize the shared Agora engine
    await _agoraManager.initialize();

    // Set client role to broadcaster (caller)
    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

    // Enable media based on call type
    if (widget.isVideoCall) {
      await _agoraManager.prepareVideo();
    } else {
      await _engine.enableAudio();
      // For audio calls, we still need to enable video but mute it immediately
      await _engine.enableVideo();
      await _engine.muteLocalVideoStream(true);
    }

    // Register event handlers
    _agoraManager.setupEventHandlers(
      onJoinChannelSuccess: (connection, elapsed) {
        print(
          "BOY APP: SUCCESSFULLY JOINED CHANNEL ${connection.channelId} as UID ${connection.localUid}",
        );
        if (mounted) {
          setState(() => _joined = true);
        }
      },
      onUserJoined: (connection, remoteUid, elapsed) {
        print(
          "BOY APP: REMOTE USER $remoteUid JOINED CHANNEL ${connection.channelId}",
        );
        setState(() => this.remoteUid = remoteUid);
      },
      onUserOffline: (connection, remoteUid, reason) {
        print("BOY APP: USER $remoteUid LEFT CHANNEL ${connection.channelId}");
        setState(() => this.remoteUid = null);
      },
      onError: (err, msg) {
        print("BOY APP: AGORA ERROR $err: $msg");
      },
    );

    // Wait a moment for event handlers to register, then join
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) {
        joinCall();
      }
    });
  }

  Future<void> joinCall() async {
    print(
      "Boy App: Joining channel ${widget.channelName} with UID ${widget.uid}",
    );
    try {
      await _agoraManager.joinChannel(widget.channelName, uid: widget.uid);
      print("Boy App: Join channel request sent");
    } catch (e) {
      print("Boy App: Error joining channel: $e");
    }
  }

  Future<void> leaveCall() async {
    await _agoraManager.leaveChannel();
    setState(() {
      _joined = false;
      remoteUid = null;
    });
  }

  void toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    _engine.muteLocalAudioStream(_isMuted);
  }

  void toggleCamera() {
    setState(() {
      _isCameraOff = !_isCameraOff;
    });
    _engine.muteLocalVideoStream(_isCameraOff);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _joined
              ? (remoteUid != null
                    ? '${widget.isVideoCall ? 'Video' : 'Audio'} Call Connected'
                    : '${widget.isVideoCall ? 'Video' : 'Audio'} Call Connecting...')
              : '${widget.isVideoCall ? 'Video' : 'Audio'} Call Starting...',
        ),
        backgroundColor: widget.isVideoCall ? Colors.blue : Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Remote video (receiver) - show black screen when no remote user
          Container(
            color: Colors.black,
            child: _joined && remoteUid != null
                ? AgoraVideoView(
                    controller: VideoViewController.remote(
                      rtcEngine: _engine,
                      canvas: VideoCanvas(uid: remoteUid!),
                      connection: RtcConnection(channelId: widget.channelName),
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.isVideoCall ? Icons.videocam : Icons.phone,
                          size: 80,
                          color: Colors.white38,
                        ),
                        SizedBox(height: 20),
                        Text(
                          _joined
                              ? 'Waiting for ${widget.remoteUserName}...'
                              : 'Join call to start',
                          style: TextStyle(fontSize: 18, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
          ),

          // Local video preview (for both video and audio calls)
          if (_joined && widget.isVideoCall)
            Align(
              alignment: Alignment.topRight,
              child: Container(
                width: 120,
                height: 160,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.black26, // Background when no camera
                ),
                child: _isCameraOff
                    ? Center(
                        child: Icon(
                          Icons.videocam_off,
                          color: Colors.white70,
                          size: 40,
                        ),
                      )
                    : AgoraVideoView(
                        controller: VideoViewController(
                          rtcEngine: _engine,
                          canvas: const VideoCanvas(uid: boyAppUid),
                        ),
                      ),
              ),
            ),

          // Waiting for remote user state
          if (_joined && remoteUid == null)
            Container(
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.phone_callback, size: 80, color: Colors.white),
                    SizedBox(height: 20),
                    Text(
                      remoteUid != null ? 'Call Connected' : 'In Call',
                      style: TextStyle(
                        fontSize: 20,
                        color: remoteUid != null ? Colors.green : Colors.white,
                        fontWeight: remoteUid != null
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      remoteUid != null
                          ? 'Connected with ${widget.remoteUserName}'
                          : 'Waiting for ${widget.remoteUserName} to join...',
                      style: TextStyle(
                        fontSize: 16,
                        color: remoteUid != null ? Colors.green : Colors.grey,
                        fontWeight: remoteUid != null
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Call controls overlay
          if (_joined)
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton(
                    onPressed: toggleMute,
                    backgroundColor: _isMuted ? Colors.red : Colors.white,
                    child: Icon(
                      _isMuted ? Icons.mic_off : Icons.mic,
                      color: _isMuted ? Colors.white : Colors.black,
                    ),
                  ),
                  FloatingActionButton(
                    onPressed: leaveCall,
                    backgroundColor: Colors.red,
                    child: const Icon(Icons.call_end, color: Colors.white),
                  ),
                  if (widget.isVideoCall)
                    FloatingActionButton(
                      onPressed: () {
                        if (widget.isVideoCall) {
                          toggleCamera();
                        }
                      },
                      backgroundColor: _isCameraOff
                          ? Colors.red
                          : (widget.isVideoCall ? Colors.white : Colors.grey),
                      child: Icon(
                        _isCameraOff ? Icons.videocam_off : Icons.videocam,
                        color: _isCameraOff ? Colors.white : Colors.black,
                      ),
                    ),
                ],
              ),
            ),

          // Join call button (hidden since we auto-join)
          // if (!_joined)
          //   Center(
          //     child: ElevatedButton(
          //       onPressed: joinCall,
          //       style: ElevatedButton.styleFrom(
          //         backgroundColor: Colors.blue,
          //         foregroundColor: Colors.white,
          //         padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          //       ),
          //       child: Text('Start Call', style: TextStyle(fontSize: 18)),
          //     ),
          //   ),
        ],
      ),
    );
  }
}

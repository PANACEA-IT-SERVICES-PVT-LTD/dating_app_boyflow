import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../agora_config.dart'; // Import the config file
import '../../services/call_notification_service.dart';
import '../../services/female_app_agora_manager.dart';

class FemaleAppCallScreen extends StatefulWidget {
  final String channelName;
  final int uid;

  const FemaleAppCallScreen({
    Key? key,
    this.channelName = 'friends_call_123',
    this.uid = femaleAppUid, // Use female app UID from config
  }) : super(key: key);

  @override
  State<FemaleAppCallScreen> createState() => _FemaleAppCallScreenState();
}

class _FemaleAppCallScreenState extends State<FemaleAppCallScreen> {
  final _agoraManager = FemaleAppAgoraManager();
  int? remoteUid; // Track remote user ID
  bool _joined = false;
  bool _isMuted = false;
  bool _isCameraOff = false;

  // Controllers for input fields
  final TextEditingController _channelController = TextEditingController();
  final TextEditingController _uidController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with widget values
    _channelController.text = widget.channelName;
    _uidController.text = widget.uid.toString();
    initAgora();
    // Listen for incoming calls
    CallNotificationService().callStream.listen(_handleIncomingCall);
  }

  @override
  void dispose() {
    _agoraManager.release(); // Use agora manager to release
    _channelController.dispose();
    _uidController.dispose();
    super.dispose();
  }

  Future<void> initAgora() async {
    await [Permission.camera, Permission.microphone].request();

    // Initialize the shared Agora engine
    await _agoraManager.initialize();

    // Set client role to broadcaster (can send/receive media)
    await _agoraManager.engine!.setClientRole(
      role: ClientRoleType.clientRoleBroadcaster,
    );

    // Enable media based on call type (video call by default)
    await _agoraManager.prepareVideo();

    // Register event handlers
    _agoraManager.setupEventHandlers(
      onJoinChannelSuccess: (connection, elapsed) {
        print(
          "FEMALE APP: SUCCESSFULLY JOINED CHANNEL ${connection.channelId} as UID ${connection.localUid}",
        );
        if (mounted) {
          setState(() => _joined = true);
        }
      },
      onUserJoined: (connection, remoteUid, elapsed) {
        print("FEMALE APP: CALLER CONNECTED: $remoteUid");
        if (mounted) {
          setState(() => this.remoteUid = remoteUid);
        }
      },
      onUserOffline: (connection, remoteUid, reason) {
        print("FEMALE APP: CALLER DISCONNECTED: $remoteUid");
        if (mounted) {
          setState(() => this.remoteUid = null);
        }
      },
      onError: (err, msg) {
        print("FEMALE APP: AGORA ERROR $err: $msg");
      },
    );

    // Wait for event handlers to register, then auto-join for testing
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) {
        print(
          "Female app auto-joining channel: ${widget.channelName} with UID: ${widget.uid}",
        );
        joinCall(widget.channelName, widget.uid);
      }
    });
  }

  Future<void> joinCall(String channelName, int uid) async {
    print("FEMALE APP: Joining channel $channelName with UID: $uid");
    try {
      await _agoraManager.joinChannel(channelName, uid: uid);
      print("FEMALE APP: Join channel request sent");
    } catch (e) {
      print("FEMALE APP: Error joining channel: $e");
    }
  }

  Future<void> leaveCall() async {
    await _agoraManager.leaveChannel();
    setState(() {
      _joined = false;
      remoteUid = null;
    });
  }

  Future<void> toggleMute() async {
    await _agoraManager.engine!.muteLocalAudioStream(!_isMuted);
    setState(() {
      _isMuted = !_isMuted;
    });
  }

  Future<void> toggleCamera() async {
    await _agoraManager.engine!.muteLocalVideoStream(!_isCameraOff);
    setState(() {
      _isCameraOff = !_isCameraOff;
    });
  }

  void _handleIncomingCall(IncomingCallData call) {
    // Join the call channel when call is accepted
    joinCall(call.channelName, int.parse(_uidController.text));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _joined
              ? 'In Call - ${_channelController.text}'
              : 'Ready to Receive Calls',
        ),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Local video preview (small) - always show when joined
          if (_joined)
            Positioned(
              top: 50,
              right: 20,
              child: Container(
                width: 100,
                height: 150,
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
                          rtcEngine: _agoraManager.engine!,
                          canvas: VideoCanvas(uid: widget.uid),
                        ),
                      ),
              ),
            ),

          // Remote video view (main) - show black screen when no remote user
          Container(
            color: Colors.black,
            child: _joined && remoteUid != null
                ? AgoraVideoView(
                    controller: VideoViewController.remote(
                      rtcEngine: _agoraManager.engine!,
                      canvas: VideoCanvas(uid: remoteUid!),
                      connection: RtcConnection(channelId: widget.channelName),
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.videocam, size: 80, color: Colors.white38),
                        SizedBox(height: 20),
                        Text(
                          _joined
                              ? 'Waiting for caller...'
                              : 'Join a call to start',
                          style: TextStyle(fontSize: 18, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
          ),

          // Ready state with input fields
          if (!_joined)
            Container(
              color: Colors.pink.shade50,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.phone_callback, size: 80, color: Colors.pink),
                      SizedBox(height: 20),
                      Text(
                        'Ready to receive calls',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.pink.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 30),

                      // Channel Name Input
                      TextField(
                        controller: _channelController,
                        decoration: InputDecoration(
                          labelText: 'Channel Name',
                          hintText: 'Enter channel name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: Icon(Icons.chat),
                        ),
                      ),
                      SizedBox(height: 20),

                      // UID Input
                      TextField(
                        controller: _uidController,
                        decoration: InputDecoration(
                          labelText: 'Your UID',
                          hintText: 'Enter your user ID',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: Icon(Icons.person),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 30),

                      // Current settings display
                      Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Current Settings',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.pink,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Channel: ${_channelController.text}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                            Text(
                              'Your UID: ${_uidController.text}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30),

                      ElevatedButton(
                        onPressed: () {
                          // Simulate incoming call for testing
                          CallNotificationService().simulateIncomingCall(
                            callerName: "Test Caller",
                            callerId: "1",
                            channelName: _channelController.text,
                            callerUid: 1,
                            isVideoCall: true,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text(
                          'Simulate Incoming Call',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
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
                  FloatingActionButton(
                    onPressed: toggleCamera,
                    backgroundColor: _isCameraOff ? Colors.grey : Colors.white,
                    child: Icon(
                      _isCameraOff ? Icons.videocam_off : Icons.videocam,
                      color: _isCameraOff ? Colors.white : Colors.black,
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

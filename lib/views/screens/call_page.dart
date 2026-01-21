import 'package:provider/provider.dart';
import '../../controllers/api_controller.dart';
import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../services/token_service.dart';

const String kDefaultAgoraAppId = '3b2d066ea4da4c84ad4492ea72780653';
const String kAgoraAppId = String.fromEnvironment(
  'AGORA_APP_ID',
  defaultValue: kDefaultAgoraAppId,
);

class CallPage extends StatefulWidget {
  // Add these fields for call context
  // You may want to pass these from the call start logic
  // For now, assume channelName == callId, and receiverId/callType are available via widget or arguments
  // You can adjust as needed for your app's call flow
  // final String receiverId;
  // final String callType;
  const CallPage({
    super.key,
    required this.channelName,
    required this.enableVideo,
    this.isInitiator = false,
  });

  final String channelName;
  final bool enableVideo;
  final bool isInitiator;

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  Timer? _callTimer;
  int _callDuration = 0;
  bool _endingCall = false;
  DateTime? _callStartTime;

  // These should be set from call context (e.g., via widget or arguments)
  // For demo, we use dummy values. Replace with real values in your integration.
  String get _receiverId =>
      widget.channelName.split('_').last; // Example extraction
  String get _callType => widget.enableVideo ? 'video' : 'audio';
  String get _callId => widget.channelName;
  RtcEngine? _engine;
  int? _remoteUid;
  bool _joined = false;
  bool _muted = false;
  bool _videoEnabled = true;
  StreamSubscription? _engineEventSub;

  @override
  void initState() {
    super.initState();
    _videoEnabled = widget.enableVideo;
    _init();

    // Start call timer
    _callStartTime = DateTime.now();
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _callDuration++);
    });
  }

  Future<void> _init() async {
    if (kAgoraAppId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Missing AGORA_APP_ID. Pass with --dart-define.'),
        ),
      );
      return;
    }

    if (!(await _ensurePermissions())) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera/Microphone permission denied.')),
      );
      return;
    }

    final engine = createAgoraRtcEngine();
    _engine = engine;
    await engine.initialize(const RtcEngineContext(appId: kAgoraAppId));

    engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          setState(() => _joined = true);
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          setState(() => _remoteUid = remoteUid);
        },
        onUserOffline:
            (
              RtcConnection connection,
              int remoteUid,
              UserOfflineReasonType reason,
            ) {
              setState(() => _remoteUid = null);
              // If remote user leaves (e.g., due to balance depletion), end the call session
              if (mounted) {
                _endCallSession();
              }
            },
        onError: (ErrorCodeType err, String msg) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Call Error: $msg')));
          }
        },
      ),
    );

    // Configure engine with memory-optimized settings
    await engine.setParameters('{"rtc.log_level":3}');

    await engine.enableAudio();
    if (widget.enableVideo) {
      await engine.enableVideo();

      // Set video encoding parameters to reduce memory usage
      await engine.setVideoEncoderConfiguration(
        const VideoEncoderConfiguration(
          dimensions: VideoDimensions(
            width: 320,
            height: 240,
          ), // Lower resolution
          frameRate: 15, // Lower frame rate
          bitrate: 300, // Lower bitrate
        ),
      );

      await Future.delayed(const Duration(milliseconds: 100));
      await engine.startPreview();
    } else {
      await engine.disableVideo();
    }

    final token = await TokenService.fetchToken(
      channelName: widget.channelName,
      uid: 0,
    );

    await engine.joinChannel(
      token: token,
      channelId: widget.channelName,
      uid: 0,
      options: ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileCommunication,
        publishMicrophoneTrack: true,
        publishCameraTrack: widget.enableVideo,
      ),
    );
  }

  Future<bool> _ensurePermissions() async {
    final statuses = await [Permission.microphone, Permission.camera].request();

    final micGranted =
        statuses[Permission.microphone] == PermissionStatus.granted;
    final camGranted = statuses[Permission.camera] == PermissionStatus.granted;
    return micGranted && camGranted;
  }

  @override
  void dispose() {
    _engineEventSub?.cancel();
    _callTimer?.cancel();
    _callTimer = null;
    _endCallSession(
      auto: true,
    ); // Ensure cleanup and API call if not already done
    _engine = null;
    super.dispose();
  }

  Future<void> _leave() async {
    try {
      final engine = _engine;
      if (engine != null) {
        try {
          await engine.stopPreview();
        } catch (_) {}
        try {
          await engine.disableVideo();
        } catch (_) {}
        await engine.leaveChannel();
        // Properly release engine resources to minimize memory usage
        await engine.release();
      }
    } finally {
      if (mounted) setState(() => _joined = false);
    }
  }

  /// End call session: stop timer, stop Agora, call backend, cleanup UI/state
  Future<void> _endCallSession({bool auto = false}) async {
    if (_endingCall) return; // Prevent duplicate requests
    _endingCall = true;
    _callTimer?.cancel();
    _callTimer = null;
    final duration = _callDuration;
    await _leave(); // Stop Agora/WebRTC

    try {
      final apiController = Provider.of<ApiController>(context, listen: false);
      // Log parameters before API call
      print(
        '[DEBUG] Calling endCall API with: receiverId=$_receiverId, duration=$duration, callType=$_callType, callId=$_callId',
      );

      // Add retry mechanism for the API call
      Map<String, dynamic>? response;
      int attempts = 0;
      int maxAttempts = 3;

      while (attempts < maxAttempts) {
        try {
          response = await apiController.endCall(
            receiverId: _receiverId,
            duration: duration,
            callType: _callType,
            callId: _callId,
          );
          break; // Success, exit retry loop
        } catch (e) {
          attempts++;
          print('[DEBUG] endCall attempt $attempts failed: $e');
          if (attempts >= maxAttempts) {
            rethrow; // Re-throw if all attempts failed
          }
          // Wait before retrying
          await Future.delayed(Duration(seconds: 1 * attempts));
        }
      }

      // Log full response
      print('[DEBUG] endCall API response: $response');
      if (response != null && response['success'] == true) {
        final data = response['data'] ?? {};
        // Show call summary (coins, duration, etc.)
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => AlertDialog(
              title: const Text('Call Ended'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Duration: ${data['duration'] ?? duration} seconds'),
                  Text('Coins Deducted: ${data['coinsDeducted'] ?? '-'}'),
                  Text(
                    'Your Balance: ${data['callerRemainingBalance'] ?? data['remainingBalance'] ?? '-'}',
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).maybePop(); // Back to dashboard
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } else {
        final msg = response?['message'] ?? 'Failed to end call';
        print('[DEBUG] endCall API error: $msg');
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(msg)));
          Navigator.of(context).maybePop(); // Navigate back anyway
        }
      }
    } catch (e, stack) {
      print('[DEBUG] Exception in endCall: $e\n$stack');
      // Even if API fails, still navigate back to prevent stuck call screen
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Call ended (API error: $e)')));
        Navigator.of(context).maybePop(); // Navigate back even on API error
      }
    } finally {
      _endingCall = false;
    }
  }

  Future<void> _toggleMute() async {
    final next = !_muted;
    final engine = _engine;
    if (engine == null) return;
    await engine.muteLocalAudioStream(next);
    setState(() => _muted = next);
  }

  Future<void> _switchCamera() async {
    final engine = _engine;
    if (engine == null) return;
    await engine.switchCamera();
  }

  Future<void> _toggleLocalVideo() async {
    final next = !_videoEnabled;
    final engine = _engine;
    if (engine == null) return;
    if (next) {
      await engine.enableVideo();
      await engine.muteLocalVideoStream(false);
      await Future.delayed(const Duration(milliseconds: 100));
      await engine.startPreview();
    } else {
      await engine.muteLocalVideoStream(true);
      await engine.stopPreview();
    }
    setState(() => _videoEnabled = next);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Channel: ${widget.channelName}')),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.black,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: _remoteUid != null
                        ? AgoraVideoView(
                            controller: VideoViewController.remote(
                              rtcEngine: _engine!,
                              canvas: VideoCanvas(uid: _remoteUid),
                              connection: RtcConnection(
                                channelId: widget.channelName,
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              _joined ? 'Waiting for remote user…' : 'Joining…',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ),
                  ),
                  if (widget.enableVideo)
                    Positioned(
                      right: 12,
                      bottom: 12,
                      width: 120,
                      height: 180,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _engine == null
                              ? const SizedBox.shrink()
                              : AgoraVideoView(
                                  controller: VideoViewController(
                                    rtcEngine: _engine!,
                                    canvas: const VideoCanvas(uid: 0),
                                  ),
                                ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: _toggleMute,
                    icon: Icon(_muted ? Icons.mic_off : Icons.mic),
                    color: _muted ? Colors.red : null,
                  ),
                  if (widget.enableVideo)
                    IconButton(
                      onPressed: _toggleLocalVideo,
                      icon: Icon(
                        _videoEnabled ? Icons.videocam : Icons.videocam_off,
                      ),
                    ),
                  if (widget.enableVideo)
                    IconButton(
                      onPressed: _switchCamera,
                      icon: const Icon(Icons.cameraswitch),
                    ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: _endingCall ? null : () => _endCallSession(),
                    icon: const Icon(Icons.call_end),
                    label: const Text('End Call'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

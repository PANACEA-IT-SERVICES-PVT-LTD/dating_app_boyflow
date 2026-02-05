import 'package:provider/provider.dart';
import '../../controllers/api_controller.dart';
import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../services/token_service.dart';

// Call History Item Model
class CallHistoryItem {
  final String userId;
  final String name;
  final String profileImage;
  final String callType;
  final String status;
  final int duration;
  final int billableDuration;
  final DateTime createdAt;
  final String callId;

  CallHistoryItem({
    required this.userId,
    required this.name,
    required this.profileImage,
    required this.callType,
    required this.status,
    required this.duration,
    required this.billableDuration,
    required this.createdAt,
    required this.callId,
  });

  factory CallHistoryItem.fromJson(Map<String, dynamic> json) {
    return CallHistoryItem(
      userId: json['userId'] ?? '',
      name: json['name'] ?? 'Unknown',
      profileImage: json['profileImage'] ?? '',
      callType: json['callType'] ?? 'audio',
      status: json['status'] ?? 'unknown',
      duration: json['duration'] ?? 0,
      billableDuration: json['billableDuration'] ?? 0,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      callId: json['callId'] ?? '',
    );
  }
}

// Call History Widget
class CallHistoryWidget extends StatefulWidget {
  const CallHistoryWidget({super.key});

  @override
  State<CallHistoryWidget> createState() => _CallHistoryWidgetState();
}

class _CallHistoryWidgetState extends State<CallHistoryWidget> {
  List<CallHistoryItem> _callHistory = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 0;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadCallHistory();
  }

  Future<void> _loadCallHistory({bool loadMore = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      if (!loadMore) {
        _error = null;
        _currentPage = 0;
        _callHistory.clear();
      }
    });

    try {
      final apiController = Provider.of<ApiController>(context, listen: false);
      final result = await apiController.fetchCallHistory(
        limit: 10,
        skip: _currentPage * 10,
      );

      if (result['success'] == true && result['data'] is List) {
        final List<dynamic> data = result['data'];
        final List<CallHistoryItem> newItems = data
            .map((item) => CallHistoryItem.fromJson(item))
            .toList();

        setState(() {
          if (loadMore) {
            _callHistory.addAll(newItems);
          } else {
            _callHistory = newItems;
          }
          _hasMore = newItems.length == 10; // Assume more if we got full page
          _currentPage++;
        });
      } else {
        setState(() {
          _error = result['message'] ?? 'Failed to load call history';
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Call History'), centerTitle: true),
      body: RefreshIndicator(
        onRefresh: () => _loadCallHistory(),
        child: _error != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _loadCallHistory(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: _callHistory.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _callHistory.length) {
                    // Load more indicator
                    return _isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : ListTile(
                            title: const Text('Load More'),
                            onTap: () => _loadCallHistory(loadMore: true),
                            trailing: const Icon(Icons.arrow_downward),
                          );
                  }

                  final call = _callHistory[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: call.profileImage.isNotEmpty
                            ? NetworkImage(call.profileImage)
                            : null,
                        child: call.profileImage.isEmpty
                            ? Text(call.name.substring(0, 1))
                            : null,
                      ),
                      title: Text(call.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                call.callType == 'video'
                                    ? Icons.videocam
                                    : Icons.phone,
                                size: 16,
                                color: call.callType == 'video'
                                    ? Colors.blue
                                    : Colors.green,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${call.callType.capitalize()} call',
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: call.status == 'completed'
                                      ? Colors.green
                                      : Colors.grey,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  call.status,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Duration: ${_formatDuration(call.duration)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatDate(call.createdAt),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      trailing: Text(
                        _formatDuration(call.billableDuration),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

extension on String {
  String capitalize() {
    return isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
  }
}

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
      // Close the call page if Agora app ID is missing
      if (mounted) {
        Navigator.of(context).maybePop();
      }
      return;
    }

    if (!(await _ensurePermissions())) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera/Microphone permission denied.')),
      );
      // Close the call page if permissions are denied
      if (mounted) {
        Navigator.of(context).maybePop();
      }
      return;
    }

    final engine = createAgoraRtcEngine();
    _engine = engine;
    await engine.initialize(const RtcEngineContext(appId: kAgoraAppId));

    engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          setState(() => _joined = true);
          print('[DEBUG] Successfully joined channel: ${connection.channelId}');
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          setState(() => _remoteUid = remoteUid);
          print('[DEBUG] Remote user joined: $remoteUid');
        },
        onUserOffline:
            (
              RtcConnection connection,
              int remoteUid,
              UserOfflineReasonType reason,
            ) {
              setState(() => _remoteUid = null);
              print('[DEBUG] Remote user left: $remoteUid, reason: $reason');
              // If remote user leaves (e.g., due to balance depletion), end the call session
              if (mounted) {
                _endCallSession();
              }
            },
        onError: (ErrorCodeType err, String msg) {
          print('[DEBUG] Agora error: ${err.index}, message: $msg');
          if (mounted && context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Call Error: $msg')));
            // If there's a critical error, end the call session
            // Error code -102 is CONNECTION_REJECTED which can mean various connection issues
            if (err.index == -102 ||
                err.index == 102 ||
                err.index == -8 ||
                err.index == 8) {
              // Handle both positive and negative indices for common connection errors
              // -102/102: CONNECTION_REJECTED
              // -8/8: INVALID_APP_ID
              print(
                '[DEBUG] Critical Agora error detected (${err.index}), ending call session',
              );
              _endCallSession();
            }
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

    print('[DEBUG] Attempting to join channel: ${widget.channelName}');

    // Add timeout for the join channel operation
    try {
      await engine
          .joinChannel(
            token: token,
            channelId: widget.channelName,
            uid: 0,
            options: ChannelMediaOptions(
              clientRoleType: ClientRoleType.clientRoleBroadcaster,
              channelProfile: ChannelProfileType.channelProfileCommunication,
              publishMicrophoneTrack: true,
              publishCameraTrack: widget.enableVideo,
            ),
          )
          .timeout(const Duration(seconds: 15)); // Add 15-second timeout
    } catch (e) {
      print('[DEBUG] Failed to join channel: $e');
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to connect to call. Please try again.'),
          ),
        );
        // Navigate back after showing error
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && context.mounted) {
            Navigator.of(context).maybePop();
          }
        });
      }
    }
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
    // Only trigger endCall if the call was actually initiated
    if (!_endingCall && _callDuration > 0) {
      _endCallSession(
        auto: true,
      ); // Ensure cleanup and API call if not already done
    }
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

    // Don't make API call if the call was never properly established
    // For example, if Agora connection failed immediately
    if (!_joined && duration == 0 && !auto) {
      print('[DEBUG] Call was never established, skipping API call');
      await _leave(); // Still clean up Agora resources
      if (mounted && context.mounted) {
        Navigator.of(context).maybePop(); // Return to previous screen
      }
      _endingCall = false;
      return;
    }

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
        if (mounted && context.mounted) {
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
        if (mounted && context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(msg)));
          Navigator.of(context).maybePop(); // Navigate back anyway
        }
      }
    } catch (e, stack) {
      print('[DEBUG] Exception in endCall: $e\n$stack');
      // Even if API fails, still navigate back to prevent stuck call screen
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Call ended (API error: $e)')));
        Navigator.of(context).maybePop(); // Navigate back even on API error
      } else {
        // If widget is unmounted, just log the error and return
        print('[DEBUG] Widget unmounted during endCall, skipping UI updates');
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
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CallHistoryWidget(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.history),
                    color: Colors.blue,
                    tooltip: 'Call History',
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

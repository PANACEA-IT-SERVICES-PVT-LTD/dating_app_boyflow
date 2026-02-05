import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class AgoraService {
  static const String appId =
      '3b2d066ea4da4c84ad4492ea72780653'; // Your Agora App ID

  RtcEngine? _engine;
  bool _isJoined = false;
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  int? _remoteUid;
  String? _channelName;

  // Callbacks
  Function(int uid)? onUserJoined;
  Function(int uid)? onUserOffline;
  Function()? onJoinChannelSuccess;
  Function(String error)? onError;
  Function()? onCallEnd;

  bool get isJoined => _isJoined;
  bool get isMuted => _isMuted;
  bool get isVideoEnabled => _isVideoEnabled;
  int? get remoteUid => _remoteUid;
  RtcEngine? get engine => _engine;

  Future<void> initialize() async {
    if (_engine != null) return;

    try {
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(
        RtcEngineContext(
          appId: appId,
          channelProfile: ChannelProfileType.channelProfileCommunication,
          audioScenario: AudioScenarioType.audioScenarioDefault,
        ),
      );

      _setupEventHandlers();

      // Enable audio and video
      await _engine!.enableAudio();
      await _engine!.enableVideo();

      if (kDebugMode) {
        print('Agora RTC Engine initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize Agora RTC Engine: $e');
      }
      onError?.call('Failed to initialize Agora: $e');
    }
  }

  void _setupEventHandlers() {
    _engine?.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          if (kDebugMode) {
            print('Successfully joined channel: ${connection.channelId}');
          }
          _isJoined = true;
          onJoinChannelSuccess?.call();
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          if (kDebugMode) {
            print('Remote user joined: $remoteUid');
          }
          _remoteUid = remoteUid;
          onUserJoined?.call(remoteUid);
        },
        onUserOffline:
            (
              RtcConnection connection,
              int remoteUid,
              UserOfflineReasonType reason,
            ) {
              if (kDebugMode) {
                print('Remote user offline: $remoteUid, reason: $reason');
              }
              _remoteUid = null;
              onUserOffline?.call(remoteUid);
            },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          if (kDebugMode) {
            print('Left channel: ${connection.channelId}');
          }
          _isJoined = false;
          _remoteUid = null;
          onCallEnd?.call();
        },
        onError: (ErrorCodeType err, String msg) {
          if (kDebugMode) {
            print('Agora error: $err, message: $msg');
          }
          onError?.call('Agora error: $msg');
        },
      ),
    );
  }

  Future<void> joinChannel({
    required String channelName,
    required String token,
    required int uid,
  }) async {
    if (_engine == null) {
      await initialize();
    }

    try {
      // Check and request permissions
      await _requestPermissions();

      _channelName = channelName;

      // Configure video encoder
      await _engine!.setVideoEncoderConfiguration(
        const VideoEncoderConfiguration(
          dimensions: VideoDimensions(width: 640, height: 480),
          frameRate: 15,
          bitrate: 800,
        ),
      );

      // Join channel
      await _engine!.joinChannel(
        token: token,
        channelId: channelName,
        uid: uid,
        options: const ChannelMediaOptions(
          channelProfile: ChannelProfileType.channelProfileCommunication,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
        ),
      );

      if (kDebugMode) {
        print('Joining channel: $channelName with uid: $uid');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to join channel: $e');
      }
      onError?.call('Failed to join channel: $e');
    }
  }

  Future<void> leaveChannel() async {
    if (_engine == null || !_isJoined) return;

    try {
      await _engine!.leaveChannel();
      _isJoined = false;
      _remoteUid = null;
      _channelName = null;

      if (kDebugMode) {
        print('Left channel successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error leaving channel: $e');
      }
      onError?.call('Error leaving channel: $e');
    }
  }

  Future<void> toggleMute() async {
    if (_engine == null) return;

    try {
      _isMuted = !_isMuted;
      await _engine!.muteLocalAudioStream(_isMuted);

      if (kDebugMode) {
        print('Microphone ${_isMuted ? 'muted' : 'unmuted'}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling mute: $e');
      }
      onError?.call('Error toggling mute: $e');
    }
  }

  Future<void> toggleVideo() async {
    if (_engine == null) return;

    try {
      _isVideoEnabled = !_isVideoEnabled;
      await _engine!.muteLocalVideoStream(!_isVideoEnabled);

      if (kDebugMode) {
        print('Video ${_isVideoEnabled ? 'enabled' : 'disabled'}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling video: $e');
      }
      onError?.call('Error toggling video: $e');
    }
  }

  Future<void> switchCamera() async {
    if (_engine == null) return;

    try {
      await _engine!.switchCamera();
      if (kDebugMode) {
        print('Camera switched');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error switching camera: $e');
      }
      onError?.call('Error switching camera: $e');
    }
  }

  Future<void> startPreview() async {
    if (_engine == null) return;

    try {
      await _engine!.startPreview();
      if (kDebugMode) {
        print('Preview started');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error starting preview: $e');
      }
      onError?.call('Error starting preview: $e');
    }
  }

  Future<void> stopPreview() async {
    if (_engine == null) return;

    try {
      await _engine!.stopPreview();
      if (kDebugMode) {
        print('Preview stopped');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error stopping preview: $e');
      }
      onError?.call('Error stopping preview: $e');
    }
  }

  Future<void> _requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      await [Permission.camera, Permission.microphone].request();
    }
  }

  Future<void> dispose() async {
    await leaveChannel();

    if (_engine != null) {
      await _engine!.release();
      _engine = null;
    }

    _isJoined = false;
    _isMuted = false;
    _isVideoEnabled = true;
    _remoteUid = null;
    _channelName = null;

    if (kDebugMode) {
      print('AgoraService disposed');
    }
  }
}

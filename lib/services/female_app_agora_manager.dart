import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart';
import '../agora_config.dart';

class FemaleAppAgoraManager {
  // Singleton instance
  static final FemaleAppAgoraManager _instance = FemaleAppAgoraManager._internal();
  factory FemaleAppAgoraManager() => _instance;
  FemaleAppAgoraManager._internal();

  // Persistent RtcEngine instance
  RtcEngine? _engine;
  bool _isInitialized = false;
  String? _currentChannel;
  int? _currentUid;

  // Getters
  RtcEngine? get engine => _engine;
  bool get isInitialized => _isInitialized;
  String? get currentChannel => _currentChannel;
  int? get currentUid => _currentUid;

  /// Initialize the Agora engine with a unique UID for female app
  Future<void> initialize() async {
    if (_isInitialized && _engine != null) {
      debugPrint('FemaleAppAgoraManager: Engine already initialized');
      return;
    }

    try {
      // Create engine only once
      _engine = createAgoraRtcEngine();
      
      // Initialize engine
      await _engine!.initialize(
        RtcEngineContext(
          appId: appId,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ),
      );

      _isInitialized = true;
      _currentUid = femaleAppUid; // Use a different UID for female app
      
      debugPrint('FemaleAppAgoraManager: Engine initialized with UID: ${femaleAppUid}');
      debugPrint('FemaleAppAgoraManager: App ID: $appId');
      debugPrint('FemaleAppAgoraManager: Engine hash: ${_engine.hashCode}');

    } catch (e) {
      debugPrint('FemaleAppAgoraManager: Failed to initialize engine: $e');
      _isInitialized = false;
    }
  }

  /// Enable video and start preview (must be called before joining)
  Future<void> prepareVideo() async {
    if (!_isInitialized || _engine == null) {
      debugPrint('FemaleAppAgoraManager: Engine not initialized');
      return;
    }

    try {
      await _engine!.enableVideo();
      await _engine!.startPreview();
      debugPrint('FemaleAppAgoraManager: Video enabled and preview started');
    } catch (e) {
      debugPrint('FemaleAppAgoraManager: Failed to prepare video: $e');
    }
  }

  /// Join a channel with the same engine instance
  Future<void> joinChannel(String channelName, {int? uid}) async {
    if (!_isInitialized || _engine == null) {
      debugPrint('FemaleAppAgoraManager: Engine not initialized');
      return;
    }

    try {
      final joinUid = uid ?? femaleAppUid; // Use female app UID by default
      _currentChannel = channelName;
      _currentUid = joinUid;

      debugPrint('FemaleAppAgoraManager: Joining channel');
      debugPrint('App ID: $appId');
      debugPrint('Channel Name: $channelName');
      debugPrint('UID: $joinUid');
      debugPrint('Engine Hash: ${_engine.hashCode}');

      await _engine!.joinChannel(
        token: "",
        channelId: channelName,
        uid: joinUid,
        options: const ChannelMediaOptions(),
      );

      debugPrint('FemaleAppAgoraManager: Successfully joined channel $channelName');
    } catch (e) {
      debugPrint('FemaleAppAgoraManager: Failed to join channel: $e');
    }
  }

  /// Leave current channel
  Future<void> leaveChannel() async {
    if (!_isInitialized || _engine == null) return;

    try {
      await _engine!.leaveChannel();
      _currentChannel = null;
      debugPrint('FemaleAppAgoraManager: Left channel');
    } catch (e) {
      debugPrint('FemaleAppAgoraManager: Failed to leave channel: $e');
    }
  }

  /// Clean up and release engine
  Future<void> release() async {
    if (_engine != null) {
      try {
        await _engine!.leaveChannel();
        _engine!.release();
        debugPrint('FemaleAppAgoraManager: Engine released');
      } catch (e) {
        debugPrint('FemaleAppAgoraManager: Error releasing engine: $e');
      }
      _engine = null;
      _isInitialized = false;
      _currentChannel = null;
      _currentUid = null;
    }
  }

  /// Set up event handlers
  void setupEventHandlers({
    Function(RtcConnection connection, int elapsed)? onJoinChannelSuccess,
    Function(RtcConnection connection, int remoteUid, int elapsed)? onUserJoined,
    Function(RtcConnection connection, int remoteUid, UserOfflineReasonType reason)? onUserOffline,
    Function(ErrorCodeType err, String msg)? onError,
  }) {
    if (!_isInitialized || _engine == null) {
      debugPrint('FemaleAppAgoraManager: Cannot setup event handlers - engine not initialized');
      return;
    }

    debugPrint('FemaleAppAgoraManager: Setting up event handlers');
    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: onJoinChannelSuccess,
        onUserJoined: onUserJoined,
        onUserOffline: onUserOffline,
        onError: onError,
      ),
    );
    debugPrint('FemaleAppAgoraManager: Event handlers registered');
  }
}
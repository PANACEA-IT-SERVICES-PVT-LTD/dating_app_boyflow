import 'dart:async';
import 'dart:math';
import '../models/call_state.dart';
import '../models/user.dart';
import 'callkit_service.dart';

class CallManager {
  static final CallManager _instance = CallManager._internal();
  factory CallManager() => _instance;
  CallManager._internal();

  final StreamController<CallInfo?> _callStateController =
      StreamController<CallInfo?>.broadcast();
  CallInfo? _currentCall;

  Stream<CallInfo?> get callStateStream => _callStateController.stream;
  CallInfo? get currentCall => _currentCall;

  static const String currentUserId = 'current_user';
  static const String currentUserName = 'You';

  Future<String> initiateCall(User targetUser, CallType type) async {
    // Perform memory cleanup if needed
    _cleanupResources();

    final callId = _generateCallId();
    final channelName = 'call_${callId}';

    _currentCall = CallInfo(
      id: callId,
      channelName: channelName,
      callerName: currentUserName,
      callerId: currentUserId,
      receiverId: targetUser.id,
      type: type,
      state: CallState.outgoing,
      timestamp: DateTime.now(),
    );

    _callStateController.add(_currentCall);


    final callkit = CallkitService();
    await callkit.showOutgoingCall(
      callId: callId,
      targetName: targetUser.name,
      channelName: channelName,
      isVideo: type == CallType.video,
    );

    // No incoming call simulation
    return callId;
  }



  Future<void> acceptCall() async {
    if (_currentCall == null) return;

    _currentCall = _currentCall!.copyWith(state: CallState.connected);
    _callStateController.add(_currentCall);

    final callkit = CallkitService();
    await callkit.endCall(_currentCall!.id);
  }

  Future<void> rejectCall() async {
    if (_currentCall == null) return;

    _currentCall = _currentCall!.copyWith(state: CallState.ended);
    _callStateController.add(_currentCall);

    final callkit = CallkitService();
    await callkit.endCall(_currentCall!.id);

    _clearCurrentCall();
  }

  Future<void> endCall() async {
    if (_currentCall == null) return;

    _currentCall = _currentCall!.copyWith(state: CallState.ended);
    _callStateController.add(_currentCall);

    final callkit = CallkitService();
    await callkit.endCall(_currentCall!.id);

    _clearCurrentCall();
  }

  void _clearCurrentCall() {
    _currentCall = null;
    _callStateController.add(null);
  }



  String _generateCallId() {
    return 'call_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  void _cleanupResources() {
    // Clean up any cached data or temporary resources
    if (_currentCall?.state == CallState.ended) {
      _currentCall = null;
    }
  }

  void dispose() {
    _callStateController.close();
  }
}

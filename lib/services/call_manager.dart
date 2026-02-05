import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/call_state.dart';
import '../models/user.dart';

class CallManager extends ChangeNotifier {
  static final CallManager _instance = CallManager._internal();
  factory CallManager() => _instance;
  CallManager._internal();

  final CallStateModel _callStateModel = CallStateModel();
  CallInfo? _currentCall;

  CallState get currentState => _callStateModel.state;
  String? get activeCallId => _callStateModel.activeCallId;
  bool get hasActiveCall => _callStateModel.isActiveCall;
  CallInfo? get currentCall => _currentCall;

  void setState(CallState newState, {String? callId}) {
    _callStateModel.setState(newState, callId: callId);
    notifyListeners();
  }

  void reset() {
    _callStateModel.reset();
    _currentCall = null;
    notifyListeners();
  }

  bool canStartNewCall() {
    return !hasActiveCall;
  }

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

    notifyListeners();

    // Callkit service integration would go here
    // For now, just return the callId
    return callId;
  }

  Future<void> acceptCall() async {
    if (_currentCall == null) return;

    _currentCall = _currentCall!.copyWith(state: CallState.connected);
    notifyListeners();

    // Callkit service integration would go here
  }

  Future<void> rejectCall() async {
    if (_currentCall == null) return;

    _currentCall = _currentCall!.copyWith(state: CallState.ended);
    notifyListeners();

    // Callkit service integration would go here

    _clearCurrentCall();
  }

  Future<void> endCall() async {
    if (_currentCall == null) return;

    _currentCall = _currentCall!.copyWith(state: CallState.ended);
    notifyListeners();

    // Callkit service integration would go here

    _clearCurrentCall();
  }

  void _clearCurrentCall() {
    _currentCall = null;
    notifyListeners();
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
    // No stream controller to close in this simplified version
  }
}

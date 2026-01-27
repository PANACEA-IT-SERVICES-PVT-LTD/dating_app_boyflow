enum CallState { idle, outgoing, incoming, connected, ended }

enum CallType { audio, video }

class CallInfo {
  final String id;
  final String channelName;
  final String callerName;
  final String callerId;
  final String receiverId;
  final CallType type;
  final CallState state;
  final DateTime timestamp;

  const CallInfo({
    required this.id,
    required this.channelName,
    required this.callerName,
    required this.callerId,
    required this.receiverId,
    required this.type,
    required this.state,
    required this.timestamp,
  });

  CallInfo copyWith({
    String? id,
    String? channelName,
    String? callerName,
    String? callerId,
    String? receiverId,
    CallType? type,
    CallState? state,
    DateTime? timestamp,
  }) {
    return CallInfo(
      id: id ?? this.id,
      channelName: channelName ?? this.channelName,
      callerName: callerName ?? this.callerName,
      callerId: callerId ?? this.callerId,
      receiverId: receiverId ?? this.receiverId,
      type: type ?? this.type,
      state: state ?? this.state,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

class CallStateModel {
  CallState _state = CallState.idle;
  String? _activeCallId;

  CallState get state => _state;
  String? get activeCallId => _activeCallId;

  void setState(CallState newState, {String? callId}) {
    _state = newState;
    _activeCallId = callId;
  }

  bool get isActiveCall =>
      _state == CallState.outgoing ||
      _state == CallState.incoming ||
      _state == CallState.connected;

  void reset() {
    _state = CallState.idle;
    _activeCallId = null;
  }
}

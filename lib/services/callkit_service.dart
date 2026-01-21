import 'dart:math';


import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';






class CallkitService {
  Future<void> endCall(String uuid) async {
    await FlutterCallkitIncoming.endCall(uuid);
  }

  Future<void> showOutgoingCall({
    required String callId,
    required String targetName,
    required String channelName,
    bool isVideo = true,
  }) async {
    final paramsMap = <String, dynamic>{
      'id': callId,
      'nameCaller': targetName,
      'appName': 'AgoraVideoCall',
      'avatar': 'https://i.pravatar.cc/100?img=12',
      'handle': channelName,
      'type': isVideo ? 1 : 0,
      'extra': {
        'channelName': channelName,
        'isOutgoing': true,
      },
      'android': {
        'isCustomNotification': true,
        'backgroundColor': '#0955fa',
        'isShowLogo': true,
      },
      'ios': {
        'iconName': 'CallKitLogo',
        'handleType': 'generic',
      }
    };
    await FlutterCallkitIncoming.startCall(CallKitParams.fromJson(paramsMap));
  }

  String _randomUuid() {
    final rand = Random();
    return List.generate(32, (_) => rand.nextInt(16).toRadixString(16)).join();
  }
}

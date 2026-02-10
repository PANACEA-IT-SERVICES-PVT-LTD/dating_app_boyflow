import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../agora_config.dart';
import '../screens/female_app_call_screen.dart';
import '../../agora_video_call.dart';

class CallTestGuideScreen extends StatefulWidget {
  const CallTestGuideScreen({Key? key}) : super(key: key);

  @override
  State<CallTestGuideScreen> createState() => _CallTestGuideScreenState();
}

class _CallTestGuideScreenState extends State<CallTestGuideScreen> {
  final _channelController = TextEditingController(text: 'test_channel_123');
  final _callerUidController = TextEditingController(text: '1');
  final _receiverUidController = TextEditingController(text: '2');
  final _callerNameController = TextEditingController(text: 'John');
  final _receiverNameController = TextEditingController(text: 'Sarah');

  bool _isVideoCall = true;
  bool _isTesting = false;

  @override
  void dispose() {
    _channelController.dispose();
    _callerUidController.dispose();
    _receiverUidController.dispose();
    _callerNameController.dispose();
    _receiverNameController.dispose();
    super.dispose();
  }

  void _startCallerTest() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AgoraVideoCallScreen(
          channelName: _channelController.text,
          uid: int.parse(_callerUidController.text),
          remoteUserId: int.parse(_receiverUidController.text),
          remoteUserName: _receiverNameController.text,
          isVideoCall: _isVideoCall,
          isCaller: true,
        ),
      ),
    );
  }

  void _startReceiverTest() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FemaleAppCallScreen(
          channelName: _channelController.text,
          uid: int.parse(_receiverUidController.text),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Call Testing Guide'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                '📞 Audio/Video Call Testing',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Test both audio and video calls between two users',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),

              // Call Type Toggle
              Row(
                children: [
                  const Text('Call Type: ', style: TextStyle(fontSize: 18)),
                  Switch(
                    value: _isVideoCall,
                    onChanged: (value) {
                      setState(() => _isVideoCall = value);
                    },
                  ),
                  Text(
                    _isVideoCall ? 'Video Call' : 'Audio Call',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Configuration Section
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Configuration',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Channel Name
                      TextField(
                        controller: _channelController,
                        decoration: const InputDecoration(
                          labelText: 'Channel Name',
                          border: OutlineInputBorder(),
                          helperText: 'Unique identifier for this call session',
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Caller Info
                      const Text(
                        'Caller (User 1)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _callerUidController,
                              decoration: const InputDecoration(
                                labelText: 'UID',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _callerNameController,
                              decoration: const InputDecoration(
                                labelText: 'Name',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      // Receiver Info
                      const Text(
                        'Receiver (User 2)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _receiverUidController,
                              decoration: const InputDecoration(
                                labelText: 'UID',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _receiverNameController,
                              decoration: const InputDecoration(
                                labelText: 'Name',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // Test Instructions
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '📋 Testing Instructions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        '1. Both users must use the SAME channel name\n'
                        '2. Each user must have a UNIQUE UID (1 and 2)\n'
                        '3. Start the caller app first\n'
                        '4. Start the receiver app second\n'
                        '5. Both should connect automatically\n'
                        '6. Test audio/video controls\n'
                        '7. End call from either side',
                        style: TextStyle(fontSize: 14, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // Test Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _startCallerTest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.phone_forwarded, size: 30),
                          const SizedBox(height: 5),
                          Text(
                            'Start as Caller\n(User 1)',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _startReceiverTest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.phone_callback, size: 30),
                          const SizedBox(height: 5),
                          Text(
                            'Start as Receiver\n(User 2)',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // Status Indicators
              Card(
                color: _isVideoCall
                    ? Colors.blue.shade50
                    : Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _isVideoCall ? Icons.videocam : Icons.phone,
                            color: _isVideoCall ? Colors.blue : Colors.green,
                            size: 24,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _isVideoCall
                                ? 'Video Call Mode'
                                : 'Audio Call Mode',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _isVideoCall ? Colors.blue : Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _isVideoCall
                            ? '• Both video and audio streams enabled\n'
                                  '• Camera controls available\n'
                                  '• Local preview shown'
                            : '• Only audio stream enabled\n'
                                  '• Camera automatically muted\n'
                                  '• No local video preview',
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../agora_video_call.dart';

class ManualCallTestScreen extends StatefulWidget {
  @override
  _ManualCallTestScreenState createState() => _ManualCallTestScreenState();
}

class _ManualCallTestScreenState extends State<ManualCallTestScreen> {
  final _channelController = TextEditingController();
  final _uidController = TextEditingController(text: '1');
  final _remoteUidController = TextEditingController(text: '2');
  final _remoteNameController = TextEditingController(text: 'Test User');

  bool _isVideoCall = true;

  @override
  void initState() {
    super.initState();
    // Set default channel name
    _channelController.text =
        'test_channel_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  void dispose() {
    _channelController.dispose();
    _uidController.dispose();
    _remoteUidController.dispose();
    _remoteNameController.dispose();
    super.dispose();
  }

  void _startCall() {
    if (_channelController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a channel name')),
      );
      return;
    }

    if (_uidController.text.isEmpty || _remoteUidController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter valid UIDs')));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AgoraVideoCallScreen(
          channelName: _channelController.text,
          uid: int.parse(_uidController.text),
          remoteUserId: int.parse(_remoteUidController.text),
          remoteUserName: _remoteNameController.text,
          isVideoCall: _isVideoCall,
          isCaller: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual Call Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Manual Call Testing',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Call Type Toggle
            Row(
              children: [
                const Text('Call Type: ', style: TextStyle(fontSize: 16)),
                Switch(
                  value: _isVideoCall,
                  onChanged: (value) {
                    setState(() {
                      _isVideoCall = value;
                    });
                  },
                ),
                Text(_isVideoCall ? 'Video' : 'Audio'),
              ],
            ),
            const SizedBox(height: 20),

            // Channel Name Input
            TextField(
              controller: _channelController,
              decoration: const InputDecoration(
                labelText: 'Channel Name',
                border: OutlineInputBorder(),
                hintText: 'Enter unique channel name',
              ),
            ),
            const SizedBox(height: 16),

            // Local UID Input
            TextField(
              controller: _uidController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Your UID',
                border: OutlineInputBorder(),
                hintText: 'Enter your user ID (number)',
              ),
            ),
            const SizedBox(height: 16),

            // Remote UID Input
            TextField(
              controller: _remoteUidController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Remote User UID',
                border: OutlineInputBorder(),
                hintText: 'Enter remote user ID (number)',
              ),
            ),
            const SizedBox(height: 16),

            // Remote User Name Input
            TextField(
              controller: _remoteNameController,
              decoration: const InputDecoration(
                labelText: 'Remote User Name',
                border: OutlineInputBorder(),
                hintText: 'Enter remote user name',
              ),
            ),
            const SizedBox(height: 30),

            // Start Call Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startCall,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isVideoCall ? Colors.blue : Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text(
                  'Start ${_isVideoCall ? 'Video' : 'Audio'} Call',
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Instructions
            const Text(
              'Testing Instructions:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              '1. Enter a unique channel name\n'
              '2. Set your UID and remote user UID (must be different)\n'
              '3. Choose call type (Video/Audio)\n'
              '4. Start the call\n'
              '5. On another device/app instance, use the SAME channel name with opposite UIDs\n'
              '6. Both users must join the same channel to connect',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

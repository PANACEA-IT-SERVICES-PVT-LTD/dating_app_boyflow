import 'package:flutter/material.dart';
import 'views/screens/female_app_call_screen.dart';
import 'agora_config.dart';

void main() {
  runApp(TestApp());
}

class TestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Female App Test',
      theme: ThemeData(primarySwatch: Colors.pink),
      home: FemaleAppCallScreen(
        channelName: 'friends_call_123',
        uid: femaleAppUid,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

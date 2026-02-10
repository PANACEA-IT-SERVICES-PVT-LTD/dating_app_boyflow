import 'package:flutter/material.dart';
import 'views/screens/female_app_call_screen.dart';

void main() {
  runApp(const FemaleApp());
}

class FemaleApp extends StatelessWidget {
  const FemaleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Female App - Call Receiver',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const FemaleAppCallScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/api_controller.dart';
import 'views/screens/male_dashboard_screen.dart';

void main() {
  runApp(const MaleApp());
}

class MaleApp extends StatelessWidget {
  const MaleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ApiController(),
      child: MaterialApp(
        title: 'Male App - Dating Platform',
        theme: ThemeData(
          primarySwatch: Colors.pink,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: MaleDashboardScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

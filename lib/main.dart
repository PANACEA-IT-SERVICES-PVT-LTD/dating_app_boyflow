// lib/main.dart
import 'package:Boy_flow/views/screens/registration_status.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/routes/app_routes.dart';
import 'controllers/api_controller.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ApiController())],
      child: MaterialApp(
        title: 'Girl Flow',
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.accountScreen,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}

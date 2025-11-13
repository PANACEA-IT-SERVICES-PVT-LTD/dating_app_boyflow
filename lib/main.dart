// lib/main.dart
import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
import 'core/routes/app_routes.dart';
// import 'controllers/api_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Boy Flow',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.login,
      onGenerateRoute: AppRoutes.generateRoute,
    );
    // return MultiProvider(
    //   providers: [ChangeNotifierProvider(create: (_) => ApiController())],
    //   child: MaterialApp(
    //     title: 'Boy Flow',
    //     debugShowCheckedModeBanner: false,
    //     initialRoute: AppRoutes.home,
    //     onGenerateRoute: AppRoutes.generateRoute,
    //   ),
    // );
  }
}

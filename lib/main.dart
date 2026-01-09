// lib/main.dart
import 'package:Boy_flow/core/routes/app_routes.dart';
import 'package:Boy_flow/views/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'views/screens/main_navigation.dart';
import 'views/screens/introduce_yourself_screen.dart';

import 'controllers/api_controller.dart';
// Removed unused import
import 'views/screens/main_navigation.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ApiController()),
        // Add other providers here if needed
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Boy Flow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      onGenerateRoute: AppRoutes.generateRoute,
      home: AuthCheck(),
    );
  }
}

class AuthCheck extends StatefulWidget {
  @override
  _AuthCheckState createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  @override
  void initState() {
    super.initState();
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null && token.isNotEmpty) {
      // Check if user profile has location set
      final profileResp = await http.get(
        Uri.parse('https://friend-circle-new.vercel.app/male-user/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      try {
        final body = profileResp.body.isNotEmpty
            ? jsonDecode(profileResp.body)
            : {};
        final data = (body is Map && body['data'] is Map)
            ? body['data'] as Map
            : null;
        final hasLocation =
            data != null &&
            data['latitude'] != null &&
            data['longitude'] != null;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (hasLocation) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainNavigationScreen()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => IntroduceYourselfScreen(),
              ),
            );
          }
        });
      } catch (_) {
        // Fallback to dashboard if error parsing profile
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainNavigationScreen()),
          );
        });
      }
    } else {
      // User is not logged in, go to login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator while checking auth status
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Loading...'),
          ],
        ),
      ),
    );
  }
}

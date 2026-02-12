// lib/main.dart
import 'package:boy_flow/api_service/api_endpoint.dart';
import 'package:boy_flow/core/routes/app_routes.dart';
import 'package:boy_flow/views/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'views/screens/main_navigation.dart';
import 'views/screens/introduce_yourself_screen.dart';

import 'controllers/api_controller.dart';

// Removed unused import

// Firebase imports
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'services/fcm_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase asynchronously to avoid blocking the first frame
  Firebase.initializeApp().then((_) {
    print('Firebase initialized successfully');
    FCMService().initialize();
  }).catchError((e) {
    print('Error initializing Firebase: $e');
  });

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
      home: AuthCheck(), // Use AuthCheck to verify authentication status
    );
  }
}

class AuthCheck extends StatefulWidget {
  @override
  _AuthCheckState createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  bool _isCheckingAuth = false;

  @override
  void initState() {
    super.initState();
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    print('[DEBUG] checkAuthStatus called');
    if (_isCheckingAuth) {
      return; // Prevent multiple simultaneous checks
    }
    _isCheckingAuth = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
  
      if (token != null && token.isNotEmpty) {
        print('[DEBUG] Token found, redirecting to dashboard');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(context, AppRoutes.mainNavigation);
        });
      } else {
        print('[DEBUG] No token found, redirecting to login');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        });
      }
    } catch (e) {
      print('Error checking auth status: $e');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      });
    } finally {
      _isCheckingAuth = false;
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

// lib/main.dart
import 'package:Boy_flow/api_service/api_endpoint.dart';
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
import 'views/screens/account_screen.dart';
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
      home: AccountScreen(),
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
    if (_isCheckingAuth) {
      return; // Prevent multiple simultaneous checks
    }
    _isCheckingAuth = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      // Reset the flag after a delay to allow UI updates
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _isCheckingAuth = false;
      });
      final token = prefs.getString('token');

<<<<<<< HEAD
      if (token != null && token.isNotEmpty) {
        // Check if user profile has location set
        final profileResp = await http.get(
          Uri.parse('\${ApiEndPoints.baseUrls}/male-user/me'),
          headers: {
            'Authorization': 'Bearer \$token',
            'Content-Type': 'application/json',
          },
        );

        // Check if the request was successful
        if (profileResp.statusCode == 200) {
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
                  MaterialPageRoute(
                    builder: (context) => MainNavigationScreen(),
                  ),
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
          } catch (e, stackTrace) {
            print('Error parsing profile data: \$e');
            print('Stack trace: \$stackTrace');
            // Fallback to main navigation if error parsing profile
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MainNavigationScreen()),
              );
            });
=======
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
>>>>>>> b359924312079c24c35afbb1a6047af8e5436feb
          }
        } else {
          // Different status codes might need different handling
          if (profileResp.statusCode == 404) {
            // User profile not found - clear the token and redirect to login
            print(
              'User profile not found (404) - clearing token and redirecting to login',
            );
            // Clear the token to force a fresh login
            await prefs.remove('token');
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            });
          } else if (profileResp.statusCode == 401 ||
              profileResp.statusCode == 403) {
            // Unauthorized - token might be expired
            print(
              'Unauthorized access (\${profileResp.statusCode}) - redirecting to login',
            );
            // Go to login for unauthorized access
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            });
          } else {
            // Other error codes
            print(
              'API request failed with status code: \${profileResp.statusCode}',
            );
            // For other errors, go to login
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            });
          }
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
    } catch (e, stackTrace) {
      print('Error in auth check: \$e');
      print('Stack trace: \$stackTrace');
      // If there's an error, default to login screen
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

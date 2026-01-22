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
// ...existing code...
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
      home: LoginScreen(), // Set initial route to login screen as requested
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
      final token = prefs.getString('token');
  
      if (token != null && token.isNotEmpty) {
        // Fetch user profile to check completion and approval status
        final profileResp = await http.get(
          Uri.parse('${ApiEndPoints.baseUrls}/male-user/me'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
  
        if (profileResp.statusCode == 200) {
          try {
            final body = profileResp.body.isNotEmpty
                ? jsonDecode(profileResp.body)
                : {};
            final data = (body is Map && body['data'] is Map)
                ? body['data'] as Map<String, dynamic>
                : null;
                  
            if (data != null) {
              // Check profile completion first
              final profileCompleted = data['profileCompleted'] as bool? ?? false;
                
              if (!profileCompleted) {
                // If profile is not completed, navigate to profile completion
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => IntroduceYourselfScreen()),
                  );
                });
                return; // Exit to prevent further checks
              }
                
              // If profile is completed, check admin approval status
              final adminApprovalStatus = data['reviewStatus']?.toString() ?? 'PENDING';
                
              WidgetsBinding.instance.addPostFrameCallback((_) {
                switch (adminApprovalStatus.toUpperCase()) {
                  case 'APPROVED':
                    // Navigate to homepage if approved
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => MainNavigationScreen()),
                    );
                    break;
                  case 'REJECTED':
                    // Navigate to rejected status screen
                    Navigator.pushReplacementNamed(context, '/registrationStatus');
                    break;
                  case 'PENDING':
                  default:
                    // Navigate to under review status screen
                    Navigator.pushReplacementNamed(context, '/registrationStatus');
                    break;
                }
              });
            } else {
              // If no data found, redirect to login
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              });
            }
          } catch (e, stackTrace) {
            print('Error parsing profile data: $e');
            print('Stack trace: $stackTrace');
            // On error, redirect to login
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            });
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
              'Unauthorized access (${profileResp.statusCode}) - redirecting to login',
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
              'API request failed with status code: ${profileResp.statusCode}',
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
      print('Error in auth check: $e');
      print('Stack trace: $stackTrace');
      // If there's an error, default to login screen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        });
      });
    } finally {
      // Always reset the flag in the finally block
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _isCheckingAuth = false;
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

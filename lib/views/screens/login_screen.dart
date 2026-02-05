import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/routes/app_routes.dart';
import '../../utils/colors.dart';
import '../../widgets/gradient_button.dart';
import '../../controllers/api_controller.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../api_service/api_endpoint.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  bool _isLikelyEmail(String v) {
    final value = v.trim();
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value);
  }

  Future<void> _sendOtp() async {
    FocusScope.of(context).unfocus();
    final email = _emailCtrl.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter your email.")));
      return;
    }
    if (!_isLikelyEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid email address.")),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final apiController = Provider.of<ApiController>(context, listen: false);
      print(
        '[DEBUG] Attempting to call API controller login with email: $email',
      );
      final result = await apiController.login(email);

      print('[DEBUG] Login API result: $result');

      final success = result["success"] == true;
      final message =
          result["message"] ??
          (success ? "OTP sent successfully" : "Failed to send OTP");

      if (!mounted) return;

      if (success) {
        // Navigate first before showing snackbar to avoid widget deactivation issues
        if (mounted) {
          Navigator.pushNamed(
            context,
            AppRoutes.loginVerification,
            arguments: <String, dynamic>{
              'email': email,
              'source': 'login',
              if (result['otp'] != null) 'otp': result['otp'].toString(),
            },
          );
          // Show success message after navigation
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("✅ $message")));
            }
          });
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("❌ $message")));
      }
    } catch (e) {
      print('[ERROR] Login error: $e');
      if (!mounted) return;
      String errorMessage = "❌ Error: ${e.toString()}";
      // Provide more user-friendly error message for common issues
      if (e.toString().toLowerCase().contains('connection') ||
          e.toString().toLowerCase().contains('network')) {
        errorMessage =
            "❌ Network error: Please check your internet connection.";
      } else if (e.toString().toLowerCase().contains('404')) {
        errorMessage =
            "❌ Service temporarily unavailable. Please try again later.";
      } else if (e.toString().toLowerCase().contains('500')) {
        errorMessage =
            "❌ Server error: We're experiencing technical difficulties. Please try again later.";
      } else if (e.toString().toLowerCase().contains('timeout')) {
        errorMessage =
            "❌ Request timeout: Server is taking too long to respond. Please try again.";
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mock loading state for screen-only development
    bool isLoading = false;

    final mq = MediaQuery.of(context);
    final keyboardInset = mq.viewInsets.bottom;

    return Scaffold(
      // keep this true (default) so scaffold adjusts for keyboard
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          // ensure padding for keyboard so the content can scroll above it
          padding: EdgeInsets.only(bottom: keyboardInset),
          child: ConstrainedBox(
            // allow the SingleChildScrollView to take at least the full height
            constraints: BoxConstraints(
              minHeight: mq.size.height - mq.padding.top - mq.padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Stack(
                children: [
                  Container(
                    height: mq.size.height,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.gradientTop,
                          AppColors.gradientBottom,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 45),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            const Text(
                              "100% Trusted and secure",
                              style: TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Image.asset(
                              'assets/sheild.png',
                              height: 24,
                              width: 24,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 240,
                        child: Image.asset('assets/LoginImage.png'),
                      ),
                      const Spacer(), // pushes the white container to bottom
                      // bottom white sheet
                      Container(
                        width: double.infinity,
                        // make sure the container doesn't exceed available height
                        // and remains scrollable on small screens
                        padding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 24,
                        ),
                        decoration: const BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min, // shrink to fit
                          children: [
                            const Text(
                              "Email Id",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: AppColors.black87,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.inputField,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: TextField(
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.done,
                                decoration: const InputDecoration(
                                  hintText: 'Enter your email',
                                  border: InputBorder.none,
                                ),
                                onSubmitted: (_) {
                                  if (!isLoading) _sendOtp();
                                },
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "We don't share your email",
                              style: TextStyle(
                                color: AppColors.otpBorder,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 16),
                            GradientButton(
                              text: _submitting ? 'Sending OTP...' : 'Log In',
                              onPressed: _submitting
                                  ? null
                                  : () {
                                      if (!isLoading) _sendOtp();
                                    },
                              buttonText: '',
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  print(
                                    '🔐 Login Screen: Navigating to signup',
                                  );
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.signup,
                                  );
                                },
                                child: const Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    color: AppColors.black87,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

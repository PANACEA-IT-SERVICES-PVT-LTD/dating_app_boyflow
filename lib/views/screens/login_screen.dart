import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
import '../../core/routes/app_routes.dart';
import '../../utils/colors.dart';
import '../../widgets/gradient_button.dart';
// import '../../controllers/api_controller.dart';
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
      final url = Uri.parse("${ApiEndPoints.baseUrl}${ApiEndPoints.loginMale}");
      final resp = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      dynamic body;
      try {
        body = resp.body.isNotEmpty ? jsonDecode(resp.body) : {};
      } catch (_) {
        body = {"raw": resp.body};
      }

      final success = (body is Map && body["success"] == true);
      final message =
          (body is Map ? body["message"] : null) ??
          (resp.statusCode >= 200 && resp.statusCode < 300
              ? "OTP sent"
              : "Failed to send OTP");

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("✅ $message")));

        if (mounted) {
          Navigator.pushNamed(
            context,
            AppRoutes.loginVerification,
            arguments: <String, dynamic>{
              'email': email,
              'source': 'login',
              if (body['otp'] != null) 'otp': body['otp'].toString(),
            },
          );
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("❌ $message")));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Error: ${e.toString()}")));
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

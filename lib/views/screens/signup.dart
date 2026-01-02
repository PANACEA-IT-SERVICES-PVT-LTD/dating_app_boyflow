// lib/views/screens/signup_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../core/routes/app_routes.dart';
import '../../utils/colors.dart';
import '../../widgets/gradient_button.dart';
import '../../api_service/api_endpoint.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _referralCtrl = TextEditingController();

  bool _submitting = false;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _emailCtrl.dispose();
    _referralCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final firstName = _firstNameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final referral = _referralCtrl.text.trim();

    setState(() => _submitting = true);

    try {
      final url = Uri.parse(
        "${ApiEndPoints.baseUrls}${ApiEndPoints.signupMale}",
      );

      final resp = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "firstName": firstName,
          "email": email,
          "referralCode": referral,
        }),
      );

      dynamic body;
      try {
        body = resp.body.isNotEmpty ? jsonDecode(resp.body) : {};
      } catch (_) {
        body = {};
      }

      final success = body is Map && body["success"] == true;
      final message =
          body["message"] ??
          (success ? "Registration successful" : "Registration failed");

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("✅ $message")));

        Navigator.pushReplacementNamed(
          context,
          AppRoutes.signupVerification,
          arguments: {
            'email': email,
            if (body['otp'] != null) 'otp': body['otp'].toString(),
          },
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("❌ $message")));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Error: $e")));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          /// ================= HEADER =================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(bottom: 6),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.gradientTop, AppColors.gradientBottom],
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 28),
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
                        height: 22,
                        width: 22,
                        color: AppColors.icon,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: screenHeight * 0.14,
                  child: Image.asset('assets/Signup.png', fit: BoxFit.contain),
                ),
              ],
            ),
          ),

          /// ================= FORM =================
          Expanded(
            child: NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (o) {
                o.disallowIndicator();
                return true;
              },
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text(
                            "Register yourself",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Center(
                          child: Text(
                            "Please register or sign up",
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                        const SizedBox(height: 24),

                        /// First Name
                        const Text("First Name"),
                        const SizedBox(height: 8),
                        _buildInput(
                          controller: _firstNameCtrl,
                          hint: "Enter first name",
                          validator: (v) => v == null || v.trim().isEmpty
                              ? "Enter first name"
                              : null,
                        ),

                        const SizedBox(height: 16),

                        /// Email
                        const Text("Email"),
                        const SizedBox(height: 8),
                        _buildInput(
                          controller: _emailCtrl,
                          hint: "Enter email",
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return "Enter email";
                            }
                            if (!RegExp(
                              r'^[^@]+@[^@]+\.[^@]+',
                            ).hasMatch(v.trim())) {
                              return "Enter valid email";
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        /// Referral
                        const Text("Referral Code (optional)"),
                        const SizedBox(height: 8),
                        _buildInput(
                          controller: _referralCtrl,
                          hint: "Enter referral code (if any)",
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          /// ================= BOTTOM =================
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: GradientButton(
                      text: _submitting ? "Registering..." : "Register",
                      onPressed: _submitting ? null : _submit,
                      buttonText: '',
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.login);
                    },
                    child: const Text(
                      "Log In",
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.inputField,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(hintText: hint, border: InputBorder.none),
      ),
    );
  }
}

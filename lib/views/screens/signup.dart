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

    setState(() => _submitting = true);

    try {
      final resp = await http.post(
        Uri.parse("${ApiEndPoints.baseUrls}${ApiEndPoints.signupMale}"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "firstName": _firstNameCtrl.text.trim(),
          "email": _emailCtrl.text.trim(),
          "referralCode": _referralCtrl.text.trim(),
        }),
      );

      final body = resp.body.isNotEmpty ? jsonDecode(resp.body) : {};
      final success = body["success"] == true;
      final message = body["message"] ?? "Something went wrong";

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("✅ $message")));

        Navigator.pushReplacementNamed(
          context,
          AppRoutes.signupVerification,
          arguments: {
            "email": _emailCtrl.text.trim(),
            if (body["otp"] != null) "otp": body["otp"].toString(),
          },
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("❌ $message")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ $e")));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.white,

      /// 🔥 VERY IMPORTANT
      resizeToAvoidBottomInset: false,

      /// ================= BODY =================
      body: Column(
        children: [
          /// HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(bottom: 6),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.gradientTop, AppColors.gradientBottom],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
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

          /// FORM (Scrollable)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
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

                    const Text("First Name"),
                    const SizedBox(height: 8),
                    _input(
                      _firstNameCtrl,
                      "Enter first name",
                      validator: (v) => v == null || v.trim().isEmpty
                          ? "Enter first name"
                          : null,
                    ),

                    const SizedBox(height: 16),

                    const Text("Email"),
                    const SizedBox(height: 8),
                    _input(
                      _emailCtrl,
                      "Enter email",
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return "Enter email";
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                          return "Enter valid email";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    const Text("Referral Code (optional)"),
                    const SizedBox(height: 8),
                    _input(_referralCtrl, "Enter referral code"),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      /// ================= FIXED BOTTOM =================
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
    );
  }

  Widget _input(
    TextEditingController ctrl,
    String hint, {
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
        controller: ctrl,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(hintText: hint, border: InputBorder.none),
      ),
    );
  }
}

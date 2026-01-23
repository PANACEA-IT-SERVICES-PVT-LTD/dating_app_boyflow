import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/api_controller.dart';
import '../../core/routes/app_routes.dart';
import '../../utils/colors.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/otp_input_fields.dart';
import '../../utils/token_helper.dart';
import '../screens/main_navigation.dart';

class SignupVerificationScreen extends StatefulWidget {
  final String? email;
  final String? otp;

  const SignupVerificationScreen({super.key, this.email, this.otp});

  @override
  State<SignupVerificationScreen> createState() =>
      _SignupVerificationScreenState();
}

class _SignupVerificationScreenState extends State<SignupVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.otp != null && widget.otp!.length == 4) {
      for (int i = 0; i < 4; i++) {
        _otpControllers[i].text = widget.otp![i];
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length != 4) {
      setState(() => _errorMessage = 'Please enter the complete OTP');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiController = Provider.of<ApiController>(context, listen: false);
      // Call verifyOtp and get the response body for token extraction
      final endpoint = 'signup';
      // Use ApiController.verifyOtp, but also get the token from the controller if available
      final success = await apiController.verifyOtp(otp, source: endpoint);

      // Try to get token from controller (if set)
      final token = apiController.authToken;
      if (success && token != null && token.isNotEmpty) {
        await saveLoginToken(token);
      }

      if (mounted) {
        if (success) {
          // After successful signup OTP, navigate directly to dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainNavigationScreen()),
          );
        } else {
          setState(() => _errorMessage = 'Invalid OTP. Please try again.');
        }
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error verifying OTP: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: mq.size.height * 0.4,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.gradientTop, AppColors.gradientBottom],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Verify your email",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: AppColors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Enter the 4-digit OTP sent to ${widget.email ?? ''}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.black54,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // ...existing code...
                    OtpInputFields(
                      onCompleted: (otp) {
                        for (
                          int i = 0;
                          i < otp.length && i < _otpControllers.length;
                          i++
                        ) {
                          _otpControllers[i].text = otp[i]
                              .toString(); // <-- FIX: ensure String
                        }
                        _verifyOtp();
                      },
                    ),
                    // ...existing code...
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                    const SizedBox(height: 32),
                    GradientButton(
                      text: _isLoading ? "Verifying..." : "Verify OTP",
                      onPressed: _isLoading ? null : _verifyOtp,
                      buttonText: '',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

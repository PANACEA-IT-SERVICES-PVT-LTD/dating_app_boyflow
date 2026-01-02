import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/api_controller.dart';
import '../../core/routes/app_routes.dart';
// Removed unused imports
import '../../widgets/gradient_button.dart';
import '../../widgets/otp_input_fields.dart';

class LoginVerificationScreen extends StatefulWidget {
  final String? email;
  final String? otp;

  const LoginVerificationScreen({super.key, this.email, this.otp});

  @override
  State<LoginVerificationScreen> createState() =>
      _LoginVerificationScreenState();
}

class _LoginVerificationScreenState extends State<LoginVerificationScreen> {
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
      final success = await apiController.verifyOtp(otp, source: 'login');

      if (mounted) {
        if (success) {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
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

  void _resendOtp() {
    // Implement resend OTP logic here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OTP has been resent to your email')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Verify your email",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Enter the 4-digit OTP sent to ${widget.email ?? ''}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, color: Colors.black54),
                ),
                const SizedBox(height: 32),
                OtpInputFields(
                  onCompleted: (otp) {
                    for (
                      int i = 0;
                      i < otp.length && i < _otpControllers.length;
                      i++
                    ) {
                      _otpControllers[i].text = otp[i].toString();
                    }
                    _verifyOtp();
                  },
                ),
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
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: _resendOtp,
                  child: const Text(
                    "Resend OTP",
                    style: TextStyle(
                      color: Colors.purple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

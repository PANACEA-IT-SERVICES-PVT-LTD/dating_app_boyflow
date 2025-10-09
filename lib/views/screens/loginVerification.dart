// lib/views/screens/login_verification.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/routes/app_routes.dart';
import '../../utils/colors.dart';
import '../../widgets/gradient_button.dart';
import '../../controllers/api_controller.dart';
import '../../widgets/otp_input_fields.dart'; // <-- your OTP input widget

class LoginVerificationScreen extends StatefulWidget {
  const LoginVerificationScreen({super.key});

  @override
  State<LoginVerificationScreen> createState() =>
      _LoginVerificationScreenState();
}

class _LoginVerificationScreenState extends State<LoginVerificationScreen> {
  String? _email;
  String? _mobile;
  String? _source;
  String _otp = "";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _email = args?['email'] as String?;
    _mobile = args?['mobile'] as String?;
    _source = args?['source'] as String?;
  }

  Future<void> _verifyOtp() async {
    final api = Provider.of<ApiController>(context, listen: false);
    if (_otp.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter the OTP')));
      return;
    }

    final ok = await api.verifyOtp(otp: _otp);
    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('✅ OTP verified!')));
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false);
    } else {
      final msg = api.error ?? 'OTP verification failed';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Future<void> _resendOtp() async {
    if (_email == null || _email!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email not available to resend OTP.')),
      );
      return;
    }
    final api = Provider.of<ApiController>(context, listen: false);
    final ok = await api.requestLoginOtp(email: _email!);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP resent to your email.')),
      );
    } else {
      final msg = api.error ?? 'Failed to resend OTP';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: true,
      body: Consumer<ApiController>(
        builder: (context, api, _) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // 🌈 Gradient header area
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(bottom: 180),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,

                      colors: [AppColors.gradientTop, AppColors.gradientBottom],
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 20,
                          left: 15,
                          right: 15,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Back arrow
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Icon(
                                Icons.arrow_back_ios,
                                color: AppColors.white,
                              ),
                            ),
                            // Shield icon
                            Image.asset(
                              'assets/sheild.png',
                              height: 24,
                              width: 24,
                              color: AppColors.white,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 280,
                        child: Image.asset(
                          'assets/Otp.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),

                // 🧾 White bottom section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 30,
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Verify OTP",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Please enter the OTP and verify",
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.black54,
                        ),
                      ),
                      const SizedBox(height: 25),

                      // ✅ OTP input boxes
                      OtpInputFields(
                        onCompleted: (otp) {
                          setState(() => _otp = otp);
                        },
                      ),

                      const SizedBox(height: 30),

                      // Verify button
                      GradientButton(
                        text: api.isLoading ? 'Verifying...' : 'Verify OTP',
                        onPressed: () {
                          if (!api.isLoading) _verifyOtp();
                        },
                      ),
                      const SizedBox(height: 12),

                      // Resend option
                      TextButton(
                        onPressed: api.isLoading ? null : _resendOtp,
                        child: const Text(
                          'Resend OTP',
                          style: TextStyle(
                            color: AppColors.link,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

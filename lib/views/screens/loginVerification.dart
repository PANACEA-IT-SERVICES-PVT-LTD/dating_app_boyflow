import 'package:Boy_flow/views/screens/earnings_screen.dart';
import 'package:Boy_flow/views/screens/mainhome.dart';
import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
import '../../core/routes/app_routes.dart';
import '../../utils/colors.dart';
import '../../widgets/gradient_button.dart';
// import '../../controllers/api_controller.dart';
import '../../widgets/otp_input_fields.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../api_service/api_endpoint.dart';

class LoginVerificationScreen extends StatefulWidget {
  const LoginVerificationScreen({super.key});

  @override
  State<LoginVerificationScreen> createState() =>
      _LoginVerificationScreenState();
}

class _LoginVerificationScreenState extends State<LoginVerificationScreen> {
  String? _email;
  String? _mobile;
  String? _source; // "login" or "signup"
  String _otp = "";
  bool _submitting = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _email = (args?['email'] as String?)?.trim();
    _mobile = (args?['mobile'] as String?)?.trim();
    _source = (args?['source'] as String?)?.trim().toLowerCase() ?? "login";
  }

  Future<void> _verifyOtp() async {
    final otp = _otp.trim();
    if (otp.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter the OTP')));
      return;
    }

    setState(() => _submitting = true);
    try {
      final endpoint = (_source == 'login')
          ? ApiEndPoints.loginotpMale
          : ApiEndPoints.verifyOtpMale;
      final url = Uri.parse("${ApiEndPoints.baseUrls}$endpoint");
      final numericOtp = RegExp(r'^\d+$').hasMatch(otp) ? int.parse(otp) : otp;
      final payload = <String, dynamic>{
        "otp": numericOtp,
        if (_email != null && _email!.trim().isNotEmpty) "email": _email!.trim(),
        if (_mobile != null && _mobile!.trim().isNotEmpty)
          "mobileNumber": _mobile!.trim(),
        if (_source != null && _source!.trim().isNotEmpty)
          "source": _source!.trim(),
        if (_email != null && _email!.trim().isNotEmpty)
          "channel": "email"
        else if (_mobile != null && _mobile!.trim().isNotEmpty)
          "channel": "mobile",
      };
      final resp = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      dynamic body;
      try {
        body = resp.body.isNotEmpty ? jsonDecode(resp.body) : {};
      } catch (_) {
        body = {"raw": resp.body};
      }

      final success = (body is Map && body["success"] == true);
      final message = (body is Map ? body["message"] : null) ??
          (resp.statusCode >= 200 && resp.statusCode < 300
              ? 'OTP verified successfully.'
              : 'OTP verification failed');

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ $message')),
        );
        final nextRoute = (_source == 'login')
            ? AppRoutes.home
            : AppRoutes.introduceYourself;
        Navigator.pushNamedAndRemoveUntil(
          context,
          nextRoute,
          (_) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ $message')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _resendOtp() async {
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OTP resent. Please check your inbox.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isLoading = false;

    final mq = MediaQuery.of(context);
    final keyboardInset = mq.viewInsets.bottom;
    final safeHeight = mq.size.height - mq.padding.top - mq.padding.bottom;

    final headerHeight = (safeHeight * 0.90).clamp(180.0, 320.0);

    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: keyboardInset),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: safeHeight),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  // (keep existing UI below exactly as in your file)
                  // ...
                  // The rest of your original layout code goes here unchanged
                  // up to the end of the class.
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
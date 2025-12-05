import 'package:Boy_flow/views/screens/earnings_screen.dart';
import 'package:Boy_flow/views/screens/mainhome.dart';
import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
import '../../core/routes/app_routes.dart';
import '../../utils/colors.dart';
import '../../widgets/gradient_button.dart';
// import '../../controllers/api_controller.dart';
import '../../widgets/otp_input_fields.dart';
import 'dart:async';
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
    // Validate OTP input
    final otp = _otp.trim();
    if (otp.isEmpty) {
      _showError('Please enter the OTP');
      return;
    }

    // Validate that either email or mobile is provided
    if ((_email == null || _email!.trim().isEmpty) && 
        (_mobile == null || _mobile!.trim().isEmpty)) {
      _showError('Email or mobile number is required');
      return;
    }

    setState(() => _submitting = true);

    try {
      // Determine the appropriate endpoint based on the source
      final endpoint = (_source == 'login')
          ? ApiEndPoints.loginotpMale
          : ApiEndPoints.verifyOtpMale;
      
      final url = Uri.parse("${ApiEndPoints.baseUrls}$endpoint");
      
      // Convert OTP to number if it's all digits
      final numericOtp = RegExp(r'^\d+$').hasMatch(otp) ? int.parse(otp) : otp;
      
      // Prepare the request payload
      final payload = <String, dynamic>{
        "otp": numericOtp,
        if (_email != null && _email!.trim().isNotEmpty) "email": _email!.trim(),
        if (_mobile != null && _mobile!.trim().isNotEmpty)
          "mobileNumber": _mobile!.trim(),
        if (_source != null && _source!.trim().isNotEmpty)
          "source": _source!.trim().toLowerCase(),
        if (_email != null && _email!.trim().isNotEmpty)
          "channel": "email"
        else if (_mobile != null && _mobile!.trim().isNotEmpty)
          "channel": "mobile",
      };

      // Make the API request
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 30));

      // Parse the response
      final Map<String, dynamic> responseBody;
      try {
        responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        throw Exception('Invalid server response');
      }

      if (!mounted) return;

      // Handle the response
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final success = responseBody["success"] == true;
        final message = responseBody["message"]?.toString() ?? 'OTP verified successfully';
        
        if (success) {
          _showSuccess(message);
          _navigateAfterVerification();
        } else {
          _showError(message);
        }
      } else {
        final errorMessage = responseBody['message']?.toString() ?? 
            'Server error: ${response.statusCode}';
        _showError(errorMessage);
      }
    } on http.ClientException catch (e) {
      _showError('Network error: ${e.message}');
    } on TimeoutException {
      _showError('Request timed out. Please check your internet connection.');
    } on FormatException {
      _showError('Invalid server response format');
    } catch (e) {
      _showError('An unexpected error occurred: $e');
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

  // Show error message to the user
  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('❌ $message'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Show success message to the user
  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ $message'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Navigate to the appropriate screen after successful verification
  void _navigateAfterVerification() {
    if (!mounted) return;
    
    final nextRoute = (_source == 'login')
        ? AppRoutes.home
        : AppRoutes.introduceYourself;
        
    Navigator.pushNamedAndRemoveUntil(
      context,
      nextRoute,
      (route) => false, // Remove all previous routes
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final keyboardInset = mq.viewInsets.bottom;
    final screenHeight = mq.size.height;
    final screenWidth = mq.size.width;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(bottom: keyboardInset),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
                minWidth: constraints.maxWidth,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top gradient section with illustration - Clean design
                    Container(
                      width: double.infinity,
                      height: screenHeight * 0.5,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFFEF5DA8),
                            const Color(0xFF9E45FF),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(40),
                          bottomRight: Radius.circular(40),
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Gradient overlay
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  const Color(0xFFEF5DA8).withOpacity(0.9),
                                  const Color(0xFF9E45FF).withOpacity(0.9),
                                ],
                              ),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(40),
                                bottomRight: Radius.circular(40),
                              ),
                            ),
                          ),
                          // Main image content
                          SafeArea(
                            child: Center(
                              child: Container(
                                height: screenHeight * 0.4,
                                margin: const EdgeInsets.only(bottom: 20),
                                child: Image.asset(
                                  'assets/Otp.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // OTP Input Section
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 16.0 : 24.0,
                        vertical: 24.0,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Verify OTP',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please enter the OTP and verify',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // OTP Input Fields
                          OtpInputFields(
                            onCompleted: (otp) {
                              setState(() {
                                _otp = otp;
                              });
                              _verifyOtp();
                            },
                          ),
                          
                          SizedBox(height: screenHeight * 0.04),
                          
                          // Verify Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _submitting ? null : _verifyOtp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: EdgeInsets.zero,
                                disabledBackgroundColor: Colors.grey[300],
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFEF5DA8), Color(0xFF9E45FF)],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Container(
                                  alignment: Alignment.center,
                                  child: _submitting
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          'Verify OTP',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Resend OTP Button
                          Center(
                            child: TextButton(
                              onPressed: _submitting ? null : _resendOtp,
                              child: Text(
                                'Resend OTP',
                                style: TextStyle(
                                  color: _submitting 
                                      ? Colors.grey 
                                      : const Color(0xFF9E45FF),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Add flexible space to push content up when keyboard appears
                    if (keyboardInset > 0) SizedBox(height: keyboardInset * 0.5),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
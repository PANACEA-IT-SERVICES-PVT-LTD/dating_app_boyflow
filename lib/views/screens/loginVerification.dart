import 'package:Boy_flow/views/screens/earnings_screen.dart';
import 'package:Boy_flow/views/screens/mainhome.dart';
import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';
import '../../utils/colors.dart';
import '../../widgets/gradient_button.dart';
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
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeFromArguments();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _initializeFromArguments();
    }
  }

  void _initializeFromArguments() {
    if (_isInitialized) return;
    
    try {
      final args = ModalRoute.of(context)?.settings.arguments;
      
      if (args == null) {
        debugPrint('⚠️ No arguments provided to LoginVerificationScreen');
        Navigator.of(context).pop();
        return;
      }
      
      if (args is Map<String, dynamic>) {
        setState(() {
          _email = (args['email'] as String?)?.trim();
          _mobile = (args['mobile'] as String?)?.trim();
          _source = (args['source'] as String?)?.trim().toLowerCase() ?? 'login';
          _isInitialized = true;
        });
        
        if (_email == null && _mobile == null) {
          debugPrint('⚠️ Neither email nor mobile provided to LoginVerificationScreen');
          Navigator.of(context).pop();
        }
      } else {
        debugPrint('⚠️ Invalid arguments type: ${args.runtimeType}');
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('❌ Error initializing LoginVerificationScreen: $e');
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _verifyOtp() async {
    // Validate OTP input
    final otp = _otp.trim();
    if (otp.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter the OTP')));
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
// lib/core/routes/app_routes.dart
// ...existing code...
import 'package:Boy_flow/views/screens/signup_verification.dart';
import 'package:flutter/material.dart';
import 'package:Boy_flow/views/screens/loginVerification.dart';

// Screens
import 'package:Boy_flow/views/screens/login_screen.dart';
// ...existing code...
import 'package:Boy_flow/views/screens/onboardingscreen.dart';
import 'package:Boy_flow/views/screens/verificationfail.dart';
import 'package:Boy_flow/views/screens/signup.dart';
import 'package:Boy_flow/views/screens/mainhome.dart';
import 'package:Boy_flow/views/screens/call_screen.dart';
import 'package:Boy_flow/views/screens/chat_screen.dart';
import 'package:Boy_flow/views/screens/notification_screen.dart';
import 'package:Boy_flow/views/screens/account_screen.dart';
import 'package:Boy_flow/views/screens/help_videos_screen.dart';
import 'package:Boy_flow/views/screens/chat_detail_screen.dart';
import 'package:Boy_flow/views/screens/call_user_details_screen.dart';
import 'package:Boy_flow/views/screens/profile_gallery_screen.dart';
import 'package:Boy_flow/models/female_user.dart';
import 'package:Boy_flow/views/screens/support_service_screen.dart';
import 'package:Boy_flow/views/screens/call_rate_screen.dart';
import 'package:Boy_flow/views/screens/withdraws_screen.dart';
import 'package:Boy_flow/views/screens/followers_screen.dart';
import 'package:Boy_flow/views/screens/earnings_screen.dart';
import 'package:Boy_flow/views/screens/settings_screen.dart';
import 'package:Boy_flow/views/screens/BlocklistScreen.dart';
import 'package:Boy_flow/views/screens/kyc_details_screen.dart';
import 'package:Boy_flow/views/screens/update_kyc_details_screen.dart';
import 'package:Boy_flow/views/screens/withdraw_request_screen.dart';
import 'package:Boy_flow/views/screens/withdraw_confirmation_screen.dart';
import 'package:Boy_flow/views/screens/introduce_yourself_screen.dart';
import 'package:Boy_flow/views/screens/Invite_friends_screen.dart';
import 'package:Boy_flow/views/screens/registration_status.dart';

class AppRoutes {
  static const String login = '/login'; // request OTP (email input)
  static const String home = '/home';
  static const String onboarding = '/onboarding';
  static const String loginVerification = '/loginVerification'; // OTP verify
  static const String verificationFail = '/verificationFail';
  static const String signup = '/signup';
  static const String aboutScreen = '/aboutScreen';
  static const String homepage = '/homepage';
  static const String chatScreen = '/chatScreen';
  static const String callScreen = '/callScreen';
  static const String notificationScreen = '/notificationScreen';
  static const String accountScreen = '/accountScreen';
  static const String helpVideos = '/helpVideos';
  static const String chatDetail = '/chatDetail';
  static const String calluserdetails = '/CallUserDetails';
  static const String profilegallery = '/ProfileGallery';
  static const String callrate = '/Callrate';
  static const String withdraws = '/Withdraws';
  static const String followers = '/Followers';
  static const String earnings = '/Earnings';
  static const String createagency = '/CreateAgency';
  static const String supportservice = '/Supportservice';
  static const String settings = '/Settings';
  static const String blocklistscreen = '/Blocklistscreen';
  static const String kycDetails = '/kycDetails';
  static const String updatekyc = '/Updatekyc';
  static const String withdrawrequest = '/Withdrawrequest';
  static const String withdrawconfirmation = '/Withdrawconfirmation';
  static const String invitefriends = '/Invitefriends';
  static const String introduceYourself = '/IntroduceYourself';
  static const String registrationstatus = '/RegistrationStatus';
  static const String signupVerification = '/signupVerification';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    // Debug: Print route information
    print('🔍 Navigating to: ${settings.name}');
    if (args != null) {
      print('📦 Arguments: $args');
    }

    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case home:
        return MaterialPageRoute(builder: (_) => const MainHome());

      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());

      case loginVerification:
        // Handle OTP verification screen with arguments
        final Map<String, dynamic> routeArgs = args is Map<String, dynamic>
            ? args
            : {};
        return MaterialPageRoute(
          builder: (_) => LoginVerificationScreen(
            email: routeArgs['email'],
            otp: routeArgs['otp'],
          ),
        );

      case verificationFail:
        return MaterialPageRoute(
          builder: (_) => const VerificationFailScreen(),
        );

      case signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case signupVerification:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) =>
              SignupVerificationScreen(email: args['email'], otp: args['otp']),
        );

      case homepage:
        return MaterialPageRoute(builder: (_) => const MainHome());

      case chatScreen:
        return MaterialPageRoute(builder: (_) => const ChatScreen());

      case callScreen:
        return MaterialPageRoute(builder: (_) => const CallScreen());

      case notificationScreen:
        return MaterialPageRoute(builder: (_) => const NotificationScreen());

      case accountScreen:
        return MaterialPageRoute(builder: (_) => const AccountScreen());

      case helpVideos:
        return MaterialPageRoute(builder: (_) => const HelpVideosScreen());

      case registrationstatus:
        return MaterialPageRoute(
          builder: (_) => const RegistrationStatusScreen(),
        );

      case chatDetail:
        if (args is Map<String, String>) {
          return MaterialPageRoute(
            builder: (_) => ChatDetailScreen(
              name: args['name'] ?? 'Unknown',
              img: args['img'] ?? '',
            ),
          );
        }
        return _errorRoute("Invalid arguments for ChatDetailScreen");

      case calluserdetails:
        return MaterialPageRoute(builder: (_) => const CallUserDetailsScreen());

      case profilegallery:
        // TODO: Pass the correct FemaleUser instance here. For now, pass a dummy user or refactor to get user from arguments.
        return MaterialPageRoute(
          builder: (_) => ProfileGalleryScreen(
            user: FemaleUser(
              id: 'demo',
              name: 'Demo',
              age: 0,
              bio: '',
              avatarUrl: '',
            ),
          ),
        );

      case callrate:
        return MaterialPageRoute(builder: (_) => const MyCallRate());

      case withdraws:
        return MaterialPageRoute(builder: (_) => const RewardLevelsScreen());

      case followers:
        return MaterialPageRoute(builder: (_) => const MyFollowersScreen());

      case earnings:
        return MaterialPageRoute(builder: (_) => const MyEarningsScreen());

      case supportservice:
        return MaterialPageRoute(builder: (_) => const SupportServiceScreen());

      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      case blocklistscreen:
        return MaterialPageRoute(builder: (_) => const BlockListScreen());

      case kycDetails:
        return MaterialPageRoute(builder: (_) => const KYCDetailsScreen());

      case updatekyc:
        return MaterialPageRoute(builder: (_) => const UpdateKycScreen());

      case withdrawrequest:
        return MaterialPageRoute(builder: (_) => const WithdrawRequestScreen());

      case withdrawconfirmation:
        return MaterialPageRoute(
          builder: (_) => const WithdrawConfirmationScreen(amount: ''),
        );

      case invitefriends:
        return MaterialPageRoute(builder: (_) => const InviteFriendsScreen());

      case introduceYourself:
        return MaterialPageRoute(
          builder: (_) => const IntroduceYourselfScreen(),
        );

      default:
        return _errorRoute("No route defined for ${settings.name}");
    }
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: Center(child: Text(message)),
      ),
    );
  }
}

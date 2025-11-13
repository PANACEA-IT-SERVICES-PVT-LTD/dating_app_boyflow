// lib/core/routes/app_routes.dart
import 'package:flutter/material.dart';
import 'package:Boy_flow/views/screens/loginVerification.dart';

// Screens
import 'package:Boy_flow/views/screens/login_screen.dart';
import 'package:Boy_flow/views/screens/started.dart';
import 'package:Boy_flow/views/screens/onboardingscreen.dart';
// OTP screen
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
        return MaterialPageRoute(builder: (_) => const mainhome());

      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());

      case loginVerification:
        // OTP screen; pass through any arguments (email/mobile/source)
        return MaterialPageRoute(
          builder: (_) => const LoginVerificationScreen(),
          settings: settings,
        );

      case verificationFail:
        return MaterialPageRoute(
          builder: (_) => const VerificationFailScreen(),
        );

      case signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());

      case homepage:
        return MaterialPageRoute(builder: (_) => const mainhome());

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
        return MaterialPageRoute(builder: (_) => ProfileGalleryScreen());

      case callrate:
        return MaterialPageRoute(builder: (_) => const MyCallRate());

      case withdraws:
        return MaterialPageRoute(builder: (_) => const RewardLevelsScreen());

      case followers:
        return MaterialPageRoute(builder: (_) => const MyFollowersScreen());

      case earnings:
        return MaterialPageRoute(builder: (_) => const MyEarningsScreen());

      // case createagency:
      //   return MaterialPageRoute(builder: (_) => const CreateAgencyScreen());

      case supportservice:
        return MaterialPageRoute(builder: (_) => const SupportServiceScreen());

      // case const settings: // ✅ fixed typo (was: case AppRoutes settings:)
      //   return MaterialPageRoute(builder: (_) => const SettingsScreen());

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
        return MaterialPageRoute(builder: (_) => InviteFriendsScreen());

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

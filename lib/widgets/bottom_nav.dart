import 'package:Boy_flow/api_service/api_service.dart';
import 'package:flutter/material.dart';
import '../views/screens/mainhome.dart';
import '../views/screens/chat_screen.dart';
import '../views/screens/call_screen.dart';
import '../views/screens/notification_screen.dart';
import '../views/screens/account_screen.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNav({super.key, required this.currentIndex});

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget destination;
    switch (index) {
      case 0:
        destination = const mainhome();
        break;
      case 1:
        destination = const ChatScreen();
        break;
      case 2:
        destination = const CallScreen();
        break;
      case 3: 
        destination = const NotificationScreen();
        break;
      case 4:
        destination = const AccountScreen();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => destination,
        transitionDuration: const Duration(milliseconds: 0),
        reverseTransitionDuration: const Duration(milliseconds: 0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: (index) => _onTap(context, index),
      selectedItemColor: const Color.fromARGB(255, 255, 85, 204), // Active pink
      unselectedItemColor: Colors.grey,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Chat'),
        BottomNavigationBarItem(icon: Icon(Icons.call), label: 'Call'),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'Notifications',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}

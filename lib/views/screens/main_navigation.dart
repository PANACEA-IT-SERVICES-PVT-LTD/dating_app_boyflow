import 'package:flutter/material.dart';
import 'mainhome.dart';
import 'chat_screen.dart';
import 'call_screen.dart';

import 'notification_screen.dart';
import 'account_screen.dart';
import 'package:provider/provider.dart';
import '../../controllers/api_controller.dart';
import 'login_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    MainHome(),
    ChatScreen(),
    CallScreen(),
    NotificationScreen(),
    AccountScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Set up forced logout callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final apiController = Provider.of<ApiController>(context, listen: false);
      apiController.onForceLogout = _handleForcedLogout;
    });
  }

  @override
  void dispose() {
    // Clean up forced logout callback
    final apiController = Provider.of<ApiController>(context, listen: false);
    if (apiController.onForceLogout == _handleForcedLogout) {
      apiController.onForceLogout = null;
    }
    super.dispose();
  }

  void _handleForcedLogout() {
    // Remove all routes and go to login
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        child: IndexedStack(
          key: ValueKey<int>(_currentIndex),
          index: _currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color.fromARGB(255, 255, 85, 204),
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
      ),
    );
  }
}

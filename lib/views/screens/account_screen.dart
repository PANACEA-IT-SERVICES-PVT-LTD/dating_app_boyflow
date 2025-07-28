import 'package:flutter/material.dart';
import '../../widgets/bottom_nav.dart';

// Screens
import '../screens/profile_gallery_screen.dart';
import '../screens/call_rate_screen.dart';
import '../screens/withdraws_screen.dart';
import '../screens/followers_screen.dart';
import '../screens/earnings_screen.dart';
import '../screens/streamers_screen.dart';
import '../screens/support_service_screen.dart';
import '../screens/settings_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool isOnline = false;

  final List<Map<String, dynamic>> menuItems = [
    {
      'iconPath': 'assets/profile&gallery.png',
      'label': 'My profile & gallery',
      'screen': ProfileGalleryScreen(),
    },
    {
      'iconPath': 'assets/callrate.png',
      'label': 'My Call rate',
      'screen': MyCallRateScreen(),
    },
    {
      'iconPath': 'assets/wallet.png',
      'label': 'My Withdraws',
      'screen': MyWithdrawsScreen(),
    },
    {
      'iconPath': 'assets/followers.png',
      'label': 'My Followers',
      'screen': MyFollowersScreen(),
    },
    {
      'iconPath': 'assets/earnings.png',
      'label': 'My Earnings',
      'screen': MyEarningsScreen(),
    },
    {
      'iconPath': 'assets/profile.png',
      'label': 'My Streamers',
      'screen': MyStreamersScreen(),
    },
    {
      'iconPath': 'assets/supportservice.png',
      'label': 'Support Service',
      'screen': SupportServiceScreen(),
    },
    {
      'iconPath': 'assets/settings.png',
      'label': 'Settings',
      'screen': SettingsScreen(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            "Account",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          actions: [
            const Padding(
              padding: EdgeInsets.only(right: 10),
              child: Center(
                child: Text("Online", style: TextStyle(color: Colors.white)),
              ),
            ),
            Switch(
              value: isOnline,
              onChanged: (val) => setState(() => isOnline = val),
              activeColor: Colors.green,
              inactiveTrackColor: Colors.grey.shade400,
            ),
          ],
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF00CC), Color(0xFF9A00F0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        itemCount: menuItems.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = menuItems[index];
          return ListTile(
            leading: Image.asset(
              item['iconPath'],
              height: 40,
              width: 40,
              fit: BoxFit.contain,
            ),
            title: Text(
              item['label'],
              style: TextStyle(
                color: Colors.grey[800],
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.black),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => item['screen']),
              );
            },
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 4),
    );
  }
}

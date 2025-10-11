import 'package:Boy_flow/views/screens/introduce_yourself_screen.dart';
import 'package:flutter/material.dart';
import '../../widgets/bottom_nav.dart';

// Screens
import '../screens/profile_gallery_screen.dart';
import '../screens/call_rate_screen.dart';
import '../screens/withdraws_screen.dart';
import '../screens/followers_screen.dart';
import '../screens/earnings_screen.dart';
import 'create_agency_screen.dart';
import '../screens/support_service_screen.dart';
import '../screens/settings_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool isOnline = false;
  bool isFollowing = false; // <-- added

  final List<Map<String, dynamic>> menuItems = [
    {
      'iconPath': 'assets/profile&gallery.png',
      'label': 'Talktime Transactions',
      'screen': ProfileGalleryScreen(),
    },
    {
      'iconPath': 'assets/callrate.png',
      'label': 'Talktime',
      'screen': MyCallRateScreen(),
    },
    {
      'iconPath': 'assets/wallet.png',
      'label': 'Levels',
      'screen': MyWithdrawsScreen(),
    },
    {
      'iconPath': 'assets/followers.png',
      'label': 'Blocked & Hidden List',
      'screen': MyFollowersScreen(),
    },
    {
      'iconPath': 'assets/earnings.png',
      'label': 'Report A Problem ',
      'screen': MyEarningsScreen(),
    },
    {
      'iconPath': 'assets/profile.png',
      'label': 'Create Agency',
      'screen': CreateAgencyScreen(),
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

      // Body: fixed top card + scrollable menu
      body: Column(
        children: [
          // Top profile card with shadow and rounded corners
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(
                        'https://i.pravatar.cc/150?img=5',
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Info column
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name + Edit button arranged horizontally but responsive
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Name (flexible, prevents overflow)
                                Flexible(
                                  child: ShaderMask(
                                    shaderCallback: (bounds) => const LinearGradient(
                                      colors: [
                                        Color(0xFFFF55A5),
                                        Color(0xFF9A00F0),
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ).createShader(bounds),
                                    blendMode: BlendMode.srcIn,
                                    child: const Text(
                                      "Shophie92",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.white, // required by ShaderMask
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 8),

                                // Edit button (keeps intrinsic size, won't force row overflow)
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => IntroduceYourselfScreen(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    constraints: const BoxConstraints(
                                      minWidth: 30,
                                      maxWidth: 60,
                                      minHeight: 32,
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFFF55A5),
                                          Color(0xFF9A00F0),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.purple.withOpacity(0.3),
                                          blurRadius: 6,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: const Text(
                                      "Edit",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 6),
                            const Text("Age: 22 years"),
                            const SizedBox(height: 10),
                            const Text(
                              "India",
                              style: TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Optionally add quick actions (edit/view) here
                  ],
                ),
              ),
            ),
          ),

          // The menu list — scrollable
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: Colors.black,
                  ),
                  onTap: () {
                    final Widget screen = item['screen'] as Widget;
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => screen),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      bottomNavigationBar: const CustomBottomNav(currentIndex: 4),
    );
  }
}

/// Small utility widget for gradient text (kept in case you want it later).
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Gradient gradient;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const GradientText(
    this.text, {
    required this.gradient,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return gradient.createShader(
          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
        );
      },
      blendMode: BlendMode.srcIn,
      child: Text(
        text,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        style: (style ?? const TextStyle()).copyWith(color: Colors.white),
      ),
    );
  }
}

import 'package:Boy_flow/views/screens/BlockListScreen1.dart';
import 'package:Boy_flow/views/screens/ReportAProblemPage.dart';
import 'package:Boy_flow/views/screens/TransactionsScreen.dart';
import 'package:Boy_flow/views/screens/introduce_yourself_screen.dart';
import 'package:Boy_flow/views/screens/profile_gallery_screen.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../widgets/bottom_nav.dart';

// Screens
import '../screens/call_rate_screen.dart';
import '../screens/withdraws_screen.dart';
import '../screens/followers_screen.dart';
import '../screens/earnings_screen.dart';
import '../screens/support_service_screen.dart';
import '../screens/settings_screen.dart';
import '../../api_service/api_endpoint.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool isOnline = false;
  bool isFollowing = false; // <-- added

  String? _firstName;
  String? _lastName;
  int? _age;
  String? _bio;
  String? _gender;
  String? _height;
  String? _profileImageUrl;
  bool _loadingProfile = false;

  // Interests (IDs from /male-user/me) + titles from /male-user/interests
  List<String> _interestIds = [];
  Map<String, String> _interestIdToTitle = {};

  final List<Map<String, dynamic>> menuItems = [
    {
      'iconPath': 'assets/profile&gallery.png',
      'label': 'Talktime Transactions',
      'screen': TransactionsScreen(),
    },
    {
      'iconPath': 'assets/callrate.png',
      'label': 'Talktime',
      'screen': MyCallRate(),
    },
    {
      'iconPath': 'assets/wallet.png',
      'label': 'Levels',
      'screen': RewardLevelsScreen(),
    },
    {
      'iconPath': 'assets/followers.png',
      'label': 'Blocked & Hidden List',
      'screen': BlockListScreen1(),
    },
    {
      'iconPath': 'assets/earnings.png',
      'label': 'Report A Problem ',
      'screen': ReportAProblemPage(),
    },
    {
      'iconPath': 'assets/profile.png',
      'label': 'Followers',
      'screen': MyFollowersScreen(),
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
  void initState() {
    super.initState();
    _fetchMaleUserMe();
    _fetchMaleInterests();
  }

  Future<void> _fetchMaleUserMe() async {
    setState(() {
      _loadingProfile = true;
    });

    try {
      final url = Uri.parse(
        "${ApiEndPoints.baseUrls}${ApiEndPoints.maleMe}",
      );

      final resp = await http.get(url);

      dynamic body;
      try {
        body = resp.body.isNotEmpty ? jsonDecode(resp.body) : {};
      } catch (_) {
        body = {"raw": resp.body};
      }

      if (!mounted) return;

      if (body is Map && body["success"] == true && body["data"] is Map) {
        final data = body["data"] as Map<String, dynamic>;

        final dobStr = data["dateOfBirth"]?.toString();
        int? age;
        if (dobStr != null) {
          final dob = DateTime.tryParse(dobStr);
          if (dob != null) {
            final now = DateTime.now();
            age = now.year - dob.year -
                ((now.month < dob.month ||
                        (now.month == dob.month && now.day < dob.day))
                    ? 1
                    : 0);
          }
        }

        setState(() {
          _firstName = data["firstName"]?.toString();
          _lastName = data["lastName"]?.toString();
          _bio = data["bio"]?.toString();
          _gender = data["gender"]?.toString();
          _height = data["height"]?.toString();
          _age = age;

          final images = data["images"];
          if (images is List && images.isNotEmpty) {
            _profileImageUrl = images.first.toString();
          }

          final interests = data["interests"];
          _interestIds = [];
          if (interests is List) {
            _interestIds = interests.map((e) => e.toString()).toList();
          }
        });
      }
    } catch (_) {
      if (!mounted) return;
    } finally {
      if (mounted) {
        setState(() {
          _loadingProfile = false;
        });
      }
    }
  }

  Future<void> _fetchMaleInterests() async {
    try {
      final url = Uri.parse(
        "${ApiEndPoints.baseUrls}${ApiEndPoints.maleInterests}",
      );

      final resp = await http.get(url);

      dynamic body;
      try {
        body = resp.body.isNotEmpty ? jsonDecode(resp.body) : {};
      } catch (_) {
        body = {"raw": resp.body};
      }

      if (!mounted) return;

      if (body is Map && body["success"] == true && body["data"] is List) {
        final list = body["data"] as List;
        setState(() {
          _interestIdToTitle.clear();

          for (final e in list) {
            if (e is Map && e["_id"] != null) {
              final id = e["_id"].toString();
              final title = (e["title"] ?? e["name"] ?? id).toString();
              _interestIdToTitle[id] = title;
            }
          }
        });
      }
    } catch (_) {
      if (!mounted) return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              const Text(
                "Account",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Spacer(),
              Row(
                children: [
                  Image.asset("assets/coins.png", width: 22, height: 22),
                  const SizedBox(width: 4),
                  const Text(
                    "1000",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
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
                      backgroundImage: _profileImageUrl != null
                          ? NetworkImage(_profileImageUrl!)
                          : const NetworkImage(
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
                                    child: Text(
                                      _firstName != null
                                          ? "${_firstName!} ${_lastName ?? ''}".trim()
                                          : "Shophie92",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
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
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => IntroduceYourselfScreen(),
                                      ),
                                    );
                                    // Refresh profile details after editing profile
                                    if (mounted) {
                                      await _fetchMaleUserMe();
                                    }
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
                            Text(
                              _age != null ? "Age: $_age years" : "Age: 22 years",
                            ),
                            const SizedBox(height: 4),
                            if (_gender != null && _gender!.isNotEmpty)
                              Text(
                                "Gender: ${_gender!.substring(0, 1).toUpperCase()}${_gender!.substring(1).toLowerCase()}",
                                style: const TextStyle(color: Colors.black54),
                              ),
                            const SizedBox(height: 8),
                            if (_interestIds.isNotEmpty)
                              Wrap(
                                spacing: 4,
                                runSpacing: 4,
                                children: _interestIds.map((id) {
                                  final title = _interestIdToTitle[id] ?? id;
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.pink.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      title,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.pink,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            const SizedBox(height: 10),
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

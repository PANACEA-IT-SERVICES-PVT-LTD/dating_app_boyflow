import 'package:Boy_flow/views/screens/BlockListScreen1.dart';
import 'package:Boy_flow/views/screens/ReportAProblemPage.dart';
import 'package:Boy_flow/views/screens/TransactionsScreen.dart';
import 'package:Boy_flow/views/screens/WalletTransactionsScreen.dart';
import 'package:Boy_flow/views/screens/introduce_yourself_screen.dart';
// Removed unused import
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// Removed unused import

// Screens
import 'payment_page.dart';
import 'settings_screen.dart';
import 'followers_screen.dart';
import 'call_rate_screen.dart';
import 'withdraws_screen.dart';
import 'support_service_screen.dart';
import '../../api_service/api_endpoint.dart';
import 'coin_packages_sheet.dart';
import '../../services/razorpay_service.dart';

// Global variables

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
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
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const CoinPackagesSheet(),
                  );
                },
                child: Row(
                  children: [
                    Image.asset("assets/coins.png", width: 22, height: 22),
                    const SizedBox(width: 4),
                    Text(
                      _coinBalance?.toString() ?? "0",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
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
      body: _loadingProfile
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
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
                          _profileImageUrl != null &&
                                  _profileImageUrl!.isNotEmpty
                              ? CircleAvatar(
                                  radius: 50,
                                  backgroundImage: NetworkImage(
                                    _profileImageUrl!,
                                  ),
                                )
                              : CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.pink.shade100,
                                  child: const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.white,
                                  ),
                                ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Name and Edit button
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: ShaderMask(
                                          shaderCallback: (bounds) =>
                                              const LinearGradient(
                                                colors: [
                                                  Color(0xFFFF55A5),
                                                  Color(0xFF9A00F0),
                                                ],
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight,
                                              ).createShader(bounds),
                                          blendMode: BlendMode.srcIn,
                                          child: Text(
                                            (_firstName != null &&
                                                    _firstName!.isNotEmpty)
                                                ? "${_firstName!} ${_lastName ?? ''}"
                                                      .trim()
                                                : "",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () async {
                                          final updated = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const IntroduceYourselfScreen(),
                                            ),
                                          );
                                          if (updated == true)
                                            _fetchMaleUserMe();
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFFFF55A5),
                                                Color(0xFF9A00F0),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: const Text(
                                            'Edit',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // Age
                                  if (_age != null)
                                    Text(
                                      'Age: $_age',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  // Gender
                                  if (_gender != null && _gender!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(
                                        'Gender: ${_gender![0].toUpperCase()}${_gender!.substring(1).toLowerCase()}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                                  // Interests
                                  if (_interestIds.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Wrap(
                                        spacing: 4,
                                        runSpacing: 4,
                                        children: _interestIds.map((id) {
                                          final title =
                                              _interestIdToTitle[id] ?? id;
                                          return Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.pink.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(12),
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
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
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
                          if (item['label'] == 'Buy Coins') {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => const CoinPackagesSheet(),
                            );
                          } else {
                            final Widget screen = item['screen'] as Widget;
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => screen),
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
      bottomNavigationBar: Container(height: 0),
    );
  }

  bool isOnline = false;
  bool isFollowing = false; // <-- added
  String? _email;
  String? _status;

  String? _firstName;
  String? _lastName;
  int? _age;
  int? _coinBalance;
  bool _loadingProfile = false;
  String? _profileImageUrl;
  String? _gender;
  int? _walletBalance;

  // Interests (IDs from /male-user/me) + titles from /male-user/interests
  List<String> _interestIds = [];
  Map<String, String> _interestIdToTitle = {};

  final List<Map<String, dynamic>> menuItems = [
    {
      'iconPath': 'assets/profile.png',
      'label': 'Introduce Yourself',
      'screen': IntroduceYourselfScreen(),
    },
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
      'iconPath': 'assets/coins.png',
      'label': 'Buy Coins',
      'screen': const PaymentPage(), // Default payment page or we can trigger sheet
      'onTap': true,
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
    {
      'iconPath': 'assets/wallet.png',
      'label': 'Wallet Transactions',
      'screen': WalletTransactionsScreen(),
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchMaleInterests().then((_) => _fetchMaleUserMe());
  }

  Future<void> _fetchMaleUserMe() async {
    setState(() {
      _loadingProfile = true;
    });

    try {
      final url = Uri.parse("${ApiEndPoints.baseUrl}${ApiEndPoints.maleMe}");

      final prefs = await SharedPreferences.getInstance();
      String? token =
          prefs.getString('token') ?? prefs.getString('access_token') ?? '';
      final resp = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (resp.statusCode == 404) {
        // User profile not found - log error and handle gracefully
        print('Account screen: User profile not found (404)');
        // Optionally redirect to login or show an error message
        if (mounted) {
          // You could show a dialog or snackbar to inform user
          // Or redirect to login screen
        }
        return;
      } else if (resp.statusCode == 401 || resp.statusCode == 403) {
        print('Account screen: Unauthorized access (\${resp.statusCode})');
        return;
      }

      dynamic body;
      try {
        body = resp.body.isNotEmpty ? jsonDecode(resp.body) : {};
      } catch (_) {
        body = {"raw": resp.body};
      }

      if (!mounted) return;

      if (body is Map && body["success"] == true && body["data"] is Map) {
        final data = body["data"] as Map<String, dynamic>;

        setState(() {
          _firstName = data["firstName"]?.toString();
          _lastName = data["lastName"]?.toString();
          _email = data["email"]?.toString();
          _status = data["status"]?.toString();
          _walletBalance = data["walletBalance"] is int
              ? data["walletBalance"]
              : int.tryParse(data["walletBalance"]?.toString() ?? "");
          _coinBalance = data["coinBalance"] is int
              ? data["coinBalance"]
              : int.tryParse(data["coinBalance"]?.toString() ?? "");

          final images = data["images"];
          if (images is List && images.isNotEmpty) {
            _profileImageUrl = images.first.toString();
          } else {
            _profileImageUrl = null;
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
        "${ApiEndPoints.baseUrl}${ApiEndPoints.maleInterests}",
      );
      final prefs = await SharedPreferences.getInstance();
      String? token =
          prefs.getString('token') ?? prefs.getString('access_token') ?? '';
      final resp = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );
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
          _interestIdToTitle = {
            for (var e in list)
              e["_id"].toString(): (e["title"] ?? e["name"] ?? "").toString(),
          };
        });
      }
    } catch (_) {
      if (!mounted) return;
    }
  }

  // (No stray widget code here. All widget code should be inside the build method.)
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

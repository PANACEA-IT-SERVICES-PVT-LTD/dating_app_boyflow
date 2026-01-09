// lib/views/screens/mainhome.dart
import 'package:Boy_flow/api_service/api_endpoint.dart';
import 'package:Boy_flow/controllers/api_controller.dart';
import 'package:Boy_flow/views/screens/call_page.dart';
import 'package:Boy_flow/models/female_user.dart';
import 'package:Boy_flow/views/screens/female_profile_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/user.dart' as call_user;
import '../../models/call_state.dart';
import '../../services/call_manager.dart';

class MainHome extends StatefulWidget {
  const MainHome({super.key});

  @override
  State<MainHome> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<MainHome> {
  String _filter = 'All';
  final CallManager _callManager = CallManager();

  // --- Followed profiles state ---
  List<Map<String, dynamic>> _followedProfiles = [];
  bool _isLoadingFollowed = false;
  String? _followedError;

  Future<void> rechargeWallet(int amount) async {
    try {
      final url = Uri.parse(
        ApiEndPoints.baseUrls + ApiEndPoints.maleWalletRecharge,
      );

      // Get auth token from shared preferences
      String? authToken;
      final prefs = await SharedPreferences.getInstance();
      authToken = prefs.getString('token');

      // Prepare headers with authorization
      final headers = {
        'Content-Type': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      };

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({'amount': amount}),
      );
      print('[Recharge] API response: ${response.statusCode} ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Wallet recharged successfully!')),
          );
        } else {
          String errorMessage = data['message'] ?? 'Recharge failed';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Recharge failed: $errorMessage')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('API error: ${response.statusCode}')),
        );
      }
    } on SocketException catch (e) {
      print('[Recharge] Network error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: Please check your connection')),
      );
    } on http.ClientException catch (e) {
      print('[Recharge] Client error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Connection error: $e')));
    } catch (e, st) {
      print('[Recharge] Exception: $e\n$st');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Recharge error: $e')));
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfiles();
      _loadSentFollowRequests();
    });
  }

  Future<void> _loadSentFollowRequests() async {
    try {
      final apiController = Provider.of<ApiController>(context, listen: false);
      await apiController.fetchSentFollowRequests();
    } catch (e) {
      if (mounted) {
        // Only show error if it's not a token error (handled by the controller)
        final errorMessage = e.toString().toLowerCase();
        if (!errorMessage.contains('no valid token') &&
            !errorMessage.contains('please log in again') &&
            !errorMessage.contains('invalid token')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load sent follow requests: $e')),
          );
        }
      }
    }
  }

  Future<void> _loadProfiles() async {
    try {
      final apiController = Provider.of<ApiController>(context, listen: false);
      await apiController.fetchFemaleUsersFromDashboard(
        section: 'all',
        page: 1,
        limit: 10,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load profiles: $e'),
            action: SnackBarAction(label: 'Retry', onPressed: _loadProfiles),
          ),
        );
      }
    }
  }

  // --- Followed profiles fetch method ---
  Future<void> _loadFollowedProfiles() async {
    setState(() {
      _isLoadingFollowed = true;
      _followedError = null;
    });
    try {
      final apiService = Provider.of<ApiController>(
        context,
        listen: false,
      ).apiService;
      final result = await apiService.fetchFollowedFemales(page: 1, limit: 10);
      final results = result['data']?['results'] ?? [];
      setState(() {
        _followedProfiles = List<Map<String, dynamic>>.from(results);
        _isLoadingFollowed = false;
      });
    } catch (e) {
      setState(() {
        _followedError = e.toString();
        _isLoadingFollowed = false;
      });
    }
  }

  List<Map<String, dynamic>> _applyFilter(List<Map<String, dynamic>> profiles) {
    // Add real filter logic if needed
    return profiles;
  }

  void _navigateToFemaleProfile(Map<String, dynamic> profile) {
    // Convert the profile map to a FemaleUser object
    String? imageUrl;
    if (profile['images'] != null &&
        profile['images'] is List &&
        profile['images'].isNotEmpty) {
      final imageList = profile['images'] as List;
      final firstImage = imageList[0];
      if (firstImage is Map<String, dynamic> &&
          firstImage['imageUrl'] != null) {
        imageUrl = firstImage['imageUrl'].toString();
      }
    } else if (profile['avatarUrl'] != null) {
      imageUrl = profile['avatarUrl']?.toString();
    }

    final femaleUser = FemaleUser(
      id: profile['_id']?.toString() ?? '',
      name: profile['name']?.toString() ?? 'Unknown',
      age: int.tryParse(profile['age']?.toString() ?? '0') ?? 0,
      bio: profile['bio']?.toString() ?? '',
      avatarUrl: imageUrl ?? '',
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FemaleProfileScreen(user: femaleUser)),
    );
  }

  Future<void> _startCall({
    required bool isVideo,
    required Map<String, dynamic> profile,
  }) async {
    if (kIsWeb) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Calls are only available on mobile/desktop builds.'),
        ),
      );
      return;
    }

    final user = call_user.User(
      id: (profile['_id'] ?? profile['name']).toString(),
      name: profile['name']?.toString() ?? 'Unknown',
      isOnline: true,
    );

    final type = isVideo ? CallType.video : CallType.audio;

    try {
      await _callManager.initiateCall(user, type);
      final callInfo = _callManager.currentCall;
      if (!mounted || callInfo == null) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CallPage(
            channelName: callInfo.channelName,
            enableVideo: callInfo.type == CallType.video,
            isInitiator: true,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to start call: $e')));
    }
  }

  void _showQuickSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _QuickActionsBottomSheet(
        onRechargePressed: () {
          rechargeWallet(250); // Call the API for 250 coins
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final apiController = Provider.of<ApiController>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F5FF),
      resizeToAvoidBottomInset: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              const Text(
                "Home",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
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
      body: _buildHomeTab(apiController),
      floatingActionButton: SizedBox(
        height: 45,
        width: 135,
        child: FloatingActionButton.extended(
          onPressed: _showQuickSheet,
          icon: const Icon(Icons.shuffle),
          label: const Text('Random'),
          backgroundColor: const Color(0xFFF942A4),
          foregroundColor: Colors.white,
        ),
      ),
      // Navigation handled by MainNavigationScreen
      bottomNavigationBar: Container(height: 0),
    );
  }

  Widget _buildHomeTab(ApiController apiController) {
    if (apiController.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (apiController.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${apiController.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProfiles,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final profiles = _applyFilter(apiController.femaleProfiles);

    if (profiles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No profiles found'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProfiles,
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return SafeArea(
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 14)),
          // Sent Follow Requests Column
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (apiController.sentFollowRequests.isNotEmpty) ...[
                    const Text(
                      'Sent Follow Requests:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...apiController.sentFollowRequests.map((req) {
                      final female = req['femaleUserId'] ?? {};
                      // Fallback: Try name, then email, then ''
                      final name = (female != null)
                          ? (female['name']?.toString() ??
                                female['email']?.toString() ??
                                'Unknown')
                          : 'Unknown';
                      final status = req['status'] ?? 'pending';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Text(
                              status,
                              style: const TextStyle(color: Colors.purple),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ),
          // Filter chips row
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChipWidget(
                      label: 'All',
                      selected: _filter == 'All',
                      onSelected: (v) {
                        setState(() => _filter = 'All');
                      },
                    ),
                    const SizedBox(width: 10),
                    FilterChipWidget(
                      label: 'Follow',
                      selected: _filter == 'Follow',
                      onSelected: (v) {
                        setState(() => _filter = 'Follow');
                      },
                    ),
                    const SizedBox(width: 10),
                    FilterChipWidget(
                      label: 'Near By',
                      selected: _filter == 'Near By',
                      onSelected: (v) {
                        setState(() => _filter = 'Near By');
                      },
                    ),
                    const SizedBox(width: 10),
                    FilterChipWidget(
                      label: 'New',
                      selected: _filter == 'New',
                      onSelected: (v) {
                        setState(() => _filter = 'New');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 10)),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final profile = profiles[index];

              final String name = profile['name']?.toString() ?? '';
              final String bio = profile['bio']?.toString() ?? '';
              final String ageStr = profile['age']?.toString() ?? '';

              return Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, bottom: 16),
                child: _BlockableProfileCard(
                  name: name,
                  badgeImagePath: 'assets/vector.png',
                  imagePath:
                      _getImageUrlFromProfile(profile) ?? 'assets/img_1.png',
                  language: bio.isNotEmpty ? bio : 'Bio not available',
                  age: ageStr,
                  callRate: '10/min',
                  videoRate: '20/min',
                  onCardTap: () => _navigateToFemaleProfile(profile),
                  onAudioCallTap: () =>
                      _startCall(isVideo: false, profile: profile),
                  onVideoCallTap: () =>
                      _startCall(isVideo: true, profile: profile),
                  femaleUserId: profile['_id']?.toString() ?? '',
                  femaleName: name,
                ),
              );
            }, childCount: profiles.length),
          ),
          // Add extra bottom padding to prevent overflow
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

/// Quick sheet and promo card
class _QuickActionsBottomSheet extends StatelessWidget {
  final VoidCallback onRechargePressed;
  const _QuickActionsBottomSheet({required this.onRechargePressed});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.4,
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: true,
          child: Column(
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Expanded(
                child: ListView(
                  children: [_PromoCoinsCard(onPressed: onRechargePressed)],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromoCoinsCard extends StatelessWidget {
  final VoidCallback onPressed;
  const _PromoCoinsCard({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        gradient: const LinearGradient(
          colors: [Color(0xFFF875B6), Color(0xFFFFC6E5)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Limited Time Offer",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/coins.png", width: 26, height: 26),
              const SizedBox(width: 8),
              const Text(
                "FLAT 80% Off",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Image.asset("assets/coins.png", width: 60, height: 60),
          const SizedBox(height: 8),
          const Text(
            "250 Coins",
            style: TextStyle(
              color: Colors.purple,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: "@ Rs.200 ",
                  style: TextStyle(
                    color: Colors.white70,
                    decoration: TextDecoration.lineThrough,
                    fontSize: 14,
                  ),
                ),
                TextSpan(
                  text: "Rs 50",
                  style: TextStyle(
                    color: Colors.pinkAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
                  'Add 250 Coins',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// FilterChip widget
class FilterChipWidget extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const FilterChipWidget({
    required this.label,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const gradient = LinearGradient(
      colors: [Color(0xFFF942A4), Color(0xFF8A34F7)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return GestureDetector(
      onTap: () => onSelected(!selected),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          gradient: selected ? gradient : null,
          color: selected ? null : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: selected
              ? null
              : Border.all(color: Colors.grey.shade300, width: 1.2),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : const Color(0xFF6B3AA8),
          ),
        ),
      ),
    );
  }
}

/// Profile card and helpers
class ProfileCardWidget extends StatelessWidget {
  final String name;
  final String language;
  final String age;
  final String callRate;
  final String videoRate;
  final String imagePath;
  final String badgeImagePath;
  final VoidCallback? onCardTap;
  final VoidCallback? onAudioCallTap;
  final VoidCallback? onVideoCallTap;
  final VoidCallback? onFollowTap;
  final bool isFollowLoading;

  const ProfileCardWidget({
    required this.name,
    required this.language,
    required this.age,
    required this.callRate,
    required this.videoRate,
    required this.imagePath,
    required this.badgeImagePath,
    this.onCardTap,
    this.onAudioCallTap,
    this.onVideoCallTap,
    this.onFollowTap,
    this.isFollowLoading = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onCardTap,
      child: Container(
        // Removed fixed height
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 10,
              spreadRadius: 0.5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              Positioned.fill(child: Image.asset(imagePath, fit: BoxFit.cover)),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.0),
                        Colors.black.withOpacity(0.0),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 87),
                child: Container(
                  // Removed fixed height
                  color: Colors.black12,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            _BadgeImage(imagePath: badgeImagePath),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Language: $language',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$age Yrs',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (onFollowTap != null)
                              ElevatedButton(
                                onPressed: onFollowTap,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.pinkAccent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: isFollowLoading
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : const Text('Follow'),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _RatePill(
                              icon: Icons.call,
                              label: callRate,
                              iconColor: Colors.white,
                              onTap: onAudioCallTap,
                            ),
                            _RatePill(
                              icon: Icons.videocam,
                              label: videoRate,
                              iconColor: Colors.white,
                              onTap: onVideoCallTap,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BadgeImage extends StatelessWidget {
  final String imagePath;
  const _BadgeImage({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: 15,
        height: 15,
        child: Image.asset(
          "assets/vector.png",
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: Colors.black26,
            alignment: Alignment.center,
            child: const Icon(Icons.person, color: Colors.white, size: 16),
          ),
        ),
      ),
    );
  }
}

class _RatePill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final VoidCallback? onTap;

  const _RatePill({
    required this.icon,
    required this.label,
    this.iconColor = Colors.white,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.0),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white, width: 1.2),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 6, right: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Image.asset("assets/coins.png", width: 18, height: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Wrapper widget to manage follow button loading state per card
class _FollowableProfileCard extends StatefulWidget {
  final String name;
  final String language;
  final String age;
  final String callRate;
  final String videoRate;
  final String imagePath;
  final String badgeImagePath;
  final VoidCallback? onCardTap;
  final VoidCallback? onAudioCallTap;
  final VoidCallback? onVideoCallTap;
  final String femaleUserId;
  final String femaleName;

  const _FollowableProfileCard({
    required this.name,
    required this.language,
    required this.age,
    required this.callRate,
    required this.videoRate,
    required this.imagePath,
    required this.badgeImagePath,
    this.onCardTap,
    this.onAudioCallTap,
    this.onVideoCallTap,
    required this.femaleUserId,
    required this.femaleName,
    Key? key,
  }) : super(key: key);

  @override
  State<_FollowableProfileCard> createState() => _FollowableProfileCardState();
}

class _FollowableProfileCardState extends State<_FollowableProfileCard> {
  bool _isLoading = false;

  Future<void> _handleFollow() async {
    if (widget.femaleUserId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid user ID')));
      return;
    }
    setState(() => _isLoading = true);
    final apiController = Provider.of<ApiController>(context, listen: false);
    try {
      await apiController.sendFollowRequest(widget.femaleUserId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Follow request sent to ${widget.femaleName}'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send follow request: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProfileCardWidget(
      name: widget.name,
      badgeImagePath: widget.badgeImagePath,
      imagePath: widget.imagePath,
      language: widget.language,
      age: widget.age,
      callRate: widget.callRate,
      videoRate: widget.videoRate,
      onCardTap: widget.onCardTap,
      onAudioCallTap: widget.onAudioCallTap,
      onVideoCallTap: widget.onVideoCallTap,
      onFollowTap: _isLoading ? null : _handleFollow,
      isFollowLoading: _isLoading,
    );
  }
}

// Updated widget to include block functionality
class _BlockableProfileCard extends StatefulWidget {
  final String name;
  final String language;
  final String age;
  final String callRate;
  final String videoRate;
  final String imagePath;
  final String badgeImagePath;
  final VoidCallback? onCardTap;
  final VoidCallback? onAudioCallTap;
  final VoidCallback? onVideoCallTap;
  final String femaleUserId;
  final String femaleName;

  const _BlockableProfileCard({
    required this.name,
    required this.language,
    required this.age,
    required this.callRate,
    required this.videoRate,
    required this.imagePath,
    required this.badgeImagePath,
    this.onCardTap,
    this.onAudioCallTap,
    this.onVideoCallTap,
    required this.femaleUserId,
    required this.femaleName,
    Key? key,
  }) : super(key: key);

  @override
  State<_BlockableProfileCard> createState() => _BlockableProfileCardState();
}

class _BlockableProfileCardState extends State<_BlockableProfileCard> {
  bool _isLoading = false;
  bool _isBlocking = false;

  Future<void> _handleFollow() async {
    if (widget.femaleUserId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid user ID')));
      return;
    }
    setState(() => _isLoading = true);
    final apiController = Provider.of<ApiController>(context, listen: false);
    try {
      await apiController.sendFollowRequest(widget.femaleUserId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Follow request sent to ${widget.femaleName}'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send follow request: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleBlock() async {
    if (widget.femaleUserId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid user ID')));
      return;
    }

    // Confirm blocking action
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Block user'),
        content: Text(
          'Are you sure you want to block ${widget.femaleName}? '
          'This will remove all connections.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Block'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isBlocking = true);
      final apiController = Provider.of<ApiController>(context, listen: false);
      try {
        await apiController.blockUser(femaleUserId: widget.femaleUserId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User blocked successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to block user: $e')));
        }
      } finally {
        if (mounted) setState(() => _isBlocking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ProfileCardWidget(
          name: widget.name,
          badgeImagePath: widget.badgeImagePath,
          imagePath: widget.imagePath,
          language: widget.language,
          age: widget.age,
          callRate: widget.callRate,
          videoRate: widget.videoRate,
          onCardTap: widget.onCardTap,
          onAudioCallTap: widget.onAudioCallTap,
          onVideoCallTap: widget.onVideoCallTap,
          onFollowTap: _isLoading ? null : _handleFollow,
          isFollowLoading: _isLoading,
        ),
        Positioned(
          top: 10,
          right: 10,
          child: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (String result) async {
              if (result == 'block') {
                await _handleBlock();
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'block',
                child: Row(
                  children: [
                    const Icon(Icons.block, color: Colors.red),
                    const SizedBox(width: 8),
                    Text('Block User', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

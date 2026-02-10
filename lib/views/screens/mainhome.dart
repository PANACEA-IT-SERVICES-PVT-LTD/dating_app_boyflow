// lib/views/screens/mainhome.dart
import 'package:Boy_flow/api_service/api_endpoint.dart';
import 'package:Boy_flow/controllers/api_controller.dart';
import 'package:Boy_flow/models/female_user.dart';
import 'package:Boy_flow/views/screens/female_profile_screen.dart';
import 'package:Boy_flow/views/screens/call_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

class MainHome extends StatefulWidget {
  const MainHome({super.key});

  @override
  State<MainHome> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<MainHome> {
  void _showDebug(String msg) {
    // ignore: avoid_print
    print('[DEBUG] $msg');
  }

  // UI-level loading timeout
  bool _uiLoadingTimeout = false;
  Timer? _loadingTimer;
  String _filter = 'All';

  // --- Followed profiles state ---
  List<Map<String, dynamic>> _followedProfiles = [];
  bool _isLoadingFollowed = false;
  String? _followedError;

  String? _getImageUrlFromProfile(Map<String, dynamic> profile) {
    // Check if there are images in the profile
    if (profile['images'] != null &&
        profile['images'] is List &&
        profile['images'].length > 0) {
      // Return the first image URL if available
      final firstImage = profile['images'][0];
      if (firstImage is String) {
        return firstImage;
      } else if (firstImage is Map && firstImage['imageUrl'] != null) {
        return firstImage['imageUrl'];
      }
    }

    // Check for avatarUrl field
    if (profile['avatarUrl'] != null &&
        profile['avatarUrl'] is String &&
        profile['avatarUrl'].isNotEmpty) {
      return profile['avatarUrl'];
    }

    // Check for avatar field
    if (profile['avatar'] != null &&
        profile['avatar'] is String &&
        profile['avatar'].isNotEmpty) {
      return profile['avatar'];
    }

    // Check for image field
    if (profile['image'] != null &&
        profile['image'] is String &&
        profile['image'].isNotEmpty) {
      return profile['image'];
    }

    // Check for profilePic field
    if (profile['profilePic'] != null &&
        profile['profilePic'] is String &&
        profile['profilePic'].isNotEmpty) {
      return profile['profilePic'];
    }

    // Check for profilePicture field
    if (profile['profilePicture'] != null &&
        profile['profilePicture'] is String &&
        profile['profilePicture'].isNotEmpty) {
      return profile['profilePicture'];
    }

    return null;
  }

  // --- Followed profiles methods ---
  Future<void> _loadFollowedProfiles() async {
    if (!mounted) return;
    setState(() {
      _isLoadingFollowed = true;
      _followedError = null;
    });

    try {
      final apiController = Provider.of<ApiController>(context, listen: false);
      final List<Map<String, dynamic>> profiles = await apiController
          .fetchFollowedFemales(page: 1, limit: 20);

      if (mounted) {
        setState(() {
          _followedProfiles = profiles;
          _isLoadingFollowed = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingFollowed = false;
          _followedError = e.toString();
        });
      }
    }
  }

  void _startUILoadingTimeout() {
    _loadingTimer?.cancel();
    _uiLoadingTimeout = false;
    _loadingTimer = Timer(const Duration(seconds: 30), () {
      if (mounted) {
        setState(() {
          _uiLoadingTimeout = true;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // Load initial profiles immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialProfiles();
      _loadFollowedProfiles();
    });
    
    // Listen to API controller to refresh UI when profiles change
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final apiController = Provider.of<ApiController>(context, listen: false);
      apiController.addListener(_onProfilesChanged);
      apiController.fetchSentFollowRequests(); // Initial fetch of follow requests
    });
  }
  
  void _onProfilesChanged() {
    // Use post-frame callback with delay to ensure stability
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              // Force UI refresh when profiles change
              // This prevents rapid updates that cause flickering
            });
          }
        });
      }
    });
  }
  
  @override
  void dispose() {
    // Check if we're still mounted before removing listener
    if (mounted) {
      final apiController = Provider.of<ApiController>(context, listen: false);
      apiController.removeListener(_onProfilesChanged);
    }
    super.dispose();
  }

  Future<void> _loadInitialProfiles() async {
    try {
      final apiController = Provider.of<ApiController>(context, listen: false);
      await apiController.fetchDashboardSectionFemales(section: 'all', page: 1, limit: 20);
    } catch (e) {
      print('Error loading initial profiles: $e');
    }
  }

  Future<void> _showCallTypePopup(Map<String, dynamic> profile) async {
    if (mounted) {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Call ${profile['name'] ?? 'User'}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCallOption(
                    icon: Icons.call,
                    label: 'Audio Call',
                    color: Colors.green,
                    onTap: () => _startCall(profile, 'audio'),
                  ),
                  _buildCallOption(
                    icon: Icons.videocam,
                    label: 'Video Call',
                    color: Colors.purple,
                    onTap: () => _startCall(profile, 'video'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildCallOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Future<void> _startCall(Map<String, dynamic> profile, String callType) async {
    if (mounted) {
      Navigator.pop(context); // Close the bottom sheet
      
      // Navigate to call screen
      if (mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CallScreen(
              channelName: 'friends_call',
              callType: callType,
              receiverName: profile['name'] ?? 'Unknown',
            ),
          ),
        );
      }
    }
  }

  void _showQuickSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _QuickActionsBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final apiController = Provider.of<ApiController>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F5FF),
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
      bottomNavigationBar: Container(height: 0),
    );
  }

  Widget _buildHomeTab(ApiController apiController) {
    if (apiController.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (apiController.error != null) {
      return Center(child: Text('Error: ${apiController.error}'));
    }

    final profiles = _applyFilter(apiController.femaleProfiles);

    // Debug logging
    print('=== PROFILE DEBUG ===');
    print('Filter: $_filter');
    print('All profiles count: ${apiController.femaleProfiles.length}');
    print('Followed profiles count: ${_followedProfiles.length}');
    print('Filtered profiles count: ${profiles.length}');
    print('API Controller profiles reference: ${apiController.femaleProfiles.hashCode}');
    print('Local _followedProfiles reference: ${_followedProfiles.hashCode}');
    
    // Auto-refresh if profiles disappear
    if (apiController.femaleProfiles.isEmpty && _filter == 'All') {
      print('[AUTO-REFRESH] Profiles disappeared, attempting refresh...');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        apiController.refreshProfiles();
      });
    }
    
    print('=====================');

    if (profiles.isEmpty && _filter == 'All' && apiController.femaleProfiles.isNotEmpty) {
      // Fallback to all profiles if filter returns empty but all profiles exist
      return CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 14)),
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
                    const SizedBox(width: 8),
                    FilterChipWidget(
                      label: 'Follow',
                      selected: _filter == 'Follow',
                      onSelected: (v) {
                        setState(() => _filter = 'Follow');
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChipWidget(
                      label: 'New',
                      selected: _filter == 'New',
                      onSelected: (v) {
                        setState(() => _filter = 'New');
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChipWidget(
                      label: 'Near By',
                      selected: _filter == 'Near By',
                      onSelected: (v) {
                        setState(() => _filter = 'Near By');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(top: 10),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index >= apiController.femaleProfiles.length) {
                    return null;
                  }
                  final profile = apiController.femaleProfiles[index];
                  final bio = profile['bio']?.toString() ?? '';
                  final age = profile['age'];
                  String ageStr = '';
                  if (age is int) {
                    ageStr = age.toString();
                  } else if (age is String) {
                    ageStr = age;
                  } else {
                    ageStr = 'N/A';
                  }
                  final followStatus = apiController.getFollowStatus(profile['_id'] ?? '');
                  return ProfileCardWidget(
                    name: profile['name'] ?? 'Unknown',
                    language: bio.isNotEmpty ? bio : 'Bio not available',
                    age: ageStr,
                    imagePath: _getImageUrlFromProfile(profile) ?? 'assets/img_1.png',
                    callRate: profile['callRate']?.toString() ?? '10/min',
                    videoRate: profile['videoRate']?.toString() ?? '20/min',
                    badgeImagePath: '',
                    followStatus: followStatus,
                    onFollowTap: () async {
                      try {
                        if (followStatus == 'none') {
                          await apiController.sendFollowRequest(profile['_id']);
                        } else if (followStatus == 'pending') {
                          await apiController.cancelFollowRequest(profile['_id']);
                        } else if (followStatus == 'following') {
                          await apiController.unfollowUser(profile['_id']);
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                          );
                        }
                      }
                    },
                    onCardTap: () {
                      _showCallTypePopup(profile);
                    },
                    onAudioCallTap: () {
                      _showCallTypePopup(profile);
                    },
                    onVideoCallTap: () {
                      _showCallTypePopup(profile);
                    },
                  );
                },
                childCount: apiController.femaleProfiles.length,
              ),
            ),
          ),
        ],
      );
    } else if (profiles.isEmpty) {
      return const Center(child: Text('No profiles found'));
    }

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: 14)),
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
              child: ProfileCardWidget(
                name: name,
                badgeImagePath: 'assets/vector.png',
                imagePath: _getImageUrlFromProfile(profile) ?? 'assets/img_1.png',
                language: bio.isNotEmpty ? bio : 'Bio not available',
                age: ageStr,
                callRate: profile['callRate']?.toString() ?? '10/min',
                videoRate: profile['videoRate']?.toString() ?? '20/min',
                followStatus: apiController.getFollowStatus(profile['_id'] ?? ''),
                onFollowTap: () async {
                  try {
                    final status = apiController.getFollowStatus(profile['_id'] ?? '');
                    if (status == 'none') {
                      await apiController.sendFollowRequest(profile['_id']);
                    } else if (status == 'pending') {
                      await apiController.cancelFollowRequest(profile['_id']);
                    } else if (status == 'following') {
                      await apiController.unfollowUser(profile['_id']);
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                      );
                    }
                  }
                },
                onCardTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FemaleProfileScreen(
                        user: FemaleUser.fromJson(profile),
                      ),
                    ),
                  );
                },
                onAudioCallTap: () {
                  // Calls removed - show message
                  _showCallTypePopup(profile);
                },
                onVideoCallTap: () {
                  // Calls removed - show message
                  _showCallTypePopup(profile);
                },
              ),
            );
          }, childCount: profiles.length),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _applyFilter(List<Map<String, dynamic>> allProfiles) {
    if (_filter == 'Follow') {
      // Show followed profiles
      return _followedProfiles;
    } else if (_filter == 'All') {
      return allProfiles;
    } else if (_filter == 'Near By') {
      // Return nearby profiles (same as all for now)
      return allProfiles;
    } else if (_filter == 'New') {
      // Return new profiles (same as all for now)
      return allProfiles;
    }
    return allProfiles;
  }
}

/// Quick sheet and promo card
class _QuickActionsBottomSheet extends StatelessWidget {
  const _QuickActionsBottomSheet({super.key});

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
                child: ListView(children: [_PromoCoinsCard(onPressed: () {})]),
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
  final String followStatus;
  final VoidCallback? onCardTap;
  final VoidCallback? onAudioCallTap;
  final VoidCallback? onVideoCallTap;
  final VoidCallback? onFollowTap;

  const ProfileCardWidget({
    required this.name,
    required this.language,
    required this.age,
    required this.callRate,
    required this.videoRate,
    required this.imagePath,
    required this.badgeImagePath,
    this.followStatus = 'none',
    this.onCardTap,
    this.onAudioCallTap,
    this.onVideoCallTap,
    this.onFollowTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onCardTap,
      child: Container(
        height: 200,
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
                  height: 145, // Increased from 130 to prevent overflow with new button
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
                        const Spacer(),
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
                            _FollowButton(
                              status: followStatus,
                              onTap: onFollowTap,
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

class _FollowButton extends StatelessWidget {
  final String status;
  final VoidCallback? onTap;

  const _FollowButton({required this.status, this.onTap});

  @override
  Widget build(BuildContext context) {
    String label = 'Follow';
    IconData icon = Icons.person_add;
    Color color = Colors.white;

    if (status == 'pending') {
      label = 'Pending';
      icon = Icons.hourglass_empty;
      color = Colors.orangeAccent;
    } else if (status == 'following') {
      label = 'Following';
      icon = Icons.person_off; // Option to unfollow
      color = Colors.greenAccent;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color, width: 1.2),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 6, right: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
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

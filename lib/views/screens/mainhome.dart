// lib/views/screens/mainhome.dart
import 'package:boy_flow/api_service/api_endpoint.dart';
import 'package:boy_flow/controllers/api_controller.dart';
import 'package:boy_flow/models/female_user.dart';
import 'package:boy_flow/views/screens/female_profile_screen.dart';
import 'package:boy_flow/views/screens/call_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

import 'package:boy_flow/views/screens/payment_page.dart';

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

  @override
  void initState() {
    super.initState();
    // Load initial profiles immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startUILoadingTimeout();
      _loadStaticData(); // Load static data as fallback
      _loadInitialProfiles();
      _loadFollowedProfiles();
      
      final apiController = Provider.of<ApiController>(context, listen: false);
      apiController.fetchSentFollowRequests(); // Initial fetch of follow requests
    });
  }

  
  
  @override
  void dispose() {
    _loadingTimer?.cancel();
    super.dispose();
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
    print('[DEBUG] _loadProfiles called with filter: $_filter');

    _startUILoadingTimeout();
    try {
      if (_filter == 'Near By') {
        LocationPermission permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Location permission is required for Nearby'),
            ),
          );
          return;
        }
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        await _fetchProfilesByFilter(
          'Near By',
          position.latitude,
          position.longitude,
        );
      } else {
        // Only make one API call per filter change
        await _fetchProfilesByFilter(_filter);
      }
    } catch (e) {
      print('Error loading profiles: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load profiles: $e')));
      }
    }
  }

  void _loadStaticData() {
    print('[DEBUG] _loadStaticData called');
    // Static data based on the API response structure provided
    final staticProfiles = [
      {
        "_id": "696501a81b996e284c122cff",
        "name": "Female E",
        "gender": "female",
        "bio": "Hi there! How are you!",
        "images": [
          {
            "_id": "696519ffe95614370e8b16c8",
            "imageUrl":
                "https://res.cloudinary.com/dqtasamcu/image/upload/v1768233446/admin_uploads/hb3zfycdzk329tgvzkbt.jpg",
          },
        ],
        "onlineStatus": true,
        "age": 23,
      },
      {
        "_id": "695f711c945b800e3a11b9a9",
        "name": "Female D",
        "gender": "female",
        "bio": "Hi there! How are you!",
        "images": [
          {
            "_id": "695f9de94667fdc61869359e",
            "imageUrl":
                "https://res.cloudinary.com/dqtasamcu/image/upload/v1767874001/admin_uploads/nt4wtrvyh9pg4k0h3ll2.jpg",
          },
        ],
        "onlineStatus": true,
        "age": 23,
      },
      {
        "_id": "695b49eca40ac5f37a01913a",
        "name": "Female C",
        "gender": "female",
        "bio": "Hi there!",
        "images": [
          {
            "_id": "695b4a4ca40ac5f37a019140",
            "imageUrl":
                "https://res.cloudinary.com/dqtasamcu/image/upload/v1767590449/admin_uploads/rdri3unpbitymhlbzhqj.jpg",
          },
        ],
        "onlineStatus": true,
        "age": 23,
      },
    ];

    // Update the controller with static data
    final apiController = Provider.of<ApiController>(context, listen: false);
    apiController.setStaticProfiles(staticProfiles);
  }

  List<Map<String, dynamic>> _applyFilter(List<Map<String, dynamic>> profiles) {
    print('[DEBUG] Applying filter: $_filter to ${profiles.length} profiles');

    // For now, return all profiles but log which filter is active
    // In the future, you might want to implement actual filtering logic here
    // based on profile properties like isFollowed, distance, isNew, etc.

    switch (_filter) {
      case 'Follow':
        print(
          '[DEBUG] Filter set to Follow - showing all profiles (implement actual follow filtering)',
        );
        break;
      case 'New':
        print(
          '[DEBUG] Filter set to New - showing all profiles (implement actual new user filtering)',
        );
        break;
      case 'Near By':
        print(
          '[DEBUG] Filter set to Near By - showing all profiles (implement actual location filtering)',
        );
        break;
      case 'All':
      default:
        print('[DEBUG] Filter set to All - showing all profiles');
        break;
    }

    return profiles;
  }

  Future<void> _fetchProfilesByFilter(
    String filter, [
    double? lat,
    double? lng,
  ]) async {
    print('[DEBUG] _fetchProfilesByFilter called with filter: $filter');
    final apiController = Provider.of<ApiController>(context, listen: false);
    try {
      // Clear old profiles before loading new ones
      apiController.clearFemaleProfiles();

      switch (filter) {
        case 'Follow':
          print('[DEBUG] Calling fetchDashboardProfiles with section: follow');
          await apiController.fetchDashboardProfiles(
            section: 'follow',
            page: 1,
            limit: 10,
          );
          break;
        case 'New':
          print('[DEBUG] Calling fetchDashboardProfiles with section: new');
          await apiController.fetchDashboardProfiles(
            section: 'new',
            page: 1,
            limit: 10,
          );
          break;
        case 'Near By':
          print('[DEBUG] Calling fetchDashboardProfiles with section: nearby');
          await apiController.fetchDashboardProfiles(
            section: 'nearby',
            page: 1,
            limit: 10,
            latitude: lat,
            longitude: lng,
          );
          break;
        case 'All':
          print('[DEBUG] Calling fetchDashboardProfiles with section: all');
          await apiController.fetchDashboardProfiles(
            section: 'all',
            page: 1,
            limit: 10,
          );
          break;
        default:
          print(
            '[DEBUG] Calling fetchDashboardProfiles with section: all (default)',
          );
          await apiController.fetchDashboardProfiles(
            section: 'all',
            page: 1,
            limit: 10,
          );
      }
    } catch (e) {
      print('Error loading new females: $e');
      // Only use fallback for specific sections, not 'All'
      if ((_filter == 'New' || _filter == 'Follow' || _filter == 'Near By') &&
          (e.toString().toLowerCase().contains('404') ||
              e.toString().toLowerCase().contains('resource not found'))) {
        print(
          '404 detected for $_filter section, falling back to all profiles',
        );
        try {
          // Only fallback to 'All' section of dashboard API
          await apiController.fetchDashboardProfiles(
            section: 'all',
            page: 1,
            limit: 10,
          );
        } catch (fallbackError) {
          print('Fallback also failed: $fallbackError');
          if (mounted && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Failed to load $_filter users, showing all users: $fallbackError',
                ),
              ),
            );
          }
        }
      } else {
        // For other errors, show the error message
        if (mounted && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load $_filter users: $e')),
          );
        }
      }
    }
  }



  bool _isCallLoading = false;

  Future<void> _startCall(Map<String, dynamic> profile, String callType) async {
    if (_isCallLoading) return;

    if (mounted) {
      Navigator.pop(context); // Close the bottom sheet
    }

    final isVideo = callType == 'video';
    final requiredCoins = isVideo ? 20 : 10;

    final apiController = Provider.of<ApiController>(context, listen: false);
    try {
      final userProfile = await apiController.fetchMaleMe();
      final currentBalance = (userProfile['data'] != null) 
          ? (userProfile['data']['balance'] ?? 0) 
          : 0;

      if (currentBalance < requiredCoins) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Insufficient balance to start call.')),
          );
        }
        return;
      }
    } catch (e) {
      print('Could not fetch balance: $e');
    }

    setState(() {
      _isCallLoading = true;
    });

    try {
      final response = await apiController.startCall(
        receiverId: profile['_id'].toString(),
        callType: callType,
      );

      if (response['success'] == true) {
        final data = response['data'];
        if (mounted) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CallScreen(
                channelName: data['channelName'] ?? data['callId'] ?? 'friends_call',
                callType: callType,
                receiverName: profile['name'] ?? 'Unknown',
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'Failed to start call')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting call: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCallLoading = false;
        });
      }
    }
  }

  // Method to load all females from dashboard API (primary source)
  Future<void> _loadAllFemales() async {
    try {
      final apiController = Provider.of<ApiController>(context, listen: false);

      // Show loading state
      _startUILoadingTimeout();

      // Only make one API call and don't allow interference
      print('[DEBUG] Starting primary profile load from dashboard');
      await apiController.fetchDashboardProfiles(
        section: 'all',
        page: 1,
        limit: 10,
      );
      print('[DEBUG] Primary profile load completed');
    } catch (e) {
      print('Error loading all females from dashboard: $e');

      // Show error message
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load users: $e')));

      }
    }
  }


  void _showQuickSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _QuickActionsBottomSheet(
        onRechargePressed: () {
          // Navigate to PaymentPage for Razorpay integration testing
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PaymentPage()),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final apiController = Provider.of<ApiController>(context);

    // Debug print to see what's happening
    print(
      '[DEBUG] Building MainHome - isLoading: ${apiController.isLoading}, profiles length: ${apiController.femaleProfiles.length}, error: ${apiController.error}',
    );

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
                       if (v) _loadProfiles();
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChipWidget(
                    label: 'Follow',
                    selected: _filter == 'Follow',
                    onSelected: (v) {
                       setState(() => _filter = 'Follow');
                       // No API call needed if we just filter locally, but _loadProfiles can handle it if needed
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChipWidget(
                    label: 'Near By',
                    selected: _filter == 'Near By',
                    onSelected: (v) async {
                         setState(() => _filter = 'Near By');
                         // Location logic from conflict block
                          LocationPermission permission = await Geolocator.requestPermission();
                          if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permission required')));
                            }
                            return;
                          }
                          // Just trigger refresh for now
                          _loadProfiles();
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChipWidget(
                    label: 'New',
                    selected: _filter == 'New',
                    onSelected: (v) {
                       setState(() => _filter = 'New');
                       _loadProfiles();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(10),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final profile = profiles[index];
              final bio = profile['bio']?.toString() ?? '';
              final age = profile['age'];
              String ageStr = (age?.toString()) ?? 'N/A';
              final followStatus = apiController.getFollowStatus(profile['_id'] ?? '');

              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: ProfileCardWidget(
                  name: profile['name'] ?? 'Unknown',
                  language: bio.isNotEmpty ? bio : 'Bio not available',
                  age: ageStr,
                  imagePath: _getImageUrlFromProfile(profile) ?? 'assets/img_1.png',
                  callRate: profile['callRate']?.toString() ?? '10/min',
                  videoRate: profile['videoRate']?.toString() ?? '20/min',
                  badgeImagePath: 'assets/vector.png',
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
                    _navigateToFemaleProfile(profile);
                  },
                  onAudioCallTap: () {
                    _showCallTypePopup(profile);
                  },
                  onVideoCallTap: () {
                    _showCallTypePopup(profile);
                  },
                ),
              );
            }, childCount: profiles.length),
          ),
        ),
      ],
    );
  }



  void _navigateToFemaleProfile(Map<String, dynamic> profile) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FemaleProfileScreen(
            user: FemaleUser.fromJson(profile),
          ),
        ),
      );
  }







  void _showCallTypePopup(Map<String, dynamic> profile) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Start a Call',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.call),
              title: const Text('Audio Call'),
              subtitle: Text('${profile['audioRate'] ?? '10'}/min'),
              onTap: () => _startCall(profile, 'audio'),
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Video Call'),
              subtitle: Text('${profile['videoRate'] ?? '20'}/min'),
              onTap: () => _startCall(profile, 'video'),
            ),
          ],
        ),
      ),
    );
  }

  void _loadInitialProfiles() {
    _loadProfiles();
  }

  void _startUILoadingTimeout() {
    _loadingTimer?.cancel();
    _uiLoadingTimeout = false;
    _loadingTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _uiLoadingTimeout = true;
        });
      }
    });
  }
}

/// Quick sheet and promo card
class _QuickActionsBottomSheet extends StatelessWidget {
  final VoidCallback onRechargePressed;
  const _QuickActionsBottomSheet({super.key, required this.onRechargePressed});

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
                child: ListView(children: [_PromoCoinsCard(onPressed: onRechargePressed)]),
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

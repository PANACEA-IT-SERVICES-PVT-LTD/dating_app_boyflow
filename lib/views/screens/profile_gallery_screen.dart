import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../api_service/api_endpoint.dart';

class ProfileGalleryScreen extends StatefulWidget {
  const ProfileGalleryScreen({super.key});

  @override
  State<ProfileGalleryScreen> createState() => _ProfileGalleryScreenState();
}

class _ProfileGalleryScreenState extends State<ProfileGalleryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5FF),
      appBar: AppBar(
        title: const Text(
          "My Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF00CC), Color(0xFF9A00F0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            onSelected: (value) {
              // handle menu actions
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 0, child: Text("Edit Profile")),
              PopupMenuItem(value: 1, child: Text("Settings")),
              PopupMenuItem(value: 2, child: Text("Logout")),
            ],
          ),
        ],
      ),
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (OverscrollIndicatorNotification overscroll) {
          overscroll.disallowIndicator();
          return true;
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const ClampingScrollPhysics(),
          child: const ProfileTabEditable(),
        ),
      ),
    );
  }
}

class ProfileTabEditable extends StatefulWidget {
  const ProfileTabEditable({super.key});

  @override
  State<ProfileTabEditable> createState() => _ProfileTabEditableState();
}

class _ProfileTabEditableState extends State<ProfileTabEditable> {
  final Map<String, List<String>> profileDetails = {
    "My Languages": [],
    "My Interests": [],
    "Hobbies": [],
    "Travel": [],
  };

  String? _firstName;
  String? _lastName;
  int? _age;
  String? _bio;
  String? _gender;
  String? _height;
  String? _profileImageUrl;
  bool _loadingProfile = false;

  bool isFollowing = false;
  bool isSayHiSelected = false;
  bool isCallSelected = false;

  final Map<String, bool> _isPressed = {'sayhi': false, 'call': false};

  @override
  void initState() {
    super.initState();
    _fetchMaleUserMe();
  }

  Future<void> _fetchMaleUserMe() async {
    setState(() {
      _loadingProfile = true;
    });

    try {
      final url = Uri.parse("${ApiEndPoints.baseUrls}${ApiEndPoints.maleMe}");

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

        int? age;
        final dobStr = data["dateOfBirth"]?.toString();
        if (dobStr != null && dobStr.isNotEmpty) {
          try {
            final dob = DateTime.parse(dobStr);
            final now = DateTime.now();
            age =
                now.year -
                dob.year -
                ((now.month < dob.month ||
                        (now.month == dob.month && now.day < dob.day))
                    ? 1
                    : 0);
          } catch (_) {
            age = null;
          }
        }

        final langs = data["languages"];
        final ints = data["interests"];

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

          profileDetails["My Languages"] = (langs is List)
              ? langs.map((e) => e.toString()).toList()
              : [];
          profileDetails["My Interests"] = (ints is List)
              ? ints.map((e) => e.toString()).toList()
              : [];
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

  Widget _gradientButton(
    String id,
    String text,
    IconData icon, {
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    final gradientColors = [const Color(0xFFFF00CC), const Color(0xFF9A00F0)];
    final bool pressed = _isPressed[id] ?? false;
    final bool showGradient = isSelected || pressed;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (_) {
        setState(() => _isPressed[id] = true);
      },
      onTapUp: (_) {
        onPressed();
        setState(() => _isPressed[id] = false);
      },
      onTapCancel: () => setState(() => _isPressed[id] = false),
      child: AnimatedScale(
        scale: pressed ? 0.985 : 1.0,
        duration: const Duration(milliseconds: 80),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeInOut,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: showGradient
                ? LinearGradient(colors: gradientColors)
                : null,
            color: showGradient ? null : Colors.white,
            border: Border.all(color: const Color(0xFFFF00CC), width: 1.5),
            borderRadius: BorderRadius.circular(20),
            boxShadow: showGradient
                ? [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: showGradient ? Colors.white : const Color(0xFFFF00CC),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  color: showGradient ? Colors.white : const Color(0xFFFF00CC),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: _profileImageUrl != null
                    ? NetworkImage(_profileImageUrl!)
                    : const NetworkImage('https://i.pravatar.cc/150?img=5'),
              ),
              Positioned(
                bottom: -25,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Online",
                          style: TextStyle(
                            color: Colors.green[800],
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFFF55A5), Color(0xFF9A00F0)],
                    ).createShader(bounds),
                    blendMode: BlendMode.srcIn,
                    child: Text(
                      _firstName != null
                          ? "${_firstName!} ${_lastName ?? ''}".trim()
                          : "Shophie92",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        "Age: ",
                        style: TextStyle(color: Colors.black87, fontSize: 12),
                      ),
                      Text(
                        "22 years",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        "257 Followers",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => setState(() => isFollowing = !isFollowing),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF55A5), Color(0xFF9A00F0)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isFollowing ? "Following" : "Follow",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ⬇️ Updated Upside Popup (bottom sheet)
  void _showNotePopup({
    required VoidCallback onCall,
    required VoidCallback onVideo,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0FB),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Text(
                  'Note:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF9A00F0),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please do not trust fraudulent information such as money transfer, lottery etc. from strangers.\n'
                  'Do not share any personal information such as passwords, mobile numbers, or OTPs.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF00CC), Color(0xFF9A00F0)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            onCall();
                          },
                          icon: const Icon(Icons.phone, color: Colors.white),
                          label: const Text(
                            'Call',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF00CC), Color(0xFF9A00F0)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            onVideo();
                          },
                          icon: const Icon(Icons.videocam, color: Colors.white),
                          label: const Text(
                            'Video',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _profileHeaderCard(),
        const SizedBox(height: 24),
        ...profileDetails.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.key,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: entry.value
                      .map(
                        (item) => Chip(
                          label: Text(item),
                          backgroundColor: Colors.pink[50],
                          labelStyle: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          );
        }).toList(),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 140,
              child: _gradientButton(
                'sayhi',
                "Say Hi",
                Icons.chat_bubble_outline,
                isSelected: isSayHiSelected,
                onPressed: () {
                  setState(() {
                    isSayHiSelected = !isSayHiSelected;
                    if (isSayHiSelected) isCallSelected = false;
                  });
                  _showNotePopup(
                    onCall: () => debugPrint('Call pressed from Say Hi'),
                    onVideo: () => debugPrint('Video pressed from Say Hi'),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 140,
              child: _gradientButton(
                'call',
                "Call",
                Icons.phone,
                isSelected: isCallSelected,
                onPressed: () {
                  setState(() {
                    isCallSelected = !isCallSelected;
                    if (isCallSelected) isSayHiSelected = false;
                  });
                  _showNotePopup(
                    onCall: () => debugPrint('Call pressed'),
                    onVideo: () => debugPrint('Video pressed'),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: const ProfileTabEditable(),
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
    "My Languages": ["Telugu"],
    "My Interests": ["Family and parenting", "Society and politics"],
    "Hobbies": ["Cooking", "Writing"],
    "Sports": ["Cricket"],
    "Film": ["No Films"],
    "Music": ["2020s"],
    "Travel": ["Mountains"],
  };

  // selection states
  bool isFollowing = false;
  bool isSayHiSelected = false;
  bool isCallSelected = false;

  // explicit press states for each button id
  final Map<String, bool> _isPressed = {
    'sayhi': false,
    'call': false,
  };

  /// id: 'sayhi' or 'call'
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
        setState(() {
          _isPressed[id] = true;
        });
      },
      onTapUp: (_) {
        // perform the toggle/action first
        onPressed();
        // then clear the pressed visual
        setState(() {
          _isPressed[id] = false;
        });
      },
      onTapCancel: () {
        setState(() {
          _isPressed[id] = false;
        });
      },
      child: AnimatedScale(
        scale: pressed ? 0.985 : 1.0,
        duration: const Duration(milliseconds: 10),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 40),
          curve: Curves.easeInOut,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: showGradient ? LinearGradient(colors: gradientColors) : null,
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
              Icon(icon, color: showGradient ? Colors.white : const Color(0xFFFF00CC), size: 18),
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
          // Avatar + overlapping online badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=5'),
              ),
              Positioned(
                bottom: -25,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
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
          // Right side info: name, age/followers, follow button
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFFF55A5), Color(0xFF9A00F0)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ).createShader(bounds),
                    blendMode: BlendMode.srcIn,
                    child: const Text(
                      "John Borino",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Row(
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
                    onTap: () {
                      setState(() {
                        isFollowing = !isFollowing;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF55A5), Color(0xFF9A00F0)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _profileHeaderCard(),
        const SizedBox(height: 24),

        // Profile detail sections
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
                  children: entry.value.map((item) {
                    return Chip(
                      label: Text(item),
                      backgroundColor: Colors.pink[50],
                      labelStyle: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w400,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        }).toList(),

        const SizedBox(height: 24),

        // Buttons row (in content)
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
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 80), // spacing so content isn't hidden by bottom nav if any
      ],
    );
  }
}

import 'package:Boy_flow/views/screens/login_screen.dart';
import 'package:flutter/material.dart';

class mainhome extends StatefulWidget {
  const mainhome({super.key});

  @override
  State<mainhome> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<mainhome> {
  int _selectedIndex = 0;

  // current filter: 'All', 'Follow', 'Near By'
  String _filter = 'All';

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
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

  // made these dynamic so we can include boolean flags for filtering
  final List<Map<String, dynamic>> profiles = [
    {
      'name': 'Sophie92',
      'language': 'Telugu',
      'age': '22',
      'callRate': '10/min',
      'videoRate': '10/min',
      'image': 'assets/img_1.png',
      'follow': true,
      'nearby': true,
    },
    {
      'name': 'Nisha',
      'language': 'Hindi',
      'age': '23',
      'callRate': '15/min',
      'videoRate': '20/min',
      'image': 'assets/img_1.png',
      'follow': false,
      'nearby': true,
    },
    {
      'name': 'Meera',
      'language': 'Tamil',
      'age': '21',
      'callRate': '8/min',
      'videoRate': '12/min',
      'image': 'assets/img_1.png',
      'follow': true,
      'nearby': false,
    },
  ];

  List<Map<String, dynamic>> get _filteredProfiles {
    if (_filter == 'All') return profiles;
    if (_filter == 'Follow') return profiles.where((p) => p['follow'] == true).toList();
    if (_filter == 'Near By') return profiles.where((p) => p['nearby'] == true).toList();
    return profiles;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5FF),

      // Gradient top bar
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: Container(
          padding: const EdgeInsets.only(top: 40, left: 20, right: 20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF942A4), Color(0xFF8A34F7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Home",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              Row(
                children: [
                  Image.asset(
                    "assets/coins.png",
                    width: 22,
                    height: 22,
                  ),
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
        ),
      ),

      // Body scrollable
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 14)),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                children: [
                  // pass selected state and onSelected
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
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 10)),

          // Profiles as a sliver list (uses filtered list)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final profile = _filteredProfiles[index];
                return Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10, bottom: 16),
                  child: ProfileCardWidget(
                    name: profile['name'] as String,
                    badgeImagePath: profile['image'] as String,
                    imagePath: profile['image'] as String,
                    language: profile['language'] as String,
                    age: profile['age'] as String,
                    callRate: profile['callRate'] as String,
                    videoRate: profile['videoRate'] as String,
                  ),
                );
              },
              childCount: _filteredProfiles.length,
            ),
          ),
        ],
      ),

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

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFFF942A4),
        unselectedItemColor: Colors.grey[400],
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.phone), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ''),
        ],
      ),
    );
  }
}

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
                child: ListView(
                  children: [
                    _PromoCoinsCard(onPressed: () {}),
                  ],
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
            style: TextStyle(color: Colors.purple, fontWeight: FontWeight.w700, fontSize: 20),
          ),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: "@ Rs.200 ",
                  style: TextStyle(color: Colors.white70, decoration: TextDecoration.lineThrough, fontSize: 14),
                ),
                TextSpan(
                  text: "Rs 50",
                  style: TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold, fontSize: 16),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: const Text(
                  'Add 250 Coins',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FilterChipWidget extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const FilterChipWidget({required this.label, required this.selected, required this.onSelected, super.key});

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: selected,
      onSelected: onSelected,
      label: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: selected ? const Color(0xFFF942A4) : const Color(0xFFBA34F7),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      backgroundColor: Colors.pink.shade50,
      selectedColor: Colors.white,
      shape: StadiumBorder(
        side: selected
            ? const BorderSide(color: Color(0xFFF942A4), width: 1.6)
            : const BorderSide(color: Colors.transparent),
      ),
    );
  }
}

class ProfileCardWidget extends StatelessWidget {
  final String name;
  final String language;
  final String age;
  final String callRate;
  final String videoRate;
  final String imagePath;
  final String badgeImagePath;

  const ProfileCardWidget({
    required this.name,
    required this.language,
    required this.age,
    required this.callRate,
    required this.videoRate,
    required this.imagePath,
    required this.badgeImagePath,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
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
                      Colors.black.withOpacity(0.7),
                      Colors.black.withOpacity(0.3),
                      Colors.transparent,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 125),
              child: Container(
                height: 125,
                color: Colors.black38,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                              fontSize: 20,
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
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _RatePill(icon: Icons.call, label: callRate, iconColor: Colors.white),
                          _RatePill(icon: Icons.videocam, label: videoRate, iconColor: Colors.white),
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
    );
  }
}

class _BadgeImage extends StatelessWidget {
  final String imagePath;
  const _BadgeImage({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        width: 20,
        height: 20,
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

/// Centered coin image version
class _RatePill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;

  const _RatePill({
    required this.icon,
    required this.label,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.0),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white, width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 5, right: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
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
    );
  }
}

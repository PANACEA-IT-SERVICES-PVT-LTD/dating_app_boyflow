import 'package:flutter/material.dart';

class MyFollowersScreen extends StatefulWidget {
  const MyFollowersScreen({super.key});

  @override
  State<MyFollowersScreen> createState() => _MyFollowersScreenState();
}

class _MyFollowersScreenState extends State<MyFollowersScreen> {
  bool isOnline = true;
  bool showFollowers = true;

  final List<Map<String, dynamic>> followers = List.generate(7, (_) {
    return {
      'username': 'User12332',
      'age': 25,
      'gender': '♂',
      'level': '01',
      'online': true,
      'avatarUrl': 'https://via.placeholder.com/150',
    };
  });

  final Gradient appGradient = const LinearGradient(
    colors: [Color(0xFFFF00CC), Color(0xFF9A00F0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Followers",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // const Padding(
          //   padding: EdgeInsets.only(right: 10),
          //   child: Center(
          //     child: Text("Online", style: TextStyle(color: Colors.white)),
          //   ),
          // ),
          // Switch(
          //   value: isOnline,
          //   onChanged: (val) => setState(() => isOnline = val),
          //   activeColor: Colors.green,
          //   inactiveTrackColor: Colors.grey.shade400,
          // ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: appGradient),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          // Toggle Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _gradientToggleButton("My Followers", showFollowers, () {
                setState(() => showFollowers = true);
              }),
              const SizedBox(width: 10),
              _gradientToggleButton("My Following", !showFollowers, () {
                setState(() => showFollowers = false);
              }),
            ],
          ),
          const SizedBox(height: 10),
          // List
          Expanded(
            child: ListView.builder(
              itemCount: followers.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (_, index) {
                final user = followers[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(user['avatarUrl']),
                        radius: 30,
                      ),
                      const SizedBox(width: 10),
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  user['username'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _gradientLevelBadge(user['level']),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text("${user['gender']} ${user['age']}"),
                                const SizedBox(width: 8),
                                if (user['online'])
                                  const Text(
                                    "• Online",
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _gradientToggleButton(
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final Gradient gradient = appGradient;

    return Container(
      decoration: BoxDecoration(
        gradient: isSelected ? gradient : null,
        borderRadius: BorderRadius.circular(20),
        border: !isSelected ? Border.all(color: Colors.pink.shade200) : null,
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          foregroundColor: isSelected ? Colors.white : Colors.pink,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.pink,
          ),
        ),
      ),
    );
  }

  Widget _gradientLevelBadge(String level) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        gradient: appGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        level,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
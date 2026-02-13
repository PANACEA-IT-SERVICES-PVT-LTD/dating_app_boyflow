import 'package:flutter/material.dart';
import 'package:boy_flow/widgets/common_top_bar.dart';

class BlockListScreen extends StatefulWidget {
  const BlockListScreen({super.key});

  @override
  State<BlockListScreen> createState() => _BlockListScreenState();
}

class _BlockListScreenState extends State<BlockListScreen> {
  bool isOnline = true;

  List<Map<String, String>> blockedUsers = [
    {'name': 'Alex Linderson', 'id': '3232789', 'image': 'assets/user1.png'},
    {'name': 'Sam Peterson', 'id': '3232790', 'image': 'assets/user1.png'},
    {'name': 'Linda Grey', 'id': '3232791', 'image': 'assets/user1.png'},
    {'name': 'John Doe', 'id': '3232792', 'image': 'assets/user1.png'},
    {'name': 'Jane Smith', 'id': '3232793', 'image': 'assets/user1.png'},
  ];

  void _showUnblockDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Unblock User"),
          content: const Text("Are you sure you want to unblock this user?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // No
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  blockedUsers.removeAt(index); // Remove user from list
                });
                Navigator.pop(context);
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonTopBar(
        title: "Blocked List",
        showCoin: false,
        actions: [
          Row(
            children: [
              const Text("Online", style: TextStyle(color: Colors.white)),
              Switch(
                value: isOnline,
                onChanged: (val) {
                  setState(() {
                    isOnline = val;
                  });
                },
                activeColor: Colors.green,
                inactiveTrackColor: Colors.grey.shade400,
              ),
            ],
          ),
        ],
      ),
      body: blockedUsers.isEmpty
          ? const Center(child: Text("No blocked users."))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: blockedUsers.length,
              itemBuilder: (context, index) {
                final user = blockedUsers[index];
                return GestureDetector(
                  onTap: () => _showUnblockDialog(index),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundImage: AssetImage(user['image']!),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user['name']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "ID: ${user['id']}",
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        const Text(
                          "Unblock",
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

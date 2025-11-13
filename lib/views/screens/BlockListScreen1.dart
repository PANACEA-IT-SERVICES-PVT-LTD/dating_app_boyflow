import 'package:flutter/material.dart';

class BlockListScreen1 extends StatefulWidget {
  const BlockListScreen1({super.key});

  @override
  State<BlockListScreen1> createState() => _BlockListScreenState();
}

class _BlockListScreenState extends State<BlockListScreen1> {
  bool isOnline = true;

  // Dummy data for blocked users (since API removed)
  final List<Map<String, String>> blockedUsers = [
    {'id': '101', 'name': 'John Doe', 'img': ''},
    {'id': '102', 'name': 'Jane Smith', 'img': ''},
    {'id': '103', 'name': 'Michael Johnson', 'img': ''},
  ];

  Future<void> _unblockUser(String id) async {
    if (id.isEmpty) return;

    setState(() {
      blockedUsers.removeWhere((user) => user['id'] == id);
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('User unblocked')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Blocked List",
          style: TextStyle(color: Colors.white),
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
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 8.0),
          //   child: Row(
          //     children: [
          //       const Text("Online", style: TextStyle(color: Colors.white)),
          //       Switch(
          //         value: isOnline,
          //         onChanged: (val) {
          //           setState(() {
          //             isOnline = val;
          //           });
          //         },
          //         activeColor: Colors.green,
          //         inactiveTrackColor: Colors.grey,
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
      body: blockedUsers.isEmpty
          ? const Center(child: Text("No blocked users."))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: blockedUsers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final user = blockedUsers[index];
                final name = user['name'] ?? 'User';
                final id = user['id'] ?? '';
                final img = user['img'] ?? '';

                ImageProvider avatarProvider;
                if (img.trim().isNotEmpty) {
                  avatarProvider = NetworkImage(img);
                } else {
                  avatarProvider = const AssetImage('assets/male_avatar.png');
                }

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundImage: avatarProvider,
                        backgroundColor: Colors.grey.shade200,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'ID: $id',
                              style: const TextStyle(color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: id.isEmpty
                            ? null
                            : () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Unblock user'),
                                    content: Text(
                                      'Are you sure you want to unblock $name?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(ctx).pop(false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(ctx).pop(true),
                                        child: const Text('Unblock'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirmed == true) {
                                  await _unblockUser(id);
                                }
                              },
                        child: const Text(
                          'Unblock',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

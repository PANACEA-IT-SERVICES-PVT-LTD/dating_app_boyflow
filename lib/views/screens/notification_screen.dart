import 'package:flutter/material.dart';
// Removed unused import

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool isOnline = false;

  final List<Map<String, dynamic>> notifications = [
    {
      'title': 'Support Service',
      'message': 'How are you today?',
      'time': '2 min ago',
      'unread': false,
    },
    {
      'title': 'Male Broadcast',
      'message': "Don't miss to attend the meeting.",
      'time': '2 min ago',
      'unread': true,
      'count': 3,
    },
    // {
    //   'title': 'Important',
    //   'message': 'How are you today?',
    //   'time': '2 min ago',
    //   'unread': false,
    // },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            "Notifications",
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            // Padding(
            //   padding: const EdgeInsets.only(right: 10),
            //   child: Center(
            //     child: Text(
            //       isOnline ? "Online" : "Offline",
            //       style: TextStyle(
            //         color: isOnline ? Colors.white : Colors.grey[300],
            //       ),
            //     ),
            //   ),
            // ),
            // Switch(
            //   value: isOnline,
            //   onChanged: (val) => setState(() => isOnline = val),
            //   activeColor: Colors.green,
            //   inactiveTrackColor: Colors.grey.shade400,
            // ),
          ],
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
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: notifications.length,
        itemBuilder: (_, index) {
          final item = notifications[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.only(bottom: 8),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.transparent, // No visible line
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Avatar + Message
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color.fromARGB(255, 243, 75, 243),
                      child: Text(
                        item['title'][0],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['message'],
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),

                // Time and Unread Count
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      item['time'],
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    if (item['unread'] == true)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        child: Text(
                          item['count'].toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Container(height: 0),
    );
  }
}

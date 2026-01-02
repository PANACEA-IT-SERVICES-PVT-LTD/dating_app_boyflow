import 'package:flutter/material.dart';
// Removed unused import
import 'chat_detail_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool isOnline = false;
  String selectedTab = 'Important';

  final List<Map<String, dynamic>> _chatList = const [
    {
      "name": "Alex Linderson",
      "message": "How are you today?",
      "time": "2 min ago",
      "img": "https://i.pravatar.cc/150?img=1",
      "online": false,
      "unread": 0,
    },
    {
      "name": "Team Align",
      "message": "Don't miss to attend the meeting.",
      "time": "2 min ago",
      "img": "https://i.pravatar.cc/150?img=2",
      "online": true,
      "unread": 3,
    },
    {
      "name": "Sabila Sayma",
      "message": "How are you today?",
      "time": "2 min ago",
      "img": "https://i.pravatar.cc/150?img=3",
      "online": false,
      "unread": 1,
    },
    {
      "name": "John Borino",
      "message": "Have a good day 🌸",
      "time": "2 Hrs ago",
      "img": "https://i.pravatar.cc/150?img=4",
      "online": true,
      "unread": 0,
    },
    {
      "name": "Sabila Sayma",
      "message": "How are you today?",
      "time": "9th May",
      "img": "https://i.pravatar.cc/150?img=3",
      "online": false,
      "unread": 0,
    },
    {
      "name": "John Borino",
      "message": "Have a good day 🌸",
      "time": "7th May",
      "img": "https://i.pravatar.cc/150?img=4",
      "online": true,
      "unread": 0,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              const Text(
                "Chats",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
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
      body: ListView.builder(
        itemCount: _chatList.length,
        itemBuilder: (context, index) {
          final chat = _chatList[index];
          return ListTile(
            leading: Stack(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(chat['img']),
                  radius: 28,
                ),
                if (chat['online'])
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        border: Border.all(color: Colors.white, width: 2),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            title: Text(
              chat['name'],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(chat['message']),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  chat['time'],
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                if (chat['unread'] > 0)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      chat['unread'].toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ChatDetailScreen(name: chat['name'], img: chat['img']),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Container(height: 0),
    );
  }
}

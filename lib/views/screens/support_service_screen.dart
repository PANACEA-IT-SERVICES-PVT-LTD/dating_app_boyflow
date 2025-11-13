import 'package:flutter/material.dart';

class SupportServiceScreen extends StatefulWidget {
  const SupportServiceScreen({super.key});

  @override
  State<SupportServiceScreen> createState() => _SupportServiceScreenState();
}

class _SupportServiceScreenState extends State<SupportServiceScreen> {
  final List<String> messages = [
    "1. STREAMER LEVEL: Your level will increase with the coins and the time that you spent.",
    "I mean it's a weekend, so I don’t really have anything else to do.",
    "2. You can get rewards for streaming more frequently!",
    "Feel free to ask us any questions.",
  ];

  bool isOnline = true; // <-- Online status toggle

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        messages.add(text);
      });
      _controller.clear();
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        title: const Text(
          "Support Service",
          style: TextStyle(color: Colors.white),
        ),
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
          // Row(
          //   children: [
          //     Text(
          //       isOnline ? "Online" : "Offline",
          //       style: const TextStyle(color: Colors.white),
          //     ),
          //     Switch(
          //       value: isOnline,
          //       onChanged: (val) {
          //         setState(() {
          //           isOnline = val;
          //         });
          //       },
          //       activeColor: Colors.green,
          //       inactiveTrackColor: Colors.grey.shade400,
          //     ),
          //   ],
          // ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      child: Text(
                        messages[index],
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Text(
              "⬇ New messages",
              style: TextStyle(color: Colors.black54),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.camera_alt_outlined),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.image_outlined),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.mic_none_outlined),
                  onPressed: () {},
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: const Color(0xFFF5F5F5),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: const InputDecoration(
                              hintText: "Message",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send, color: Colors.pink),
                          onPressed: _sendMessage,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

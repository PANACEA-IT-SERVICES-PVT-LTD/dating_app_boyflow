import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/api_controller.dart';

/// Example widget demonstrating how to fetch chat messages for a specific chat room
class ChatMessagesExample extends StatefulWidget {
  final String chatRoomId;

  const ChatMessagesExample({
    Key? key,
    required this.chatRoomId,
  }) : super(key: key);

  @override
  State<ChatMessagesExample> createState() => _ChatMessagesExampleState();
}

class _ChatMessagesExampleState extends State<ChatMessagesExample> {
  List<Map<String, dynamic>> messages = [];
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  // Fetch messages for the chat room
  Future<void> _loadMessages() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final apiController = Provider.of<ApiController>(context, listen: false);
      final result = await apiController.fetchChatMessages(widget.chatRoomId);

      // If fetchChatMessages returns void, you need to update it to return a Map or similar result.
      // For now, add a temporary check to avoid using the result if it's void.
      if (result != null && result is Map && result['success'] == true && result['data'] is List) {
        setState(() {
          messages = List<Map<String, dynamic>>.from(result['data']);
          isLoading = false;
        });
      } else if (result != null && result is Map) {
        setState(() {
          errorMessage = result['message'] ?? 'Failed to load messages';
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load messages: No data returned';
          isLoading = false;
        });
      }
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMessages,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error: $errorMessage',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadMessages,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : messages.isEmpty
                  ? const Center(child: Text('No messages found'))
                  : ListView.builder(
                      itemCount: messages.length,
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final content = message['content'] ?? '';
                        final senderType = message['senderType'] ?? '';
                        final createdAt = message['createdAt'] ?? '';
                        final isMedia = message['isMedia'] ?? false;
                        final type = message['type'] ?? 'text';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Card(
                            color: senderType == 'male'
                                ? Colors.blue.shade50
                                : Colors.pink.shade50,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        senderType.toUpperCase(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: senderType == 'male'
                                              ? Colors.blue
                                              : Colors.pink,
                                        ),
                                      ),
                                      Text(
                                        _formatDate(createdAt),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  if (isMedia)
                                    Chip(
                                      label: Text('Media: $type'),
                                      backgroundColor: Colors.orange.shade100,
                                    )
                                  else
                                    Text(
                                      content,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}

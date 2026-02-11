import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/api_controller.dart';
import 'dart:io';

class ChatDetailScreen extends StatefulWidget {
  final String? roomId; // Can be null if starting new chat from profile
  final String? femaleUserId; // For blocking/unblocking
  final String name;
  final String img;

  const ChatDetailScreen({
    super.key,
    this.roomId,
    this.femaleUserId,
    required this.name,
    required this.img,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.roomId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final apiController = Provider.of<ApiController>(context, listen: false);
        await apiController.fetchChatMessages(widget.roomId!);
        
        // Mark as read when entering
        if (apiController.chatMessages.isNotEmpty) {
          final messageIds = apiController.chatMessages
              .map((m) => m['id']?.toString() ?? m['_id']?.toString() ?? '')
              .where((id) => id.isNotEmpty)
              .toList();
          if (messageIds.isNotEmpty) {
            apiController.markAsRead(roomId: widget.roomId!, messageIds: messageIds);
          }
        }
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty || widget.roomId == null) return;

    final apiController = Provider.of<ApiController>(context, listen: false);
    await apiController.sendTextMessage(
      roomId: widget.roomId!,
      content: content,
    );
    _messageController.clear();
    _scrollToBottom();
  }

  Future<void> _pickMedia(String type) async {
    if (widget.roomId == null) return;
    
    XFile? file;
    if (type == 'image') {
      file = await _picker.pickImage(source: ImageSource.gallery);
    } else if (type == 'video') {
      file = await _picker.pickVideo(source: ImageSource.gallery);
    }

    if (file != null) {
      final apiController = Provider.of<ApiController>(context, listen: false);
      await apiController.sendMediaMessage(
        roomId: widget.roomId!,
        file: File(file.path),
        type: type,
      );
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final apiController = Provider.of<ApiController>(context);
    final messages = apiController.chatMessages;
    final isLoading = apiController.isChatMessagesLoading;

    // Scroll to bottom when messages change
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF55A5), Color(0xFF9A00F0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(widget.img),
                radius: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () {
                if (widget.roomId != null) {
                  apiController.fetchChatMessages(widget.roomId!);
                }
              },
            ),
            if (widget.roomId != null)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (value) async {
                  if (value == 'disappearing') {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Disappearing Messages'),
                        content: const Text('Enable disappearing messages for this chat? (Messages will vanish after 24 hours)'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Disable')),
                          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Enable')),
                        ],
                      ),
                    );

                    if (confirm != null) {
                      try {
                        await apiController.toggleDisappearingMessages(
                          roomId: widget.roomId!,
                          enabled: confirm,
                        );
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Disappearing messages ${confirm ? 'enabled' : 'disabled'}')),
                          );
                        }
                      } catch (e) {
                         if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      }
                    }
                  } else if (value == 'block') {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Block User'),
                        content: Text('Are you sure you want to block ${widget.name}? they will not be able to message you.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Block', style: TextStyle(color: Colors.red))),
                        ],
                      ),
                    );

                    if (confirm == true && widget.femaleUserId != null) {
                      try {
                        await apiController.blockUser(femaleUserId: widget.femaleUserId!);
                        if (mounted) {
                          Navigator.pop(context); // Close chat
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('User blocked')),
                          );
                        }
                      } catch (e) {
                         if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      }
                    }
                  } else if (value == 'clear') {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Clear Chat'),
                        content: const Text('Are you sure you want to clear all messages?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Clear', style: TextStyle(color: Colors.red))),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      final messageIds = apiController.chatMessages
                          .map((m) => m['id']?.toString() ?? m['_id']?.toString() ?? '')
                          .where((id) => id.isNotEmpty)
                          .toList();
                      if (messageIds.isNotEmpty) {
                        try {
                          await apiController.clearChat(
                            roomId: widget.roomId!,
                            messageIds: messageIds,
                          );
                        } catch (e) {
                           if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      }
                    }
                  } else if (value == 'delete') {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Chat'),
                        content: const Text('Are you sure you want to delete this conversation?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      final messageIds = apiController.chatMessages
                          .map((m) => m['id']?.toString() ?? m['_id']?.toString() ?? '')
                          .where((id) => id.isNotEmpty)
                          .toList();
                      try {
                        await apiController.deleteChatRoom(
                          roomId: widget.roomId!,
                          messageIds: messageIds,
                        );
                        if (mounted) Navigator.pop(context);
                      } catch (e) {
                         if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      }
                    }
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'disappearing',
                    child: Text('Disappearing Messages'),
                  ),
                  const PopupMenuItem(
                    value: 'clear',
                    child: Text('Clear Chat'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete Chat'),
                  ),
                  if (widget.femaleUserId != null)
                    const PopupMenuItem(
                      value: 'block',
                      child: Text('Block User', style: TextStyle(color: Colors.red)),
                    ),
                ],
              ),
            ],
          ),
        ),
      body: Column(
        children: [
          Expanded(
            child: isLoading && messages.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : messages.isEmpty
                    ? const Center(child: Text("No messages yet"))
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          final senderType = (msg['senderType'] ?? msg['sender_type'] ?? '').toString().toUpperCase();
                          final isMe = senderType == 'MALE' || senderType == 'BOY'; 
                          final content = msg['content'] ?? '';
                          final type = msg['type'] ?? 'text';

                          Widget bubble;
                          if (type.toLowerCase() == 'image') {
                            bubble = _buildImageBubble(content, isMe);
                          } else if (type.toLowerCase() == 'video') {
                            bubble = _buildVideoBubble(content, isMe);
                          } else {
                            bubble = _buildTextBubble(content, isMe);
                          }

                          return GestureDetector(
                            onLongPress: () {
                              final msgId = msg['id']?.toString() ?? msg['_id']?.toString();
                              if (msgId == null) return;

                              showModalBottomSheet(
                                context: context,
                                builder: (context) => Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.delete),
                                      title: const Text('Delete for me'),
                                      onTap: () async {
                                        Navigator.pop(context);
                                        try {
                                          await apiController.deleteMessage(
                                            roomId: widget.roomId!,
                                            messageId: msgId,
                                          );
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Error: $e')),
                                            );
                                          }
                                        }
                                      },
                                    ),
                                    if (isMe)
                                      ListTile(
                                        leading: const Icon(Icons.delete_forever),
                                        title: const Text('Delete for everyone'),
                                        onTap: () async {
                                          Navigator.pop(context);
                                          try {
                                            await apiController.deleteMessageForEveryone(
                                              roomId: widget.roomId!,
                                              messageId: msgId,
                                            );
                                          } catch (e) {
                                            if (mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Error: $e')),
                                              );
                                            }
                                          }
                                        },
                                      ),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              );
                            },
                            child: bubble,
                          );
                        },
                      ),
          ),
          _buildInputArea(apiController.isSendingMessage),
          if (apiController.chatMessagesError != null)
             Padding(
               padding: const EdgeInsets.all(8.0),
               child: Text(
                 apiController.chatMessagesError!,
                 style: const TextStyle(color: Colors.red, fontSize: 12),
               ),
             ),
        ],
      ),
    );
  }

  Widget _buildTextBubble(String text, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? Colors.grey.shade100 : const Color.fromARGB(255, 234, 176, 222),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(color: isMe ? Colors.black : Colors.black),
        ),
      ),
    );
  }

  Widget _buildImageBubble(String url, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isMe ? Colors.grey.shade100 : const Color.fromARGB(255, 234, 176, 222),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            url,
            width: 200,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image, size: 50),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoBubble(String url, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.grey.shade100 : const Color.fromARGB(255, 234, 176, 222),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            const Icon(Icons.play_circle_fill, size: 50, color: Colors.grey),
            const SizedBox(height: 4),
            Text("Video", style: TextStyle(color: isMe ? Colors.black : Colors.black)),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(bool isSending) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.image, color: Color(0xFFFF55A5)),
              onPressed: isSending ? null : () => _pickMedia('image'),
            ),
            IconButton(
              icon: const Icon(Icons.videocam, color: Color(0xFF9A00F0)),
              onPressed: isSending ? null : () => _pickMedia('video'),
            ),
            IconButton(
              icon: const Icon(Icons.mic, color: Colors.orange),
              onPressed: isSending ? null : () => _pickMedia('audio'),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  enabled: !isSending,
                  decoration: const InputDecoration(
                    hintText: "Message",
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            isSending
                ? const SizedBox(
                    width: 44,
                    height: 44,
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFFFF55A5), Color(0xFF9A00F0)],
                        ),
                      ),
                      child: const Icon(Icons.send, color: Colors.white, size: 20),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/api_controller.dart';
import 'chat_detail_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool isOnline = false;
  String selectedTab = 'Important';
  List<dynamic> _chatRooms = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadChatRooms();
  }

  Future<void> _loadChatRooms() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      final apiController = Provider.of<ApiController>(context, listen: false);
      final response = await apiController.fetchChatRooms();
      
      if (response['success'] == true && response['data'] is List) {
        setState(() {
          _chatRooms = response['data'];
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load chats';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            "Chats",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
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
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _loadChatRooms,
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                      ElevatedButton(
                        onPressed: _loadChatRooms,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _chatRooms.isEmpty
                  ? const Center(child: Text("No chats yet"))
                  : ListView.builder(
                      itemCount: _chatRooms.length,
                      itemBuilder: (context, index) {
                        final room = _chatRooms[index];
                        
                        // Handle femaleId/femaleUserId which might be a Map or a String (ID)
                        final femaleRaw = room['femaleId'] ?? room['femaleUserId'] ?? room['female_id'] ?? room['female_user_id'];
                        final Map<String, dynamic> female = (femaleRaw is Map) ? Map<String, dynamic>.from(femaleRaw) : {};
                        
                        // Handle lastMessage which might be a Map or a String (ID)
                        final lastMsgRaw = room['lastMessage'] ?? room['last_message'];
                        final Map<String, dynamic> lastMsg = (lastMsgRaw is Map) ? Map<String, dynamic>.from(lastMsgRaw) : {};
                        
                        // Aggressive name resolution
                        String name = 'Unknown';
                        
                        // Try finding in 'female' object (already extracted above)
                        if (female.isNotEmpty) {
                          name = female['name'] ?? female['username'] ?? female['displayName'] ?? female['firstName'] ?? female['first_name'] ?? 'Unknown';
                          if (name == 'Unknown' && female['id_name'] != null) name = female['id_name'];
                        }
                        
                        // Try finding in room top-level
                        if (name == 'Unknown') {
                          name = room['femaleName'] ?? room['female_name'] ?? room['name'] ?? room['username'] ?? room['firstName'] ?? room['first_name'] ?? 'Unknown';
                        }

                        // Try other common permutations
                        if (name == 'Unknown') {
                          name = room['female_userName'] ?? room['female_user_name'] ?? room['femaleId_name'] ?? room['femaleId_username'] ?? room['female_id_name'] ?? room['female_id_username'] ?? 'Unknown';
                        }

                        if (name == 'Unknown') {
                          // Search for any map with a name field
                          room.forEach((key, value) {
                            if (name == 'Unknown' && value is Map) {
                              final vMap = Map<String, dynamic>.from(value);
                              name = vMap['name'] ?? vMap['username'] ?? vMap['displayName'] ?? vMap['firstName'] ?? vMap['first_name'] ?? 'Unknown';
                            }
                          });
                        }
                        
                        if (name == 'Unknown' && lastMsg['senderName'] != null) {
                           name = lastMsg['senderName'];
                        }
                        
                        // Last resort: Log keys for future debugging if still unknown
                        if (name == 'Unknown') {
                           debugPrint('[DEBUG] Unknown Room keys: ${room.keys.toList()}');
                           if (female.isNotEmpty) debugPrint('[DEBUG] Female object keys: ${female.keys.toList()}');
                        }
                        
                        // If lastName is separate, append it
                        if (name != 'Unknown' && (female['lastName'] != null || female['last_name'] != null || room['lastName'] != null || room['last_name'] != null)) {
                          String lName = female['lastName'] ?? female['last_name'] ?? room['lastName'] ?? room['last_name'] ?? '';
                          if (lName.isNotEmpty && !name.toLowerCase().contains(lName.toLowerCase())) {
                            name = '$name $lName'.trim();
                          }
                        }

                        // Avatar resolution
                        String img = 'https://i.pravatar.cc/150?img=1';
                        if (female.isNotEmpty) {
                          img = female['avatarUrl'] ?? female['avatar'] ?? img;
                          if (img.startsWith('https://i.pravatar.cc') && female['images'] is List && (female['images'] as List).isNotEmpty) {
                             final firstImg = female['images'][0];
                             if (firstImg is Map) img = firstImg['imageUrl'] ?? img;
                          }
                        }
                        if (img.startsWith('https://i.pravatar.cc')) {
                          img = room['femaleAvatarUrl'] ?? room['avatar'] ?? img;
                        }
                        final message = lastMsg['content'] ?? 'No messages yet';
                        final time = lastMsg['createdAt'] != null 
                            ? lastMsg['createdAt'].toString().substring(11, 16) // Quick fix for time
                            : '';
                        final unread = room['unreadCount'] ?? 0;
                        final isOnline = female['isOnline'] ?? false;

                        return Dismissible(
                          key: Key(room['_id'] ?? room['id'] ?? index.toString()),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            color: Colors.red,
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          confirmDismiss: (direction) async {
                            return await showDialog<bool>(
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
                          },
                          onDismissed: (direction) async {
                            final roomId = room['_id'] ?? room['id'];
                            if (roomId != null) {
                              try {
                                final apiController = Provider.of<ApiController>(context, listen: false);
                                // For room deletion from list, we might only have lastMessage ID
                                List<String> messageIds = [];
                                if (lastMsg['id'] != null || lastMsg['_id'] != null) {
                                  messageIds.add((lastMsg['id'] ?? lastMsg['_id']).toString());
                                }
                                await apiController.deleteChatRoom(
                                  roomId: roomId.toString(),
                                  messageIds: messageIds,
                                );
                                // Reload chat rooms after successful deletion
                                _loadChatRooms();
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                }
                              }
                            }
                          },
                          child: ListTile(
                            leading: Stack(
                              children: [
                                CircleAvatar(
                                  backgroundImage: NetworkImage(img),
                                  radius: 28,
                                ),
                                if (isOnline)
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
                              name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            subtitle: Text(
                              message,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  time,
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                if (unread > 0)
                                  Container(
                                    margin: const EdgeInsets.only(top: 6),
                                    padding: const EdgeInsets.all(5),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      unread.toString(),
                                      style: const TextStyle(color: Colors.white, fontSize: 10),
                                    ),
                                  ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatDetailScreen(
                                    roomId: room['_id'] ?? room['id'],
                                    femaleUserId: (female['id'] ?? female['_id'] ?? room['femaleId'] ?? room['femaleUserId'] ?? room['female_id'] ?? room['female_user_id'])?.toString(),
                                    name: name,
                                    img: img,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}

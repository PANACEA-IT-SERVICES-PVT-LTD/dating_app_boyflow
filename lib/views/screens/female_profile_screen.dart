import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Boy_flow/controllers/api_controller.dart';
import 'package:Boy_flow/models/female_user.dart';
import 'package:Boy_flow/utils/colors.dart';
import 'package:Boy_flow/widgets/gift_selection_sheet.dart';
import 'package:Boy_flow/agora_video_call.dart';
import 'package:Boy_flow/services/call_notification_service.dart';

class FemaleProfileScreen extends StatefulWidget {
  final FemaleUser user;
  const FemaleProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<FemaleProfileScreen> createState() => _FemaleProfileScreenState();
}

class _FemaleProfileScreenState extends State<FemaleProfileScreen> {
  LinearGradient get _mainGradient => const LinearGradient(
    colors: [Color(0xFFFF00CC), Color(0xFF9A00F0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ApiController>(context, listen: false).fetchSentFollowRequests();
    });
  }

  // Method to show call options dialog with channel selection
  void _showCallOptionsDialog(BuildContext context) {
    TextEditingController channelController = TextEditingController(
      text: 'friends_call_123',
    ); // Default channel
    bool isVideoCall = true;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Call Options"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: channelController,
                    decoration: const InputDecoration(
                      labelText: "Channel Name",
                      hintText: "Enter channel name",
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<bool>(
                          title: const Text("Video"),
                          value: true,
                          groupValue: isVideoCall,
                          onChanged: (bool? value) {
                            if (value != null) {
                              setDialogState(() {
                                isVideoCall = value;
                              });
                            }
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<bool>(
                          title: const Text("Audio"),
                          value: false,
                          groupValue: isVideoCall,
                          onChanged: (bool? value) {
                            if (value != null) {
                              setDialogState(() {
                                isVideoCall = value;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                  },
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Start the call with the selected channel name
                    Navigator.of(context).pop(); // Close dialog
                    _startCall(context, channelController.text.trim(), isVideoCall);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF00CC),
                  ),
                  child: const Text(
                    "Start",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          }
        );
      },
    );
  }

  // Method to start the call
  void _startCall(BuildContext context, String channelName, bool isVideoCall) {
    // Get the call notification service instance
    final callService = CallNotificationService();

    // Simulate sending a call notification to the female user
    callService.simulateIncomingCall(
      callerName: "Male User", // This should be the actual male user's name
      callerId: "1", // This should be the actual male user's ID
      channelName: channelName,
      callerUid: 1,
      isVideoCall: isVideoCall,
    );

    // For testing purposes, let's also join the call from the caller side
    // In a real app, you'd have separate apps for caller and receiver
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AgoraVideoCallScreen(
          channelName: channelName,
          uid: 1, // Caller UID
          isCaller: true,
          remoteUserId: 2, // This should match the female user's expected UID
          remoteUserName: widget.user.name,
          isVideoCall: isVideoCall,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final apiController = Provider.of<ApiController>(context);
    final followStatus = apiController.getFollowStatus(widget.user.id);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          decoration: BoxDecoration(gradient: _mainGradient),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: const BackButton(color: Colors.white),
            title: const Text("Profile", style: TextStyle(color: Colors.white)),
            actions: const [Icon(Icons.more_vert, color: Colors.white)],
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 150),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// PROFILE CARD
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundImage:
                            widget.user.avatarUrl != null && widget.user.avatarUrl!.isNotEmpty
                            ? NetworkImage(widget.user.avatarUrl!)
                            : null,
                        child: widget.user.avatarUrl == null || widget.user.avatarUrl!.isEmpty
                            ? const Icon(Icons.person, size: 36)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  widget.user.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.verified,
                                  color: AppColors.outlinePink,
                                  size: 18,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Age: ${widget.user.age} years",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "2350 Followers",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black45,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: followStatus == 'none' ? _mainGradient : null,
                          color: followStatus == 'pending' ? Colors.orangeAccent.withOpacity(0.2) : (followStatus == 'following' ? Colors.greenAccent.withOpacity(0.2) : null),
                          borderRadius: BorderRadius.circular(20),
                          border: followStatus != 'none' ? Border.all(color: followStatus == 'pending' ? Colors.orangeAccent : Colors.greenAccent) : null,
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () async {
                            try {
                              if (followStatus == 'none') {
                                await apiController.sendFollowRequest(widget.user.id);
                              } else if (followStatus == 'pending') {
                                await apiController.cancelFollowRequest(widget.user.id);
                              } else if (followStatus == 'following') {
                                await apiController.unfollowUser(widget.user.id);
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                                );
                              }
                            }
                          },
                          child: Text(
                            followStatus == 'none' ? "Follow" : (followStatus == 'pending' ? "Pending" : "Following"),
                            style: TextStyle(
                              color: followStatus == 'none' ? Colors.white : (followStatus == 'pending' ? Colors.orangeAccent : Colors.greenAccent),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// SECTIONS
                _section("Languages", ["Telugu"]),
                _section("Interests", [
                  "Family and parenting",
                  "Society and politics",
                ]),
                _section("Hobbies", ["Cooking", "Writing"]),
                _section("Sports", ["Cricket"]),
                _section("Film", ["NO FILMS"]),
                _section("Music", ["2020s"]),
                _section("Travel", ["Mountains"]),
              ],
            ),
          ),

          /// ================= BOTTOM BUTTONS =================
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: _mainGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: OutlinedButton.icon(
                        icon: Icon(Icons.chat, color: Colors.white),
                        label: const Text(
                          "Say Hi",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.transparent),
                          backgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: _mainGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.call, color: Colors.white),
                        label: const Text(
                          "Call",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          _showCallOptionsDialog(context);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: _mainGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ElevatedButton.icon(
                        icon: const Icon(
                          Icons.card_giftcard,
                          color: Colors.white,
                        ),
                        label: const Text(
                          "Gift",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => GiftSelectionSheet(
                              femaleUserId: widget.user.id,
                              onGiftSent: (newBalance) {
                                // Handle balance update if needed
                                print('New balance: $newBalance');
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ================= SECTION BUILDER =================
  Widget _section(String title, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items
                .map(
                  (e) => Chip(
                    label: Text(e),
                    backgroundColor: const Color(0xFFFFE3F6),
                    labelStyle: const TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:boy_flow/controllers/api_controller.dart';
import 'package:boy_flow/models/female_user.dart';
import 'package:boy_flow/utils/colors.dart';
import 'package:boy_flow/widgets/gift_selection_sheet.dart';
import 'package:boy_flow/services/call_notification_service.dart';
import 'package:boy_flow/agora_video_call.dart';
import 'package:boy_flow/agora_config.dart';

class FemaleProfileScreen extends StatefulWidget {
  final FemaleUser user;
  const FemaleProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<FemaleProfileScreen> createState() => _FemaleProfileScreenState();
}

class _FemaleProfileScreenState extends State<FemaleProfileScreen> {
  bool _isCallLoading = false;

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

  Future<void> _startCall(bool isVideo) async {
    if (_isCallLoading) return;

    setState(() {
      _isCallLoading = true;
    });

    try {
      final apiController = Provider.of<ApiController>(context, listen: false);

      final response = await apiController.startCall(
        receiverId: widget.user.id,
        callType: isVideo ? 'video' : 'audio',
      );

      if (response['success'] == true) {
        final data = response['data'];
        final channelName = data['channelName'] ?? data['callId'] ?? 'friends_call_123';

        // Navigate to Agora video call screen
        if (mounted) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AgoraVideoCallScreen(
                channelName: channelName,
                uid: boyAppUid,
                isCaller: true,
                remoteUserId: femaleAppUid,
                remoteUserName: widget.user.name,
                isVideoCall: isVideo,
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Failed to start call'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error starting call: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCallLoading = false;
        });
      }
    }
  }

  Future<void> _showCallOptions() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Call Type'),
          content: const Text('Select the type of call you want to make'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _startCall(false); // Audio call
              },
              child: const Text('Audio Call'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _startCall(true); // Video call
              },
              child: const Text('Video Call'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
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
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (value) async {
                  if (value == 'block') {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Block User'),
                        content: Text('Are you sure you want to block ${widget.user.name}? they will not be able to message you.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Block', style: TextStyle(color: Colors.red))),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      try {
                        final apiController = Provider.of<ApiController>(context, listen: false);
                        await apiController.blockUser(femaleUserId: widget.user.id);
                        if (mounted) {
                          Navigator.pop(context); // Go back after blocking
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
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'block',
                    child: Text('Block User', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],
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
                        icon: _isCallLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(Icons.call, color: Colors.white),
                        label: Text(
                          _isCallLoading ? "Calling..." : "Call",
                          style: const TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: _showCallOptions,
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

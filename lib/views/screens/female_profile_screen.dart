import 'package:flutter/material.dart';
import 'package:Boy_flow/models/female_user.dart';
import 'package:Boy_flow/utils/colors.dart';

class FemaleProfileScreen extends StatefulWidget {
  final FemaleUser user;
  const FemaleProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<FemaleProfileScreen> createState() => _FemaleProfileScreenState();
}

class _FemaleProfileScreenState extends State<FemaleProfileScreen> {
  bool _isCallLoading = false;

  Future<void> _startCall(bool isVideo) async {
    if (_isCallLoading) return;

    setState(() {
      _isCallLoading = true;
    });

    try {
      final apiController = Provider.of<ApiController>(context, listen: false);

      // Convert FemaleUser to the format expected by the API
      final profileData = {'_id': widget.user.id, 'name': widget.user.name};

      final response = await apiController.startCall(
        receiverId: widget.user.id,
        callType: isVideo ? 'video' : 'audio',
      );

      if (response['success'] == true) {
        final data = response['data'];

        // Navigate to outgoing call screen
        if (mounted) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OutgoingCallScreen(
                receiverId: widget.user.id,
                receiverName: widget.user.name,
                channelName: data['channelName'] ?? data['callId'],
                callType: isVideo ? 'video' : 'audio',
                callId: data['callId'],
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

  LinearGradient get _mainGradient => const LinearGradient(
    colors: [Color(0xFFFF00CC), Color(0xFF9A00F0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
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
                            widget.user.avatarUrl != null &&
                                widget.user.avatarUrl!.isNotEmpty
                            ? NetworkImage(widget.user.avatarUrl!)
                            : null,
                        child:
                            widget.user.avatarUrl == null ||
                                widget.user.avatarUrl!.isEmpty
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
                          gradient: _mainGradient,
                          borderRadius: BorderRadius.circular(20),
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
                          onPressed: () {},
                          child: ShaderMask(
                            shaderCallback: (rect) =>
                                _mainGradient.createShader(rect),
                            child: const Text(
                              "Follow",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
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
                        onPressed: _isCallLoading ? null : _showCallOptions,
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
                              femaleUserId: user.id,
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

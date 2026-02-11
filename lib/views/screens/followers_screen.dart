import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../controllers/api_controller.dart';
import '../../api_service/api_endpoint.dart';

class MyFollowersScreen extends StatefulWidget {
  const MyFollowersScreen({super.key});

  @override
  State<MyFollowersScreen> createState() => _MyFollowersScreenState();
}

class _MyFollowersScreenState extends State<MyFollowersScreen> {
  bool isOnline = true;
  bool _isInit = true;
  int _tabIndex = 0; // 0 = followers, 1 = following, 2 = sent requests
  bool _loading = false;
  String? _error;
  List<Map<String, dynamic>> _followers = [];
  List<Map<String, dynamic>> _following = [];
  Set<String> _favourites = {};

  final Gradient appGradient = const LinearGradient(
    colors: [Color(0xFFFF00CC), Color(0xFF9A00F0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();
    _fetchFollowers();
    _fetchFavourites();
  }

  String? _extractId(dynamic item) {
    if (item == null) return null;
    if (item is Map<String, dynamic>) {
      return (item["id"] ?? item["_id"] ?? "").toString();
    }
    return item.toString();
  }

  Future<void> _fetchFollowers() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final url = Uri.parse(
        "${ApiEndPoints.baseUrls}${ApiEndPoints.maleFollowers}",
      );
      final resp = await http.get(url);

      dynamic body;
      try {
        body = resp.body.isNotEmpty ? jsonDecode(resp.body) : {};
      } catch (_) {
        body = {"raw": resp.body};
      }

      List<dynamic> dataList = [];
      if (body is Map && body["data"] is List) {
        dataList = body["data"] as List<dynamic>;
      } else if (body is List) {
        dataList = body;
      }

      final mapped = dataList
          .whereType<Map<String, dynamic>>()
          .map<Map<String, dynamic>>((item) {
            final username = (item["username"] ?? item["name"] ?? "User")
                .toString();
            final age = int.tryParse((item["age"] ?? "0").toString()) ?? 0;
            final gender = (item["gender"] ?? "").toString();
            final level = (item["level"] ?? "01").toString();
            final online = item["online"] == true || item["isOnline"] == true;
            final avatarUrl =
                (item["avatar"] ?? item["avatarUrl"] ?? item["photo"] ?? "")
                    .toString();
            final id = (item["id"] ?? item["_id"] ?? "").toString();

            return {
              "id": id,
              "username": username,
              "age": age,
              "gender": gender,
              "level": level,
              "online": online,
              "avatarUrl": avatarUrl,
            };
          })
          .toList();

      if (!mounted) return;

      setState(() {
        _followers = mapped;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _fetchFavourites() async {
    try {
      final url = Uri.parse("${ApiEndPoints.baseUrls}${ApiEndPoints.maleMe}");
      final resp = await http.get(url);

      dynamic body;
      try {
        body = resp.body.isNotEmpty ? jsonDecode(resp.body) : {};
      } catch (_) {
        body = {"raw": resp.body};
      }

      final favIds = <String>{};
      if (body is Map && body["data"] is Map) {
        final data = body["data"] as Map;
        final favourites = data["favourites"];

        if (favourites is List) {
          for (final item in favourites) {
            final id = _extractId(item);
            if (id != null && id.isNotEmpty) {
              favIds.add(id);
            }
          }
        }
      }

      if (!mounted) return;

      setState(() {
        _favourites = favIds;
      });
    } catch (_) {
      // silent failure for favourites list
    }
  }

  Future<void> _addFavourite(String userId) async {
    if (userId.isEmpty) return;
    try {
      final url = Uri.parse(
        "${ApiEndPoints.baseUrls}${ApiEndPoints.maleAddFavourite}",
      );
      await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userId": userId}),
      );

      if (!mounted) return;
      setState(() {
        _favourites.add(userId);
      });
    } catch (_) {
      // you can add snackbar/logging here if needed
    }
  }

  Future<void> _removeFavourite(String userId) async {
    if (userId.isEmpty) return;
    try {
      final url = Uri.parse(
        "${ApiEndPoints.baseUrls}${ApiEndPoints.maleRemoveFavourite}",
      );
      await http.delete(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userId": userId}),
      );

      if (!mounted) return;
      setState(() {
        _favourites.remove(userId);
      });
    } catch (_) {
      // you can add snackbar/logging here if needed
    }
  }

  Future<void> _fetchFollowing() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final url = Uri.parse(
        "${ApiEndPoints.baseUrls}${ApiEndPoints.maleFollowing}",
      );
      final resp = await http.get(url);

      dynamic body;
      try {
        body = resp.body.isNotEmpty ? jsonDecode(resp.body) : {};
      } catch (_) {
        body = {"raw": resp.body};
      }

      List<dynamic> dataList = [];
      if (body is Map && body["data"] is List) {
        dataList = body["data"] as List<dynamic>;
      } else if (body is List) {
        dataList = body;
      }

      final mapped = dataList
          .whereType<Map<String, dynamic>>()
          .map<Map<String, dynamic>>((item) {
            final username = (item["username"] ?? item["name"] ?? "User")
                .toString();
            final age = int.tryParse((item["age"] ?? "0").toString()) ?? 0;
            final gender = (item["gender"] ?? "").toString();
            final level = (item["level"] ?? "01").toString();
            final online = item["online"] == true || item["isOnline"] == true;
            final avatarUrl =
                (item["avatar"] ?? item["avatarUrl"] ?? item["photo"] ?? "")
                    .toString();
            final id = (item["id"] ?? item["_id"] ?? "").toString();

            return {
              "id": id,
              "username": username,
              "age": age,
              "gender": gender,
              "level": level,
              "online": online,
              "avatarUrl": avatarUrl,
            };
          })
          .toList();

      if (!mounted) return;

      setState(() {
        _following = mapped;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _handleRefresh() async {
    final apiController = Provider.of<ApiController>(context, listen: false);
    if (_tabIndex == 0) {
      await apiController.fetchFollowers();
    } else if (_tabIndex == 1) {
      await apiController.fetchFollowing();
    } else {
      await apiController.fetchSentFollowRequests();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Followers",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: appGradient),
        ),
      ),
      body: Consumer<ApiController>(
        builder: (context, apiController, child) {
          return Column(
            children: [
              const SizedBox(height: 10),
              // Toggle Buttons
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _gradientToggleButton("Followers", _tabIndex == 0, () {
                      if (_tabIndex != 0) {
                        setState(() => _tabIndex = 0);
                        apiController.fetchFollowers();
                      }
                    }),
                    const SizedBox(width: 8),
                    _gradientToggleButton("Following", _tabIndex == 1, () {
                      if (_tabIndex != 1) {
                        setState(() => _tabIndex = 1);
                        apiController.fetchFollowing();
                      }
                    }),
                    const SizedBox(width: 8),
                    _gradientToggleButton("Sent Requests", _tabIndex == 2, () {
                      if (_tabIndex != 2) {
                        setState(() => _tabIndex = 2);
                        apiController.fetchSentFollowRequests();
                      }
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // List
              Expanded(
                child: apiController.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : apiController.error != null
                        ? Center(child: Text(apiController.error!))
                        : RefreshIndicator(
                            onRefresh: _handleRefresh,
                            child: Builder(
                              builder: (context) {
                                List<Map<String, dynamic>> list;
                                String emptyMessage;

                                if (_tabIndex == 0) {
                                  list = apiController.followers;
                                  emptyMessage = "No followers found.";
                                } else if (_tabIndex == 1) {
                                  list = apiController.following;
                                  emptyMessage = "No following users found.";
                                } else {
                                  list = apiController.sentFollowRequests;
                                  emptyMessage = "No sent follow requests found.";
                                }

                                if (list.isEmpty) {
                                  return SingleChildScrollView(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    child: SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.7,
                                      child: Center(child: Text(emptyMessage)),
                                    ),
                                  );
                                }

                                return ListView.builder(
                                  itemCount: list.length,
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  itemBuilder: (_, index) {
                                    final item = list[index];
                                    
                                    Map<String, dynamic> userData;
                                    String? status;
                                    
                                    if (_tabIndex == 2) {
                                      userData = (item['femaleUserId'] is Map) 
                                          ? item['femaleUserId'] 
                                          : {};
                                      status = item['status'];
                                    } else {
                                      userData = (item['femaleUserId'] is Map)
                                          ? item['femaleUserId']
                                          : (item['maleUserId'] is Map)
                                              ? item['maleUserId']
                                              : item;
                                    }

                                    final username = (userData['username'] ?? userData['name'] ?? 'User').toString();
                                    final age = (userData['age'] ?? '').toString();
                                    final gender = (userData['gender'] ?? '').toString();
                                    final level = (userData['level'] ?? '01').toString();
                                    final avatar = (userData['avatar'] ?? userData['avatarUrl'] ?? userData['photo'] ?? '').toString();
                                    final userId = (userData['id'] ?? userData['_id'] ?? '').toString();
                                    final isOnline = userData['online'] == true || userData['isOnline'] == true;

                                    ImageProvider avatarProvider;
                                    if (avatar.isNotEmpty) {
                                      avatarProvider = NetworkImage(avatar);
                                    } else {
                                      avatarProvider = const AssetImage('assets/male_avatar.png');
                                    }

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundImage: avatarProvider,
                                            radius: 30,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      username,
                                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    _gradientLevelBadge(level),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Text("$gender $age"),
                                                    const SizedBox(width: 8),
                                                    if (isOnline)
                                                      const Text(
                                                        "• Online",
                                                        style: TextStyle(
                                                          color: Colors.green,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                                if (_tabIndex == 2 && status != null)
                                                  Text(
                                                    "Status: ${status.toUpperCase()}",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: status == 'pending' ? Colors.orange : Colors.green,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          _buildActionButton(apiController, userId, _tabIndex, status),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActionButton(ApiController controller, String userId, int tabIndex, String? status) {
    if (userId.isEmpty) return const SizedBox.shrink();

    if (tabIndex == 1) {
      return TextButton(
        onPressed: () => controller.unfollowUser(userId),
        child: const Text("Unfollow", style: TextStyle(color: Colors.red)),
      );
    } else if (tabIndex == 2 && status == 'pending') {
      return TextButton(
        onPressed: () => controller.cancelFollowRequest(userId),
        child: const Text("Cancel", style: TextStyle(color: Colors.red)),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _gradientToggleButton(String label, bool isSelected, VoidCallback onTap) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 100),
      child: Container(
        decoration: BoxDecoration(
          gradient: isSelected ? appGradient : null,
          borderRadius: BorderRadius.circular(20),
          border: !isSelected ? Border.all(color: Colors.pink.shade200) : null,
        ),
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            elevation: 0,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            foregroundColor: isSelected ? Colors.white : Colors.pink,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.pink,
            ),
          ),
        ),
      ),
    );
  }

  Widget _gradientLevelBadge(String level) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        gradient: appGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        level,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

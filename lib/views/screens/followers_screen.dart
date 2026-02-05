import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../api_service/api_endpoint.dart';

class MyFollowersScreen extends StatefulWidget {
  const MyFollowersScreen({super.key});

  @override
  State<MyFollowersScreen> createState() => _MyFollowersScreenState();
}

class _MyFollowersScreenState extends State<MyFollowersScreen> {
  bool isOnline = true;
  int _tabIndex = 0; // 0 = followers, 1 = following, 2 = favourites

  List<Map<String, dynamic>> _followers = [];
  List<Map<String, dynamic>> _following = [];

  Set<String> _favourites = <String>{};
  bool _loading = false;
  String? _error;

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
        "${ApiEndPoints.baseUrl}${ApiEndPoints.maleFollowers}",
      );
      final resp = await http.get(url);

      // Handle 404 response specifically
      if (resp.statusCode == 404) {
        if (!mounted) return;
        setState(() {
          _followers = [];
          _loading = false;
          _error = 'No followers found';
        });
        return;
      } else if (resp.statusCode != 200) {
        if (!mounted) return;
        setState(() {
          _loading = false;
          _error = 'Failed to load followers: Status ${resp.statusCode}';
        });
        return;
      }

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
      final url = Uri.parse("${ApiEndPoints.baseUrl}${ApiEndPoints.maleMe}");
      final resp = await http.get(url);

      // Handle 404 response specifically
      if (resp.statusCode == 404) {
        if (!mounted) return;
        setState(() {
          _favourites = <String>{};
        });
        return;
      } else if (resp.statusCode != 200) {
        // Handle other error status codes silently or log them
        print('Warning: Failed to fetch favourites: Status ${resp.statusCode}');
        return;
      }

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
        "${ApiEndPoints.baseUrl}${ApiEndPoints.maleAddFavourite}",
      );
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userId": userId}),
      );

      // Handle 404 response specifically
      if (response.statusCode == 404) {
        print('Add favourite endpoint not found (404)');
        return;
      } else if (response.statusCode != 200) {
        print('Failed to add favourite: Status ${response.statusCode}');
        return;
      }

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
        "${ApiEndPoints.baseUrl}${ApiEndPoints.maleRemoveFavourite}",
      );
      final response = await http.delete(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userId": userId}),
      );

      // Handle 404 response specifically
      if (response.statusCode == 404) {
        print('Remove favourite endpoint not found (404)');
        return;
      } else if (response.statusCode != 200) {
        print('Failed to remove favourite: Status ${response.statusCode}');
        return;
      }

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
        "${ApiEndPoints.baseUrl}${ApiEndPoints.maleFollowing}",
      );
      final resp = await http.get(url);

      // Handle 404 response specifically
      if (resp.statusCode == 404) {
        if (!mounted) return;
        setState(() {
          _following = [];
          _loading = false;
        });
        return;
      } else if (resp.statusCode != 200) {
        if (!mounted) return;
        setState(() {
          _loading = false;
          _error = 'Failed to load following: Status ${resp.statusCode}';
        });
        return;
      }

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
        actions: [
          // const Padding(
          //   padding: EdgeInsets.only(right: 10),
          //   child: Center(
          //     child: Text("Online", style: TextStyle(color: Colors.white)),
          //   ),
          // ),
          // Switch(
          //   value: isOnline,
          //   onChanged: (val) => setState(() => isOnline = val),
          //   activeColor: Colors.green,
          //   inactiveTrackColor: Colors.grey.shade400,
          // ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: appGradient),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          // Toggle Buttons with SingleChildScrollView
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _gradientToggleButton("Followers", _tabIndex == 0, () {
                  if (_tabIndex != 0) {
                    setState(() => _tabIndex = 0);
                    if (_followers.isEmpty) {
                      _fetchFollowers();
                    }
                  }
                }),
                const SizedBox(width: 8),
                _gradientToggleButton("Following", _tabIndex == 1, () {
                  if (_tabIndex != 1) {
                    setState(() => _tabIndex = 1);
                    if (_following.isEmpty) {
                      _fetchFollowing();
                    }
                  }
                }),
                const SizedBox(width: 8),
                _gradientToggleButton("Favourites", _tabIndex == 2, () {
                  if (_tabIndex != 2) {
                    setState(() => _tabIndex = 2);
                    if (_favourites.isEmpty) {
                      _fetchFavourites();
                    }
                  }
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(child: Text(_error!))
                : Builder(
                    builder: (context) {
                      List<Map<String, dynamic>> list;
                      String emptyMessage;

                      if (_tabIndex == 0) {
                        list = _followers;
                        emptyMessage = "No followers found.";
                      } else if (_tabIndex == 1) {
                        list = _following;
                        emptyMessage = "No following users found.";
                      } else {
                        // Favourites tab: merge followers + following filtered by favourite IDs
                        final merged = <Map<String, dynamic>>[];
                        final seen = <String>{};

                        for (final u in _followers) {
                          final id = (u['id'] ?? '').toString();
                          // Only add if favourite and femaleUserId is not null
                          if (_favourites.contains(id) &&
                              !seen.contains(id) &&
                              u['femaleUserId'] != null) {
                            merged.add(u);
                            seen.add(id);
                          }
                        }

                        for (final u in _following) {
                          final id = (u['id'] ?? '').toString();
                          if (_favourites.contains(id) &&
                              !seen.contains(id) &&
                              u['femaleUserId'] != null) {
                            merged.add(u);
                            seen.add(id);
                          }
                        }

                        list = merged;
                        emptyMessage = "No favourites found.";
                      }

                      if (list.isEmpty) {
                        return Center(child: Text(emptyMessage));
                      }

                      return ListView.builder(
                        itemCount: list.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemBuilder: (_, index) {
                          final user = list[index];
                          final avatar = (user['avatarUrl'] ?? '')
                              .toString()
                              .trim();

                          ImageProvider avatarProvider;
                          if (avatar.isNotEmpty) {
                            avatarProvider = NetworkImage(avatar);
                          } else {
                            avatarProvider = const AssetImage(
                              'assets/male_avatar.png',
                            );
                          }

                          final id = (user['id'] ?? '').toString();
                          final isFav = _favourites.contains(id);

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: avatarProvider,
                                  radius: 30,
                                ),
                                const SizedBox(width: 10),
                                // Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            (user['username'] ?? 'User')
                                                .toString(),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          _gradientLevelBadge(
                                            (user['level'] ?? '01').toString(),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                            "${(user['gender'] ?? '').toString()} ${(user['age'] ?? '').toString()}",
                                          ),
                                          const SizedBox(width: 8),
                                          if (user['online'] == true)
                                            const Text(
                                              "• Online",
                                              style: TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    isFav
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isFav ? Colors.red : Colors.grey,
                                  ),
                                  onPressed: id.isEmpty
                                      ? null
                                      : () {
                                          if (isFav) {
                                            _removeFavourite(id);
                                          } else {
                                            _addFavourite(id);
                                          }
                                        },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _gradientToggleButton(
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final Gradient gradient = appGradient;

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 100),
      child: Container(
        decoration: BoxDecoration(
          gradient: isSelected ? gradient : null,
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            foregroundColor: isSelected ? Colors.white : Colors.pink,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.pink,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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

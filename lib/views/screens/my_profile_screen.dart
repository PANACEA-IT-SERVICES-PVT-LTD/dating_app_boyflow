import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider for state management
import '../../core/routes/app_routes.dart'; // Import app routes
// ...existing code...
import '../../models/profiledetails.dart';
import '../../controllers/api_controller.dart'; // Use the API controller instead

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({Key? key}) : super(key: key);

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  Profiledetails? _user;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Use the ApiController via Provider to fetch profile
      final apiController = Provider.of<ApiController>(context, listen: false);
      final result = await apiController.fetchCurrentMaleProfile();

      if (result["success"] == true && result["data"] is Map) {
        final data = result["data"] as Map;

        // Create a compatible structure for Profiledetails.fromJson
        final userData = {
          "_id": data["_id"],
          "email": data["email"],
          "mobileNumber": data["mobileNumber"],
          "interests": data["interests"] ?? [],
          "languages": data["languages"] ?? [],
          "status": data["status"],
          "reviewStatus": data["reviewStatus"],
          "isVerified": data["isVerified"],
          "isActive": data["isActive"],
          "favourites": data["favourites"] ?? [],
          "kycStatus": data["kycStatus"],
          "followers": data["followers"] ?? [],
          "femalefollowing": data["femalefollowing"] ?? [],
          "malefollowing": data["malefollowing"] ?? [],
          "malefollowers": data["malefollowers"] ?? [],
          "earnings": data["earnings"] ?? [],
          "blockList": data["blockList"] ?? [],
          "beautyFilter": data["beautyFilter"],
          "hideAge": data["hideAge"],
          "onlineStatus": data["onlineStatus"],
          "walletBalance": data["walletBalance"],
          "coinBalance": data["coinBalance"],
          "balance": data["balance"],
          "referralCode": data["referralCode"],
          "referralBonusAwarded": data["referralBonusAwarded"],
          "profileCompleted": data["profileCompleted"],
          "referredBy":
              (data["referredBy"] != null &&
                  data["referredBy"] is! List &&
                  data["referredBy"].toString().isNotEmpty)
              ? data["referredBy"]
              : null,
          "hobbies": data["hobbies"] ?? [],
          "sports": data["sports"] ?? [],
          "film": data["film"] ?? [],
          "music": data["music"] ?? [],
          "travel": data["travel"] ?? [],
          "searchPreferences": data["searchPreferences"],
          "createdAt": data["createdAt"],
          "updatedAt": data["updatedAt"],
          "__v": data["__v"],
          "age": data["age"],
          "bio": data["bio"],
          "gender": data["gender"],
          "firstName": data["firstName"],
          "lastName": data["lastName"],
          "name": "${data["firstName"] ?? ''} ${data["lastName"] ?? ''}".trim(),
          "videoUrl": data["videoUrl"],
          "images": data["images"] is List
              ? data["images"].map((img) {
                  // Handle both string URLs and object structures
                  if (img is String) {
                    return img;
                  } else if (img is Map) {
                    return img["imageUrl"];
                  }
                  return "";
                }).toList()
              : [],
        };

        setState(() {
          _user = Profiledetails.fromJson(userData);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load profile data';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading profile: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ApiController>(
      builder: (context, apiController, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF9F5FF),
          appBar: AppBar(
            title: const Text(
              "My Profile",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
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
              PopupMenuButton<int>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                onSelected: (value) async {
                  if (value == 0) {
                    // Edit Profile
                    // Navigate to introduce yourself screen for editing
                    final updated = await Navigator.pushNamed(
                      context,
                      AppRoutes.introduceYourself,
                    );
                    if (updated == true) {
                      // Refresh profile data after returning from edit
                      await _fetchUserProfile();
                    }
                  } else if (value == 1) {
                    // Settings
                    // Navigate to settings
                  } else if (value == 2) {
                    // Logout
                    // Handle logout
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 0, child: Text("Edit Profile")),
                  const PopupMenuItem(value: 1, child: Text("Settings")),
                  const PopupMenuItem(value: 2, child: Text("Logout")),
                ],
              ),
            ],
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text(_error!))
              : _user == null
              ? const Center(child: Text('No profile data available'))
              : _buildProfileContent(),
        );
      },
    );
  }

  Widget _buildProfileContent() {
    // Double check that _user is not null (should not be needed due to check in body, but added for safety)
    if (_user == null) {
      return const Center(child: Text('No profile data available'));
    }

    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (OverscrollIndicatorNotification overscroll) {
        overscroll.disallowIndicator();
        return true;
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage:
                        (_user?.images.isNotEmpty ?? false) &&
                            ((_user?.images.first.toString() ?? '').isNotEmpty)
                        ? NetworkImage(_user!.images.first.toString())
                        : null,
                    child:
                        !(_user?.images.isNotEmpty ?? false) ||
                            ((_user?.images.first.toString() ?? '').isEmpty)
                        ? const Icon(Icons.person, size: 40, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFFFF55A5), Color(0xFF9A00F0)],
                            ).createShader(bounds),
                            blendMode: BlendMode.srcIn,
                            child: Text(
                              '${_user?.name ?? "No Name"}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text(
                                "Age: ",
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                "${_user?.age ?? 'N/A'} years",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                "Balance: ",
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                "${_user?.walletBalance ?? 0}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _buildInfoChip(
                                Icons.verified,
                                "Verified",
                                _user?.isVerified == true,
                              ),
                              const SizedBox(width: 8),
                              _buildInfoChip(
                                Icons.check_circle,
                                "Active",
                                _user?.isActive == true,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Sections for profile details
            _buildSection("Bio", _user?.bio ?? "No bio available"),

            _buildSectionWithChips(
              "Interests",
              (_user?.interests.cast<String>() ?? []).cast<String>(),
            ),

            _buildSectionWithChips(
              "Languages",
              (_user?.languages.cast<String>() ?? []).cast<String>(),
            ),

            _buildSectionWithChips(
              "Hobbies",
              (_user?.hobbies.cast<String>() ?? []).cast<String>(),
            ),

            _buildSectionWithChips(
              "Sports",
              (_user?.sports.cast<String>() ?? []).cast<String>(),
            ),

            _buildSectionWithChips(
              "Film",
              (_user?.film.cast<String>() ?? []).cast<String>(),
            ),

            _buildSectionWithChips(
              "Music",
              (_user?.music.cast<String>() ?? []).cast<String>(),
            ),

            _buildSectionWithChips(
              "Travel",
              (_user?.travel.cast<String>() ?? []).cast<String>(),
            ),

            const SizedBox(height: 24),

            // Contact Info
            _buildContactSection(),

            const SizedBox(height: 24),

            // Stats
            _buildStatsSection(),

            const SizedBox(height: 24),

            // Say Hi and Call buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 120,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.pinkAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    icon: const Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.pinkAccent,
                    ),
                    label: const Text(
                      'Say Hi',
                      style: TextStyle(color: Colors.pinkAccent),
                    ),
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 120,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    icon: const Icon(Icons.phone, color: Colors.white),
                    label: const Text(
                      'Call',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? Colors.green : Colors.grey,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: isActive ? Colors.green : Colors.grey),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isActive ? Colors.green : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(content, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionWithChips(String title, List<String> items) {
    if (items.isEmpty || items.every((item) => item.isEmpty)) {
      return const SizedBox.shrink();
    }

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
                .where((item) => item.isNotEmpty)
                .map(
                  (e) => Chip(
                    label: Text(e),
                    backgroundColor: Colors.pinkAccent.withOpacity(0.1),
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

  Widget _buildContactSection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Contact Info",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildContactRow(Icons.email, "Email", (_user?.email) ?? "N/A"),
                const Divider(height: 20),
                _buildContactRow(
                  Icons.phone,
                  "Phone",
                  (_user?.mobileNumber) ?? "N/A",
                ),
                const Divider(height: 20),
                _buildContactRow(
                  Icons.cake,
                  "Age",
                  "${(_user?.age) ?? 'N/A'} years",
                ),
                const Divider(height: 20),
                _buildContactRow(
                  Icons.account_balance_wallet,
                  "Wallet Balance",
                  "\$${(_user?.walletBalance) ?? 0}",
                ),
                const Divider(height: 20),
                _buildContactRow(
                  Icons.monetization_on,
                  "Coin Balance",
                  "${(_user?.coinBalance) ?? 0} coins",
                ),
                const Divider(height: 20),
                _buildContactRow(
                  Icons.account_balance,
                  "Balance",
                  "${(_user?.balance) ?? 0}",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.pinkAccent),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Statistics",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(
                  "Followers",
                  "${(_user?.malefollowers.length) ?? 0}",
                ),
                _buildStatCard(
                  "Following",
                  "${(_user?.malefollowing.length) ?? 0}",
                ),
                _buildStatCard(
                  "Favorites",
                  "${(_user?.favourites.length) ?? 0}",
                ),
                _buildStatCard("Referrals", (_user?.referralCode) ?? "N/A"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.pinkAccent,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

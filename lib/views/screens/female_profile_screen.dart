import 'package:flutter/material.dart';
import 'package:Boy_flow/models/female_user.dart';

class FemaleProfileScreen extends StatelessWidget {
  final FemaleUser user;
  const FemaleProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      /// ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text("My Profile", style: TextStyle(color: Colors.white)),
        actions: const [Icon(Icons.more_vert, color: Colors.white)],
      ),

      /// ================= BODY =================
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
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
                            user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                            ? NetworkImage(user.avatarUrl!)
                            : null,
                        child: user.avatarUrl == null || user.avatarUrl!.isEmpty
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
                                  user.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.verified,
                                  color: Colors.purple,
                                  size: 18,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Age: ${user.age} years",
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
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pinkAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {},
                        child: const Text("Follow"),
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
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.chat, color: Colors.pinkAccent),
                      label: const Text(
                        "Say Hi",
                        style: TextStyle(color: Colors.pinkAccent),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.pinkAccent),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.call, color: Colors.white),
                      label: const Text("Call"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {},
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
}

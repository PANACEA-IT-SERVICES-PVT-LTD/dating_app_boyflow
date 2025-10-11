import 'package:flutter/material.dart';

class ProfileGalleryScreen extends StatefulWidget {
  const ProfileGalleryScreen({super.key});

  @override
  State<ProfileGalleryScreen> createState() => _ProfileGalleryScreenState();
}

class _ProfileGalleryScreenState extends State<ProfileGalleryScreen> {
  bool isOnline = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5FF), // light soft background
      appBar: AppBar(
        title: const Text("My Profile", style: TextStyle(color: Colors.white)),
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
          Row(
            children: [
              Text(
                isOnline ? "Online" : "Offline",
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(width: 8),
              Switch(
                value: isOnline,
                onChanged: (val) => setState(() => isOnline = val),
                activeColor: Colors.green,
                inactiveTrackColor: Colors.grey.shade400,
              ),
              const SizedBox(width: 12),
            ],
          ),
        ],
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: ProfileTabEditable(),
      ),
    );
  }
}

class ProfileTabEditable extends StatefulWidget {
  const ProfileTabEditable({super.key});

  @override
  State<ProfileTabEditable> createState() => _ProfileTabEditableState();
}

class _ProfileTabEditableState extends State<ProfileTabEditable> {
  final Map<String, List<String>> profileDetails = {
    "My Languages": ["Telugu"],
    "My Interests": ["Family and parenting", "Society and politics"],
    "Hobbies": ["Cooking", "Writing"],
    "Sports": ["Cricket"],
    "Film": ["No Films"],
    "Music": ["2020s"],
    "Travel": ["Mountains"],
  };

  // small helper to create gradient text used for values
  Widget _gradientText(String text, {double fontSize = 14, FontWeight fw = FontWeight.bold}) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (Rect bounds) {
        return const LinearGradient(
          colors: [Color(0xFFFF00CC), Color(0xFF9A00F0)],
        ).createShader(bounds);
      },
      child: Text(
        text,
        style: TextStyle(fontWeight: fw, fontSize: fontSize),
      ),
    );
  }

  // Profile header card widget
  Widget _profileHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white, // card uses white background for clear separation
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar (placeholder initial)
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFFF00CC), Color(0xFF9A00F0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Text(
                "J",
                style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(width: 14),

          // Name + basic details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name (gradient)
                _gradientText("Jennie", fontSize: 18, fw: FontWeight.w700),
                const SizedBox(height: 6),

                // Gender row
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 16, color: Colors.black54),
                    const SizedBox(width: 6),
                    const Text("Gender: ", style: TextStyle(color: Colors.black54)),
                    _gradientText("Female", fontSize: 14, fw: FontWeight.w600),
                  ],
                ),

                const SizedBox(height: 6),

                // DOB row
                Row(
                  children: [
                    const Icon(Icons.cake_outlined, size: 16, color: Colors.black54),
                    const SizedBox(width: 6),
                    const Text("DOB: ", style: TextStyle(color: Colors.black54)),
                    _gradientText("19th July 2025", fontSize: 14, fw: FontWeight.w600),
                  ],
                ),
              ],
            ),
          ),

          // Optional edit button (commented out)
          // IconButton(onPressed: () {}, icon: Icon(Icons.edit, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildRowLabelValue(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120, // keeps labels aligned
            child: Row(
              children: [
                Text(label, style: const TextStyle(color: Colors.black87)),
                const Text(" : "),
              ],
            ),
          ),
          Expanded(child: _gradientText(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile header card (replaces inline Nick Name, Gender, DOB)
        _profileHeaderCard(),

        // If you still want the individual label/value rows below the header, uncomment:
        // _buildRowLabelValue("Nick Name", "Jennie"),
        // _buildRowLabelValue("Gender", "Female"),
        // _buildRowLabelValue("Date of Birth", "19th July 2025"),
        // const SizedBox(height: 12),

        // Profile detail sections (left-aligned, minimal)
        ...profileDetails.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.key,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: entry.value.map((item) {
                    return Chip(
                      label: Text(item),
                      backgroundColor: Colors.pink[50],
                      labelStyle: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w400,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}

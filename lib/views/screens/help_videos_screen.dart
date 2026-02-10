import 'package:Boy_flow/api_service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:Boy_flow/views/screens/mainhome.dart';
import 'package:url_launcher/url_launcher.dart';
// Removed unused/invalid import

class HelpVideosScreen extends StatefulWidget {
  const HelpVideosScreen({super.key});

  @override
  State<HelpVideosScreen> createState() => _HelpVideosScreenState();
}

class _HelpVideosScreenState extends State<HelpVideosScreen> {
  bool isOnline = false;

  final List<Map<String, String>> videoList = [
    {
      "title": "Introduction",
      "url": "https://www.youtube.com/watch?v=abcd1234",
    },
    {
      "title": "How to transfer amount to the agency",
      "url": "https://www.youtube.com/watch?v=wxyz5678",
    },
  ];

  void _launchVideo(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Could not open video.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Gradient Header Bar (Same Height)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 40,
              left: 14,
              right: 14,
              bottom: 14,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF55A5), Color(0xFF9A00F0)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 4,
                  ), // 👈 pushes icon slightly down
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const MainHome()),
                      );
                    },
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                const Padding(
                  padding: EdgeInsets.only(
                    top: 4,
                  ), // 👈 pushes title slightly down
                  child: Text(
                    "Help Videos",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Spacer(),
                const Text("Online", style: TextStyle(color: Colors.white)),
                Switch(
                  value: isOnline,
                  onChanged: (val) => setState(() => isOnline = val),
                  activeColor: Colors.green,
                  inactiveTrackColor: Colors.grey.shade400,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Video List
          Expanded(
            child: ListView.builder(
              itemCount: videoList.length,
              itemBuilder: (context, index) {
                final video = videoList[index];
                return GestureDetector(
                  onTap: () => _launchVideo(video['url']!),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/youtube.png',
                          width: 40,
                          height: 30,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            video['title']!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

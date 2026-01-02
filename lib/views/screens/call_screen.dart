import 'package:Boy_flow/views/screens/profile_gallery_screen.dart';
import 'package:flutter/material.dart';
// Removed unused import

class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  bool isOnline = false;

  final List<Map<String, dynamic>> callData = [
    {
      "name": "John Borino",
      "time": "Today 3:06 PM",
      "duration": "(11m 20 sec)",
      "count": "01",
      "rating": "Very Good",
      "age": "22",
      "gender": "Male",
      "id": "235363",
      "follower": "Yes",
      "referral": "Yes",
      "image": "assets/sample_user.jpg",
    },
    {
      "name": "John Borino",
      "time": "Today 3:06 PM",
      "duration": "(11m 20 sec)",
      "count": "01",
      "rating": "Very Good",
      "age": "22",
      "gender": "Male",
      "id": "235363",
      "follower": "Yes",
      "referral": "Yes",
      "image": "assets/sample_user.jpg",
    },
    {
      "name": "John Borino",
      "time": "Today 3:06 PM",
      "duration": "(11m 20 sec)",
      "count": "01",
      "rating": "Bad",
      "age": "22",
      "gender": "Male",
      "id": "235363",
      "follower": "Yes",
      "referral": "Yes",
      "image": "assets/sample_user.jpg",
    },
    {
      "name": "John Borino",
      "time": "Today 3:06 PM",
      "duration": "(11m 20 sec)",
      "count": "01",
      "rating": "Very Good",
      "age": "22",
      "gender": "Male",
      "id": "235363",
      "follower": "Yes",
      "referral": "Yes",
      "image": "assets/sample_user.jpg",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          automaticallyImplyLeading: false,
          title: const Text("Calls", style: TextStyle(color: Colors.white)),
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
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: callData.length,
        itemBuilder: (_, index) {
          final call = callData[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileGalleryScreen()),
              );
            },

            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left Column
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            call['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF55A5), Color(0xFF9A00F0)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              call['count'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.call_received,
                            color: Colors.green,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${call['time']}  ${call['duration']}",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Right Side Rating
                  Text(
                    call['rating'],
                    style: TextStyle(
                      color: call['rating'] == 'Bad'
                          ? Colors.red
                          : Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(height: 0),
    );
  }
}

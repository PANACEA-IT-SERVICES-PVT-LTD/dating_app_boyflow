import 'package:flutter/material.dart';

class IntroduceYourselfScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Introduce Yourself'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFfa5ac7), Color(0xFF7b6aff)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundImage: AssetImage(
                      'assets/profile.jpg',
                    ), // Replace with your asset
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Sophie92',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.verified,
                              color: Color(0xFFfa5ac7),
                              size: 18,
                            ),
                          ],
                        ),
                        Text(
                          'Age: 22 years',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        Text(
                          '2353 Followers',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 4),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFfa5ac7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 6,
                            ),
                          ),
                          child: Text('Follow'),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Icon(Icons.circle, color: Colors.green, size: 14),
                      Text(
                        'Online',
                        style: TextStyle(color: Colors.green, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            // Languages
            Text('Languages', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFFf8e6f6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(radius: 24, backgroundColor: Colors.grey[300]),
                  SizedBox(width: 12),
                  Text('Telugu', style: TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            SizedBox(height: 24),
            // Interests
            Text('Interests', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _chip('Family and parenting'),
                _chip('Society and politics'),
              ],
            ),
            SizedBox(height: 24),
            // Hobbies
            Text('Hobbies', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [_chip('Cooking'), _chip('Writing')],
            ),
            SizedBox(height: 24),
            // Sports
            Text('Sports', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            _chip('Cricket'),
            SizedBox(height: 24),
            // Film
            Text('Film', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            _chip('NO FILMS'),
            SizedBox(height: 24),
            // Music
            Text('Music', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            _chip('2020s'),
            SizedBox(height: 24),
            // Travel
            Text('Travel', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            _chip('Mountains'),
            SizedBox(height: 32),
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: Icon(
                      Icons.chat_bubble_outline,
                      color: Color(0xFFfa5ac7),
                    ),
                    label: Text(
                      'Say Hi',
                      style: TextStyle(color: Color(0xFFfa5ac7)),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Color(0xFFfa5ac7)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/homepage');
                    },
                    icon: Icon(Icons.call, color: Colors.white),
                    label: Text('Call'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFfa5ac7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Color(0xFFf8e6f6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(label, style: TextStyle(color: Colors.black87)),
    );
  }
}

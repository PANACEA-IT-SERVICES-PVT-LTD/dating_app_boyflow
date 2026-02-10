import 'package:flutter/material.dart';

class MaleDashboardScreen extends StatefulWidget {
  @override
  _MaleDashboardScreenState createState() => _MaleDashboardScreenState();
}

class _MaleDashboardScreenState extends State<MaleDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Male Dashboard'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to the Male Dashboard',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // Add dashboard content here
            // This could include user stats, recent activity, notifications, etc.
          ],
        ),
      ),
    );
  }
}

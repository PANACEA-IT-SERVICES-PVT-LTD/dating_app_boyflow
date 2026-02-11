import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../api_service/api_endpoint.dart';

class ApiUserListScreen extends StatefulWidget {
  @override
  _ApiUserListScreenState createState() => _ApiUserListScreenState();
}

class _ApiUserListScreenState extends State<ApiUserListScreen> {
  List<dynamic> users = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchDashboard();
  }

  Future<void> fetchDashboard() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiEndPoints.baseUrls}${ApiEndPoints.dashboardEndpoint}?section=all&page=1&limit=10',
        ),
      );
      final data = json.decode(response.body);
      if (data['success'] == true) {
        setState(() {
          users = data['data']['results'];
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load data';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Center(child: CircularProgressIndicator());
    if (error != null) return Center(child: Text('Error: \n$error'));
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return ListTile(
          leading: user['images'] != null && user['images'].isNotEmpty
              ? CircleAvatar(
                  backgroundImage: NetworkImage(user['images'][0]['imageUrl']),
                )
              : CircleAvatar(child: Icon(Icons.person)),
          title: Text(user['name'] ?? ''),
          subtitle: Text(user['bio'] ?? ''),
          trailing: user['onlineStatus'] == true
              ? Icon(Icons.circle, color: Colors.green, size: 12)
              : null,
        );
      },
    );
  }
}

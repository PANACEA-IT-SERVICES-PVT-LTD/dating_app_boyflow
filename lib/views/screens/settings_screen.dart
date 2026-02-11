import 'package:flutter/material.dart';
import 'package:boy_flow/views/screens/BlockListScreen.dart';
import 'package:boy_flow/views/screens/login_screen.dart'; // Ensure this exists
import 'package:provider/provider.dart';
import 'package:boy_flow/controllers/api_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isOnline = false;
  bool beautyFilters = false;
  bool hideMyAge = false; // removed noCallsDuringLivestream

  void logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void deleteAccount() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Delete Account"),
        content: const Text("Are you sure you want to delete your account? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 244, 54, 214),
            ),
            onPressed: () async {
              final apiController = Provider.of<ApiController>(
                context,
                listen: false,
              );
              
              Navigator.pop(dialogContext); // Close dialog

              // Show loading overlay or indicator if desired
              // For now, we'll just try to delete
              
              try {
                final messenger = ScaffoldMessenger.of(context);
                await apiController.deleteAccount();
                
                if (!mounted) return;
                
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text("Account deleted successfully"),
                    backgroundColor: Colors.green,
                  ),
                );

                // Wait a moment for snackbar
                await Future.delayed(const Duration(seconds: 1));
                
                if (!mounted) return;
                
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Failed to delete account: $e"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double fontSize = 16;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Settings", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
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
          
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              "Block list",
              style: TextStyle(fontSize: fontSize),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BlockListScreen()),
              );
            },
          ),
         
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: beautyFilters,
            onChanged: (value) => setState(() => beautyFilters = value!),
            title: const Text(
              "Do not Disturb",
              style: TextStyle(fontSize: fontSize),
            ),
          ),        
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(border: OutlineInputBorder()),
            value: "Our Policies",
            items: const [
              DropdownMenuItem(
                value: "Our Policies",
                child: Text("Our Policies"),
              ),
              DropdownMenuItem(
                value: "Privacy Policy",
                child: Text("Privacy Policy"),
              ),
              DropdownMenuItem(
                value: "Terms & Conditions",
                child: Text("Terms & Conditions"),
              ),
              DropdownMenuItem(
                value: "Help & Support",
                child: Text("Help & Support"),
              ),
            ],
            onChanged: (value) {},
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: deleteAccount,
            child: const Text(
              "Delete Account",
              style: TextStyle(
                fontSize: fontSize,
                color: Color.fromARGB(255, 244, 54, 219),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: GestureDetector(
              onTap: logout,
              child: const Text(
                "LogOut",
                style: TextStyle(
                  fontSize: fontSize,
                  color: Color.fromARGB(255, 244, 54, 219),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

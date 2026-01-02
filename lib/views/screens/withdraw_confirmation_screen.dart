import 'package:flutter/material.dart';
import '../../utils/colors.dart'; // for AppColors.white etc.
// Removed unused import
import 'withdraw_request_screen.dart'; // to navigate back

class WithdrawConfirmationScreen extends StatelessWidget {
  final String amount;

  const WithdrawConfirmationScreen({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const WithdrawRequestScreen(),
                ),
              );
            },
          ),
          title: const Text(
            "My  Withdraws",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Navigate to KYC screen
                Navigator.pushNamed(context, '/updatekyc');
              },
              child: const Text(
                "Update KYC",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
          centerTitle: false,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF00CC), Color.fromARGB(255, 153, 51, 151)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/withdraw.png', // make sure this image exists
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              "Your Payment\nwill be credited in\n23 Hrs",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Please wait for 22 Hrs 22 Min 22 Sec",
              style: TextStyle(color: Colors.red, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

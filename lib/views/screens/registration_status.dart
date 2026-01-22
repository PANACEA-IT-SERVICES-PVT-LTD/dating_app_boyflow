import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';

class RegistrationStatusScreen extends StatelessWidget {
  const RegistrationStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.introduceYourself,
            );
          },
        ),
        title: const Text(
          "Registration Status",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 4),
            const Text(
              "Please check your status here",
              style: TextStyle(color: Colors.black45, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Image with rounded top corners
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/Registration.png',
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 30),

            // Main bold message
            const Text(
              "Our Team is\nreviewing Your Details\nand update",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.pink,
              ),
            ),
            const SizedBox(height: 10),

            // Countdown text
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                text: "Please wait for ",
                style: TextStyle(fontSize: 14, color: Colors.black54),
                children: [
                  TextSpan(
                    text: "22 Hrs 22 Min 22 Sec",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.pink,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Register button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.homepage);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Register",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

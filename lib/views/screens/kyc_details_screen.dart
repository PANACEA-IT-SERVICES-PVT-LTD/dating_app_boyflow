import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../widgets/gradient_button.dart';
import 'package:boy_flow/widgets/common_top_bar.dart';
import '../../views/screens/update_kyc_details_screen.dart';

class KYCDetailsScreen extends StatefulWidget {
  const KYCDetailsScreen({super.key});

  @override
  State<KYCDetailsScreen> createState() => _KYCDetailsScreenState();
}

class _KYCDetailsScreenState extends State<KYCDetailsScreen> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CommonTopBar(
        title: 'KYC Details',
        showCoin: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          _buildCustomTabs(),
          const SizedBox(height: 16),
          Expanded(
            child: selectedTab == 0 ? _buildAccountTab() : _buildUpiTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedTab = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: selectedTab == 0
                      ? const LinearGradient(
                          colors: [AppColors.buttonStart, AppColors.buttonEnd],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: selectedTab == 0 ? null : Colors.white,
                  border: Border.all(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(30),
                ),
                alignment: Alignment.center,
                child: selectedTab == 0
                    ? const Text(
                        "Account Details",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [AppColors.buttonStart, AppColors.buttonEnd],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: const Text(
                          "Account Details",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedTab = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: selectedTab == 1
                      ? const LinearGradient(
                          colors: [AppColors.buttonStart, AppColors.buttonEnd],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: selectedTab == 1 ? null : Colors.white,
                  border: Border.all(
                    color: selectedTab == 1
                        ? Colors.transparent
                        : AppColors.buttonEnd,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                alignment: Alignment.center,
                child: selectedTab == 1
                    ? const Text(
                        "UPI ID",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [AppColors.buttonStart, AppColors.buttonEnd],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: const Text(
                          "UPI ID",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _kycTextField("Name"),
          const SizedBox(height: 12),
          _kycTextField("Account Number"),
          const SizedBox(height: 12),
          _kycTextField("IFSC Code"),
          const Spacer(),
          GradientButton(
            text: "Complete KYC",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UpdateKycScreen()),
              );
            },
            buttonText: '',
          ),
        ],
      ),
    );
  }

  Widget _buildUpiTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _kycTextField("Enter UPI ID"),
          const Spacer(),
          GradientButton(
            text: "Complete KYC",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UpdateKycScreen()),
              );
            },
            buttonText: '',
          ),
        ],
      ),
    );
  }

  Widget _kycTextField(String hint) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color.fromARGB(255, 253, 225, 238).withOpacity(0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
      ),
    );
  }
}

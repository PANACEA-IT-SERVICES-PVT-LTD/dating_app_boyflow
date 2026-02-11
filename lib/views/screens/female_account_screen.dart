import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:boy_flow/controllers/profile_controller.dart';
import 'package:boy_flow/models/profile_model.dart';

class FemaleAccountScreen extends StatelessWidget {
  const FemaleAccountScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileController()..fetchProfile(),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: AppBar(
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                const Text(
                  "Account",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Image.asset("assets/coins.png", width: 22, height: 22),
                    const SizedBox(width: 4),
                    const Text(
                      "0", // Placeholder - would be dynamic in real app
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
        body: Consumer<ProfileController>(
          builder: (context, controller, child) {
            if (controller.isLoading && controller.profileData == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.error != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 60),
                      const SizedBox(height: 16),
                      Text(
                        controller.error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: controller.fetchProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF00CC),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final profile = controller.profileData;
            if (profile == null) {
              return const Center(
                child: Text(
                  'No profile data available',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            return _buildProfileContent(profile);
          },
        ),
      ),
    );
  }

  Widget _buildProfileContent(ProfileModel profile) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile Image
          CircleAvatar(
            radius: 60,
            backgroundImage: profile.profileImageUrl != null
                ? NetworkImage(profile.profileImageUrl!)
                : null,
            backgroundColor: Colors.pink.shade100,
            child: profile.profileImageUrl == null
                ? const Icon(Icons.person, size: 60, color: Colors.white)
                : null,
          ),
          const SizedBox(height: 24),

          // Name
          Text(
            '${profile.firstName} ${profile.lastName}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Gender
          Text(
            profile.gender,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),

          // Date of Birth
          Text(
            'DOB: ${profile.dateOfBirth}',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 32),

          // Static sections (not from API)
          _buildSection('Hobbies', ['Cooking', 'Reading']),
          const SizedBox(height: 16),
          _buildSection('Interests', ['Technology', 'Travel']),
          const SizedBox(height: 16),
          _buildSection('Religion', ['Hindu']),
          const SizedBox(height: 16),
          _buildSection('Sports', ['Cricket', 'Football']),
          const SizedBox(height: 16),
          _buildSection('Travel', ['Mountains', 'Beaches']),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<String> items) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: items
                .map(
                  (item) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.pink.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item,
                      style: const TextStyle(color: Colors.pink, fontSize: 14),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

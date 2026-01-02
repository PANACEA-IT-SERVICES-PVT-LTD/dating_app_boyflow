// ignore_for_file: sort_child_properties_last

import 'dart:io' show File;
import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
// Removed unused import: account_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
// import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../widgets/gradient_button.dart';
// Removed unused import: registration_status.dart
import '../../api_service/api_endpoint.dart';
// import '../../controllers/api_controller.dart'; // <- make sure the path is correct in your project
// import '../../api_service/api_endpoint.dart'; // only used for constants in comments

// Helper to save token after login
Future<void> saveLoginToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('token', token);
  debugPrint('Saved login token: $token');
}

/// Introduce Yourself Screen
///
/// This version wires the UI to your ApiController and posts the profile
/// details (name, age, gender, bio, interests, languages, videoUrl, photo).
///
/// What you need in ApiController (already added in the updated controller I sent):
///   Future<bool> updateProfileDetails({
///     required String name,
///     required int age,
///     required String gender,
///     required String bio,
///     required List<String> interestIds,
///     required List<String> languageIds,
///     String? videoUrl,
///     String? photoUrl,
///   })
/// which should POST to your backend endpoint (e.g., ApiEndPoints.updateProfile)
/// using ApiService.postData.
class IntroduceYourselfScreen extends StatefulWidget {
  const IntroduceYourselfScreen({super.key});

  @override
  State<IntroduceYourselfScreen> createState() =>
      _IntroduceYourselfScreenState();
}

class _IntroduceYourselfScreenState extends State<IntroduceYourselfScreen> {
  Future<void> _uploadProfileImage(dynamic imageFile) async {
    // TODO: Implement image upload logic
    // For now, just simulate upload and set a dummy URL
    setState(() {
      _uploadedPhotoUrl =
          'https://dummyimage.com/200x200/cccccc/000000&text=Uploaded';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ (Stub) Image uploaded successfully')),
    );
  }

  // Add stubs for missing methods at the bottom if needed
  File? _photo; // selected image file (local)
  VideoPlayerController? _videoController;

  String? _uploadedPhotoUrl;

  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _ageController = TextEditingController();

  String _gender = 'Male'; // default to match sample payload

  // Removed interests and languages

  @override
  void initState() {
    super.initState();
    _fetchCurrentMaleProfile();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _firstNameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      if (kIsWeb) {
        setState(() => _photo = null); // Don't use File on web
        await _uploadProfileImage(picked); // Pass XFile
      } else {
        setState(() => _photo = File(picked.path));
        await _uploadProfileImage(File(picked.path));
      }
    }
  }

  Future<void> _fetchCurrentMaleProfile() async {
    try {
      final url = Uri.parse("${ApiEndPoints.baseUrls}${ApiEndPoints.maleMe}");
      final resp = await http.get(url);
      dynamic body;
      try {
        body = resp.body.isNotEmpty ? jsonDecode(resp.body) : {};
      } catch (_) {
        body = {"raw": resp.body};
      }
      if (!mounted) return;
      if (body is Map && body["success"] == true && body["data"] is Map) {
        final data = body["data"] as Map;
        final firstName = (data["firstName"] ?? "").toString();
        final gender = (data["gender"] ?? "").toString();
        final dobStr = (data["dateOfBirth"] ?? "").toString();
        final images = data["images"];
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() {
            _firstNameController.text = firstName;
            if (dobStr.isNotEmpty) {
              final dob = DateTime.tryParse(dobStr);
              if (dob != null) {
                final now = DateTime.now();
                final years =
                    now.year -
                    dob.year -
                    ((now.month < dob.month ||
                            (now.month == dob.month && now.day < dob.day))
                        ? 1
                        : 0);
                if (years > 0) {
                  _ageController.text = years.toString();
                }
              }
            }
            if (gender.toLowerCase() == 'male') {
              _gender = 'Male';
            } else if (gender.toLowerCase() == 'female') {
              _gender = 'Female';
            }
            if (images is List && images.isNotEmpty) {
              _uploadedPhotoUrl = images.first.toString();
            }
          });
        });
      }
    } catch (_) {
      if (!mounted) return;
    }
  }

  Future<void> _onApprovePressed() async {
    if (!_formKey.currentState!.validate()) return;

    // Check if image is uploaded
    if (_uploadedPhotoUrl == null || _uploadedPhotoUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Please upload a profile image before submitting.'),
        ),
      );
      return;
    }
    final uri = Uri.parse(
      "${ApiEndPoints.baseUrls}${ApiEndPoints.maleProfileDetails}",
    );

    final firstName = _firstNameController.text.trim();
    String? dateOfBirth;
    final ageText = _ageController.text.trim();
    final age = int.tryParse(ageText);
    if (age != null && age > 0) {
      final now = DateTime.now();
      final approxDob = DateTime(now.year - age, 1, 1);
      dateOfBirth = approxDob.toIso8601String().split('T').first;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      String? token =
          prefs.getString('token') ?? prefs.getString('access_token') ?? '';
      if (token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Login required. Token missing.')),
        );
        return;
      }

      final resp = await http.patch(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "firstName": firstName,
          if (dateOfBirth != null) "dateOfBirth": dateOfBirth,
          "gender": _gender.toLowerCase(),
          if (_uploadedPhotoUrl != null && _uploadedPhotoUrl!.isNotEmpty)
            "images": [_uploadedPhotoUrl],
        }),
      );

      dynamic body;
      try {
        body = resp.body.isNotEmpty ? jsonDecode(resp.body) : {};
      } catch (_) {
        body = {"raw": resp.body};
      }

      if (!mounted) return;

      if (body is Map && body["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Profile updated successfully!')),
        );
        Navigator.pop(context, true); // Return true to indicate update
      } else {
        final msg =
            (body is Map ? (body["message"] ?? body["error"]) : null) ??
            "Profile update failed";
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ $msg')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error updating profile: \\${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mock loading state for screen-only development
    bool isLoading = false;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          leading: const BackButton(color: Colors.white),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          title: Column(
            children: [
              const Text(
                'Profile Update',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
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
      body: AbsorbPointer(
        absorbing: isLoading,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    // Photo (circular avatar)
                    GestureDetector(
                      onTap: _pickImage,
                      child: _photo != null
                          ? CircleAvatar(
                              radius: 60,
                              backgroundImage: FileImage(_photo!),
                            )
                          : (_uploadedPhotoUrl != null &&
                                    _uploadedPhotoUrl!.isNotEmpty
                                ? CircleAvatar(
                                    radius: 60,
                                    backgroundImage: NetworkImage(
                                      _uploadedPhotoUrl!,
                                    ),
                                  )
                                : const _DottedBorderBox(
                                    label: 'Upload photo',
                                  )),
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Name', style: _labelStyle()),
                    ),
                    const SizedBox(height: 6),
                    _buildRoundedTextField(
                      controller: _firstNameController,
                      hint: 'Enter your name',
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Name is required'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Age', style: _labelStyle()),
                    ),
                    const SizedBox(height: 6),
                    _buildRoundedTextField(
                      controller: _ageController,
                      hint: '30',
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'Age is required';
                        final n = int.tryParse(v.trim());
                        if (n == null || n < 18 || n > 99)
                          return 'Enter a valid age (18-99)';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Gender', style: _labelStyle()),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _genderOption('Male', Icons.male),
                        const SizedBox(width: 15),
                        _genderOption('Female', Icons.female),
                      ],
                    ),
                    const SizedBox(height: 30),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: GradientButton(
                        text: isLoading
                            ? 'Saving...'
                            : 'Submit', // TODO: Remove dead code above if unreachable
                        onPressed: _onApprovePressed,
                        buttonText: '',
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _genderOption(String value, IconData icon) {
    final isSelected = _gender == value;
    return ChoiceChip(
      labelPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : const Color(0xFFE91EC7),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
      selected: isSelected,
      selectedColor: const Color(0xFFE91EC7),
      backgroundColor: const Color(0xFFF5F5F5),
      shape: const StadiumBorder(),
      onSelected: (_) {
        setState(() => _gender = value);
      },
    );
  }
}

TextStyle _labelStyle() {
  return const TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 14,
    color: Colors.black,
  );
}

class _DottedBorderBox extends StatelessWidget {
  final String label;

  const _DottedBorderBox({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFFE91EC7),
          width: 1,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(10),
        color: Colors.transparent,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_a_photo, color: Color(0xFFE91EC7)),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Color(0xFFE91EC7), fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Rounded text field helper
Widget _buildRoundedTextField({
  required TextEditingController controller,
  required String hint,
  int maxLines = 1,
  TextInputType keyboardType = TextInputType.text,
  String? Function(String?)? validator,
}) {
  return TextFormField(
    controller: controller,
    maxLines: maxLines,
    keyboardType: keyboardType,
    validator: validator,
    decoration: InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF9E6F5),
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
    ),
  );
}

// ignore_for_file: sort_child_properties_last

import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
// Removed unused import: account_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../widgets/gradient_button.dart';
// Removed unused import: registration_status.dart
import '../../api_service/api_endpoint.dart';
import '../../controllers/api_controller.dart'; // <- make sure the path is correct in your project
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
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};

  File? _selectedImage;

  // Controllers for text fields
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _dobController = TextEditingController();
  final _bioController = TextEditingController();
  final _heightController = TextEditingController();
  final _searchPreferencesController = TextEditingController();
  final _filmController = TextEditingController();
  final _musicController = TextEditingController();
  final _travelController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  // Dropdowns/multi-selects
  String? _gender = 'male';
  String? _selectedReligionId;
  List<String> _interests = [];
  List<String> _languages = [];
  List<String> _relationshipGoals = [];
  List<String> _hobbies = [];
  List<String> _sports = [];

  // Sample religion options - in a real app, you'd fetch these from an API
  final List<Map<String, String>> _religions = [
    {'id': '694f63d08389fc82a4345083', 'name': 'Hindu'},
    {'id': '694f63d08389fc82a4345084', 'name': 'Muslim'},
    {'id': '694f63d08389fc82a4345085', 'name': 'Christian'},
    {'id': '694f63d08389fc82a4345086', 'name': 'Sikh'},
    {'id': '694f63d08389fc82a4345087', 'name': 'Buddhist'},
    {'id': '694f63d08389fc82a4345088', 'name': 'Jewish'},
    {'id': '694f63d08389fc82a4345089', 'name': 'Other'},
  ];

  // (No duplicate _submit method here)

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _mobileController.dispose();
    _dobController.dispose();
    _bioController.dispose();
    _heightController.dispose();
    _searchPreferencesController.dispose();
    _filmController.dispose();
    _musicController.dispose();
    _travelController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final Map<String, dynamic> payload = {
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'mobileNumber': _mobileController.text.trim(),
      'dateOfBirth': _dobController.text.trim(),
      'gender': _gender,
      'bio': _bioController.text.trim(),
      'interests': _interests,
      'languages': _languages,
      'religion': _selectedReligionId,
      'relationshipGoals': _relationshipGoals,
      'height': _heightController.text.trim(),
      'searchPreferences': _searchPreferencesController.text.trim(),
      'hobbies': _hobbies,
      'sports': _sports,
      'film': _filmController.text.trim(),
      'music': _musicController.text.trim(),
      'travel': _travelController.text.trim(),
      'latitude': _latitudeController.text.trim(),
      'longitude': _longitudeController.text.trim(),
    };

    List<http.MultipartFile> images = [];
    if (_selectedImage != null) {
      images.add(
        await http.MultipartFile.fromPath('images', _selectedImage!.path),
      );
    }

    try {
      final apiController = Provider.of<ApiController>(context, listen: false);
      await apiController.updateUserProfile(
        fields: payload,
        images: images.isNotEmpty ? images : null,
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile updated!')));
      // Navigate to dashboard or next screen
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Introduce Yourself')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _mobileController,
                decoration: const InputDecoration(labelText: 'Mobile Number'),
              ),
              TextFormField(
                controller: _dobController,
                decoration: const InputDecoration(
                  labelText: 'Date of Birth (YYYY-MM-DD)',
                ),
              ),
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: const InputDecoration(labelText: 'Gender'),
                items: ['male', 'female']
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (v) => setState(() => _gender = v),
              ),
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(labelText: 'Bio'),
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Interests (comma separated IDs)',
                ),
                onSaved: (v) => _interests = v!
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList(),
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Languages (comma separated IDs)',
                ),
                onSaved: (v) => _languages = v!
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList(),
              ),
              DropdownButtonFormField<String>(
                value: _selectedReligionId,
                decoration: const InputDecoration(labelText: 'Religion'),
                items: _religions.map((religion) {
                  return DropdownMenuItem(
                    value: religion['id'],
                    child: Text(religion['name']!),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedReligionId = newValue;
                  });
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Relationship Goals (comma separated IDs)',
                ),
                onSaved: (v) => _relationshipGoals = v!
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList(),
              ),
              TextFormField(
                controller: _heightController,
                decoration: const InputDecoration(labelText: 'Height'),
              ),
              TextFormField(
                controller: _searchPreferencesController,
                decoration: const InputDecoration(
                  labelText: 'Search Preferences',
                ),
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Hobbies (comma separated)',
                ),
                onSaved: (v) => _hobbies = v!
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList(),
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Sports (comma separated)',
                ),
                onSaved: (v) => _sports = v!
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList(),
              ),
              TextFormField(
                controller: _filmController,
                decoration: const InputDecoration(labelText: 'Film'),
              ),
              TextFormField(
                controller: _musicController,
                decoration: const InputDecoration(labelText: 'Music'),
              ),
              TextFormField(
                controller: _travelController,
                decoration: const InputDecoration(labelText: 'Travel'),
              ),
              Row(
                children: [
                  _selectedImage != null
                      ? Image.file(_selectedImage!, width: 80, height: 80)
                      : const Text('No image selected'),
                  TextButton(
                    onPressed: _pickImage,
                    child: const Text('Pick Image'),
                  ),
                ],
              ),
              TextFormField(
                controller: _latitudeController,
                decoration: const InputDecoration(labelText: 'Latitude'),
              ),
              TextFormField(
                controller: _longitudeController,
                decoration: const InputDecoration(labelText: 'Longitude'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _submit, child: const Text('Submit')),
            ],
          ),
        ),
      ),
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

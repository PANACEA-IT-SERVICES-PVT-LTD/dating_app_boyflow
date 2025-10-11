// ignore_for_file: sort_child_properties_last

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../widgets/gradient_button.dart';
import '../../views/screens/registration_status.dart';
import '../../controllers/api_controller.dart'; // <- make sure the path is correct in your project
import '../../api_service/api_endpoint.dart'; // only used for constants in comments

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
  File? _photo; // selected image file (local)
  File? _videoFile; // selected/recorded video (local)
  VideoPlayerController? _videoController;

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _bioController = TextEditingController();

  String _gender = 'Female'; // default to match sample payload

  /// Display labels for interests & a mapping to backend IDs.
  /// Replace with your real lists you fetch from backend, if available.
  final List<String> _allInterestLabels = const [
    'Listening Music',
    'Watching Movies',
    'Cooking',
    'Reading',
    'Gaming',
    'Traveling',
  ];

  /// Map label -> backend id (example shows 2 actual IDs from your sample)
  final Map<String, String> _interestLabelToId = const {
    'Listening Music': '68d4f9dfdd3c0ef9b8ebbf19',
    'Watching Movies': '68d4fac1dd3c0ef9b8ebbf20',
    // Add/replace the rest with your actual IDs from backend
    'Cooking': '68d4fac1dd3c0ef9b8ebbf21',
    'Reading': '68d4fac1dd3c0ef9b8ebbf22',
    'Gaming': '68d4fac1dd3c0ef9b8ebbf23',
    'Traveling': '68d4fac1dd3c0ef9b8ebbf24',
  };

  /// Languages (chips) with id mapping
  final List<String> _allLanguageLabels = const ['English', 'Hindi'];



  final Set<String> _selectedInterestLabels = <String>{};
  final Set<String> _selectedLanguageLabels = <String>{};

  @override
  void initState() {
    super.initState();
    // Prefill example values matching the sample response
    _nameController.text = 'oliva Doe';
    _ageController.text = '30';
    _bioController.text = 'This is my bio';
    _gender = 'Female';

    // Preselect example interests and languages (matching your sample IDs)
    _selectedInterestLabels.addAll(['Listening Music', 'Watching Movies']);
   
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _photo = File(picked.path));
    }
  }



  Future<void> _onApprovePressed() async {
    if (!_formKey.currentState!.validate()) return;

    final api = context.read<ApiController>();

    // Map selections to backend IDs
    final interestIds = _selectedInterestLabels
        .map((label) => _interestLabelToId[label])
        .whereType<String>()
        .toList();
 // TODO: replace with uploaded URL
    final String? photoUrl = _photo?.path; 

    final int age = int.parse(_ageController.text.trim());

    final ok = await api.updateProfileDetails(
      name: _nameController.text.trim(),
      age: age,
      gender: _gender.toLowerCase(),
      bio: _bioController.text.trim(),
      interestIds: interestIds,
      photoUrl: photoUrl,
    );

    if (!mounted) return;

    if (ok) {
      // Navigate to status screen on success
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RegistrationStatusScreen()),
      );
    } else {
      final err = api.error ?? 'Profile update failed';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ApiController>().isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Column(
          children: [
            Text(
              'Introduce yourself',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Please describe yourself',
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
          ],
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

                    // Photo
                    GestureDetector(
                      onTap: _pickImage,
                      child: _photo == null
                          ? const _DottedBorderBox(label: 'Upload photo')
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                _photo!,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Name', style: _labelStyle()),
                    ),
                    const SizedBox(height: 6),
                    _buildRoundedTextField(
                      controller: _nameController,
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

                    const SizedBox(height: 20),
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
                        text: isLoading ? 'Saving...' : 'Submit',
                        onPressed: isLoading ? null : _onApprovePressed,
                        buttonText: '',
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            if (isLoading)
              const Positioned.fill(
                child: ColoredBox(
                  color: Color.fromARGB(100, 255, 255, 255),
                  child: Center(child: CircularProgressIndicator()),
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
  final Widget? child;
  final bool isCircle;

  const _DottedBorderBox({
    required this.label,
    this.child,
    this.isCircle = false,
  });

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
        borderRadius: isCircle ? null : BorderRadius.circular(10),
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        color: Colors.transparent,
      ),
      child: Center(
        child:
            child ??
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add_a_photo, color: Color(0xFFE91EC7)),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFFE91EC7),
                    fontSize: 12,
                  ),
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

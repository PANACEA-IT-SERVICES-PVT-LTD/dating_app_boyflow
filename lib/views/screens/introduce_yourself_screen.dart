// ignore_for_file: sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:boy_flow/widgets/common_top_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:provider/provider.dart';
import '../../controllers/api_controller.dart';

import '../../widgets/gradient_button.dart';

// Helper to save token after login
Future<void> saveLoginToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('token', token);
}

class IntroduceYourselfScreen extends StatefulWidget {
  const IntroduceYourselfScreen({super.key});

  @override
  State<IntroduceYourselfScreen> createState() =>
      _IntroduceYourselfScreenState();
}

class _IntroduceYourselfScreenState extends State<IntroduceYourselfScreen> {
  String? _uploadedPhotoUrl;

  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _dobController = TextEditingController();
  final _bioController = TextEditingController();
  final _heightController = TextEditingController();
  final _religionController = TextEditingController();

  // Gender state
  String? _selectedGender;
  final List<String> _genders = ['Male', 'Female', 'Other'];

  // State variables for profile data
  List<Map<String, dynamic>> _images = [];
  bool _isLoading = true;

  // Helper to parse profile data (comma separated or list)
  List<String> _parseProfileList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    if (value is String) {
      return value
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return [];
  }

  // Widget for multi-select chips
  Widget _buildMultiSelectChips({
    required String title,
    required List<String> options,
    required List<String> selectedValues,
    required ValueChanged<List<String>> onSelectionChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (options.isEmpty)
            const Text(
              'No options available',
              style: TextStyle(color: Colors.grey),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: options.map((option) {
                final isSelected = selectedValues.contains(option);
                return ChoiceChip(
                  label: Text(option),
                  selected: isSelected,
                  onSelected: (selected) {
                    final newValues = List<String>.from(selectedValues);
                    if (selected) {
                      if (!newValues.contains(option)) newValues.add(option);
                    } else {
                      newValues.remove(option);
                    }
                    onSelectionChanged(newValues);
                  },
                  selectedColor: const Color(0xFFE91EC7).withOpacity(0.2),
                  backgroundColor: const Color(0xFFF9E6F5),
                  labelStyle: TextStyle(
                    color: isSelected ? const Color(0xFFE91EC7) : Colors.black,
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final messenger = ScaffoldMessenger.of(context);
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      if (!mounted) return;

      setState(() {
        // Store the local file path temporarily
        _uploadedPhotoUrl = picked.path;
        _images.insert(0, {'imageUrl': picked.path});
      });

      try {
        messenger.showSnackBar(
          const SnackBar(content: Text('Image selected. Ready to upload.')),
        );
      } catch (_) {
        // Ignore inactive messenger errors to prevent crash
      }
    }
  }

  // NEW METHOD - Load profile using new API
  Future<void> _loadProfileWithNewAPI() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiController = Provider.of<ApiController>(context, listen: false);
      final data = await apiController.fetchMaleMe();

      if (!mounted) return;

      if (data['success'] == true && data['data'] != null) {
        final userData = data['data'];

        setState(() {
          _firstNameController.text = userData['firstName']?.toString() ?? '';
          _lastNameController.text = userData['lastName']?.toString() ?? '';
          _mobileController.text = userData['mobileNumber']?.toString() ?? '';
          _bioController.text = userData['bio']?.toString() ?? '';
          _heightController.text = userData['height']?.toString() ?? '';
          _religionController.text = userData['religion']?.toString() ?? '';

          // Handle Date of Birth
          if (userData['dateOfBirth'] != null) {
            try {
              final dob = DateTime.parse(userData['dateOfBirth'].toString());
              _dobController.text =
                  "${dob.year}-${dob.month.toString().padLeft(2, '0')}-${dob.day.toString().padLeft(2, '0')}";
            } catch (_) {
              debugPrint('Error parsing DOB: ${userData['dateOfBirth']}');
            }
          }

          // Handle Gender
          final gender = userData['gender']?.toString().toLowerCase();
          if (gender != null) {
            if (gender == 'male')
              _selectedGender = 'Male';
            else if (gender == 'female')
              _selectedGender = 'Female';
            else
              _selectedGender = 'Other';
          }

          // Handle Images
          final images = userData['images'];
          if (images is List && images.isNotEmpty) {
            final firstImage = images.first;
            if (firstImage is Map) {
              // Check for 'imageUrl' or 'url' or 'path'
              final url =
                  firstImage['imageUrl']?.toString() ??
                  firstImage['url']?.toString() ??
                  firstImage['path']?.toString();
              if (url != null && url.isNotEmpty) {
                _images = [
                  {'imageUrl': url},
                ];
              }
            } else if (firstImage is String) {
              _images = [
                {'imageUrl': firstImage},
              ];
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchAvailableOptions() async {
    // API calls removed - will be replaced with new API
    // For now, keeping empty lists
  }

  @override
  void initState() {
    super.initState();
    _loadProfileWithNewAPI(); // CHANGED: Use new API method
    _fetchAvailableOptions();
  }

  // Widget for rounded text fields - moved inside the class
  Widget _buildRoundedTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFF9E6F5),
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CommonTopBar(title: 'Introduce Yourself', showCoin: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),

              GestureDetector(
                onTap: _pickImage,
                child: _images.isNotEmpty && _images[0]['imageUrl'] != null
                    ? CircleAvatar(
                        radius: 60,
                        backgroundImage:
                            () {
                                  String path = _images[0]['imageUrl'];
                                  if (path.startsWith('http')) {
                                    return NetworkImage(path);
                                  } else {
                                    if (path.startsWith('file://')) {
                                      try {
                                        path = Uri.parse(path).toFilePath();
                                      } catch (_) {}
                                    }
                                    return FileImage(File(path));
                                  }
                                }()
                                as ImageProvider,
                      )
                    : const _DottedBorderBox(label: 'Pick Image'),
              ),

              const SizedBox(height: 20),

              _buildRoundedTextField(
                controller: _firstNameController,
                hint: 'First Name',
              ),
              _buildRoundedTextField(
                controller: _lastNameController,
                hint: 'Last Name',
              ),
              _buildRoundedTextField(
                controller: _mobileController,
                hint: 'Mobile Number',
                keyboardType: TextInputType.phone,
              ),

              // Date of Birth with DatePicker
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: TextFormField(
                  controller: _dobController,
                  readOnly: true,
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().subtract(
                        const Duration(days: 365 * 18),
                      ), // Default to 18 years ago
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      // Format: YYYY-MM-DD
                      final formattedDate =
                          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                      setState(() {
                        _dobController.text = formattedDate;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF9E6F5),
                    hintText: 'Date of Birth (YYYY-MM-DD)',
                    suffixIcon: const Icon(
                      Icons.calendar_today,
                      color: Color(0xFFE91EC7),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              _buildRoundedTextField(
                controller: _bioController,
                hint: 'Bio',
                maxLines: 3,
              ),
              _buildRoundedTextField(
                controller: _heightController,
                hint: 'Height (in cm)',
                keyboardType: TextInputType.number,
              ),
              _buildRoundedTextField(
                controller: _religionController,
                hint: 'Religion',
              ),

              // Gender Dropdown
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9E6F5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedGender,
                      hint: const Text('Select Gender'),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedGender = newValue;
                        });
                      },
                      items: _genders.map<DropdownMenuItem<String>>((
                        String value,
                      ) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              GradientButton(
                text: 'Submit',
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      _isLoading = true;
                    });

                    final messenger = ScaffoldMessenger.of(context);

                    try {
                      final apiController = Provider.of<ApiController>(
                        context,
                        listen: false,
                      );

                      final Map<String, dynamic> data = {
                        'firstName': _firstNameController.text.trim(),
                        'lastName': _lastNameController.text.trim(),
                        'mobileNumber': _mobileController.text.trim(),
                        'dateOfBirth': _dobController.text.trim(),
                        'bio': _bioController.text.trim(),
                        'height': _heightController.text.trim(),
                        'religion': _religionController.text.trim(),
                      };

                      // Calculate age from DOB if possible
                      try {
                        if (_dobController.text.isNotEmpty) {
                          final birthDate = DateTime.parse(
                            _dobController.text.trim(),
                          );
                          final today = DateTime.now();
                          int age = today.year - birthDate.year;
                          if (today.month < birthDate.month ||
                              (today.month == birthDate.month &&
                                  today.day < birthDate.day)) {
                            age--;
                          }
                          data['age'] = age.toString();
                        }
                      } catch (e) {
                        debugPrint('Error calculating age: $e');
                      }

                      if (_selectedGender != null) {
                        data['gender'] = _selectedGender!.toLowerCase();
                      } else {
                        if (data['gender'] == null) {
                          data['gender'] = 'male';
                        }
                      }

                      // 1. Update text profile details via the new PATCH endpoint
                      await apiController.updateProfileDetails(data: data);

                      // 2. If there is a new image, use the upload method
                      if (_images.isNotEmpty &&
                          _images[0]['imageUrl'] != null) {
                        String path = _images[0]['imageUrl'];
                        if (!path.startsWith('http')) {
                          if (path.startsWith('file://')) {
                            try {
                              path = Uri.parse(path).toFilePath();
                            } catch (_) {}
                          }
                          final imageFile = File(path);

                          // Convert data to Map<String, String> for the multipart request
                          final Map<String, String> fields = data.map(
                            (k, v) => MapEntry(k, v.toString()),
                          );

                          await apiController.updateProfileAndImage(
                            fields: fields,
                            imageFile: imageFile,
                          );
                        }
                      }

                      if (!mounted) return;

                      try {
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Profile updated successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (_) {}

                      // Wait for the snackbar to be visible before navigating back
                      await Future.delayed(const Duration(seconds: 2));
                      if (mounted) {
                        Navigator.pop(context, true);
                      }
                    } catch (e) {
                      debugPrint('Error updating profile: $e');
                      if (!mounted) return;
                      try {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } catch (_) {}
                    } finally {
                      if (mounted) {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    }
                  }
                },
                buttonText: '',
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
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
        border: Border.all(color: const Color(0xFFE91EC7)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_a_photo, color: Color(0xFFE91EC7)),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(color: Color(0xFFE91EC7))),
          ],
        ),
      ),
    );
  }
}

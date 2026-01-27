// ignore_for_file: sort_child_properties_last

import 'dart:io' show File;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../widgets/gradient_button.dart';
import '../../controllers/api_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../models/profile_model.dart';

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
  List<String> _availableSports = [];
  List<String> _availableFilm = [];
  List<String> _availableMusic = [];
  List<String> _availableTravel = [];
  String? _uploadedPhotoUrl;

  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _heightController = TextEditingController();

  // 🔹 ADDED (missing from UI image)
  final _mobileController = TextEditingController();
  final _dobController = TextEditingController();
  final _bioController = TextEditingController();
  final _interestsController = TextEditingController();
  final _languagesController = TextEditingController();
  final _relationshipGoalsController = TextEditingController();
  final _searchPreferencesController = TextEditingController();
  final _hobbiesController = TextEditingController();
  final _sportsController = TextEditingController();
  final _filmController = TextEditingController();
  final _musicController = TextEditingController();
  final _travelController = TextEditingController();

  // Multi-select state
  List<String> _selectedSports = [];
  List<String> _selectedFilm = [];
  List<String> _selectedMusic = [];
  List<String> _selectedTravel = [];
  String? _selectedReligionId;
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  // State variables for profile data
  List<Map<String, dynamic>> _images = [];
  bool _isLoading = true;

  final List<Map<String, String>> _religions = [
    {'id': '694f63d08389fc82a4345083', 'name': 'Hindu'},
    {'id': '694f63d08389fc82a4345084', 'name': 'Muslim'},
    {'id': '694f63d08389fc82a4345085', 'name': 'Christian'},
    {'id': '694f63d08389fc82a4345086', 'name': 'Sikh'},
    {'id': '694f63d08389fc82a4345087', 'name': 'Buddhist'},
    {'id': '694f63d08389fc82a4345088', 'name': 'Jewish'},
    {'id': '694f63d08389fc82a4345089', 'name': 'Other'},
  ];

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
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final apiController = Provider.of<ApiController>(
        context,
        listen: false,
      ); // Use existing controller for image upload
      try {
        final result = await apiController.uploadUserImage(
          imageFile: File(picked.path),
        );
        print('DEBUG: image upload result: $result');
        if (result['success'] == true &&
            result['urls'] != null &&
            result['urls'] is List &&
            result['urls'].isNotEmpty) {
          setState(() {
            _uploadedPhotoUrl = result['urls'][0];
            // Optionally update _images if you want to show all images
            _images.insert(0, {'imageUrl': _uploadedPhotoUrl});
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Image uploaded successfully.'),
          ),
        );
      } catch (e) {
        print('DEBUG: Error uploading image: $e');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to upload image: $e')));
      }
    }
  }

  // NEW METHOD - Load profile using new API
  Future<void> _loadProfileWithNewAPI() async {
    try {
      // Using the new ProfileController to fetch profile data
      final profileController = Provider.of<ProfileController>(
        context,
        listen: false,
      );
      await profileController.fetchProfile();

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        if (profileController.profileData != null) {
          final profile = profileController.profileData!;
          _firstNameController.text = profile.firstName;
          _lastNameController.text = profile.lastName;
          // Note: gender and dateOfBirth are displayed but not editable in this form
          _dobController.text = profile.dateOfBirth;

          // Set the profile image if available
          if (profile.profileImageUrl != null) {
            _images = [
              {'imageUrl': profile.profileImageUrl},
            ];
          }
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load profile: $e')));
    }
  }

  Future<void> _fetchAvailableOptions() async {
    final apiController = Provider.of<ApiController>(
      context,
      listen: false,
    ); // Use existing controller for other APIs
    try {
      final sports = await apiController.fetchAllSports();
      print('DEBUG: sports response: $sports');
      final film = await apiController.fetchAllFilm();
      print('DEBUG: film response: $film');
      final music = await apiController.fetchAllMusic();
      print('DEBUG: music response: $music');
      final travel = await apiController.fetchAllTravel();
      print('DEBUG: travel response: $travel');
      if (!mounted) return;
      setState(() {
        _availableSports = sports;
        _availableFilm = film;
        _availableMusic = music;
        _availableTravel = travel;
      });
    } catch (e) {
      print('DEBUG: Error fetching options: $e');
    }
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
      appBar: AppBar(
        title: const Text('Introduce Yourself'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF00CC), Color(0xFF9A00F0)],
            ),
          ),
        ),
      ),
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
                        backgroundImage: NetworkImage(_images[0]['imageUrl']),
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
              _buildRoundedTextField(
                controller: _dobController,
                hint: 'Date of Birth (YYYY-MM-DD)',
              ),
              _buildRoundedTextField(
                controller: _bioController,
                hint: 'Bio',
                maxLines: 3,
              ),
              _buildRoundedTextField(
                controller: _interestsController,
                hint: 'Interests (comma separated IDs)',
              ),
              _buildRoundedTextField(
                controller: _languagesController,
                hint: 'Languages (comma separated IDs)',
              ),
              _buildRoundedTextField(
                controller: _relationshipGoalsController,
                hint: 'Relationship Goals (comma separated IDs)',
              ),
              _buildRoundedTextField(
                controller: _heightController,
                hint: 'Height',
                keyboardType: TextInputType.number,
              ),
              _buildRoundedTextField(
                controller: _searchPreferencesController,
                hint: 'Search Preferences',
              ),
              _buildRoundedTextField(
                controller: _hobbiesController,
                hint: 'Hobbies (comma separated)',
              ),
              // Religion Selection Dropdown
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Religion',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9E6F5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        underline: Container(),
                        value: _selectedReligionId,
                        hint: const Text('Select Religion'),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedReligionId = newValue;
                          });
                        },
                        items: _religions.map<DropdownMenuItem<String>>((
                          religion,
                        ) {
                          return DropdownMenuItem<String>(
                            value: religion['id'],
                            child: Text(religion['name']!),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              _buildMultiSelectChips(
                title: 'Sports',
                options: _availableSports,
                selectedValues: _selectedSports,
                onSelectionChanged: (values) {
                  setState(() {
                    _selectedSports = values;
                    _sportsController.text = values.join(',');
                  });
                },
              ),
              _buildMultiSelectChips(
                title: 'Film',
                options: _availableFilm,
                selectedValues: _selectedFilm,
                onSelectionChanged: (values) {
                  setState(() {
                    _selectedFilm = values;
                    _filmController.text = values.join(',');
                  });
                },
              ),
              _buildMultiSelectChips(
                title: 'Music',
                options: _availableMusic,
                selectedValues: _selectedMusic,
                onSelectionChanged: (values) {
                  setState(() {
                    _selectedMusic = values;
                    _musicController.text = values.join(',');
                  });
                },
              ),
              _buildMultiSelectChips(
                title: 'Travel',
                options: _availableTravel,
                selectedValues: _selectedTravel,
                onSelectionChanged: (values) {
                  setState(() {
                    _selectedTravel = values;
                    _travelController.text = values.join(',');
                  });
                },
              ),

              _buildRoundedTextField(
                controller: _latitudeController,
                hint: 'Latitude',
                keyboardType: TextInputType.number,
              ),
              _buildRoundedTextField(
                controller: _longitudeController,
                hint: 'Longitude',
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 30),

              GradientButton(
                text: 'Submit',
                onPressed: () async {
                  final apiController = Provider.of<ApiController>(
                    context,
                    listen: false,
                  );
                  // Parse sports from controller (comma separated to List<String>)
                  final sportsText = _sportsController.text.trim();
                  final sportsList = sportsText.isNotEmpty
                      ? sportsText
                            .split(',')
                            .map((e) => e.trim())
                            .where((e) => e.isNotEmpty)
                            .toList()
                      : <String>[];
                  // Parse film from controller (comma separated to List<String>)
                  final filmText = _filmController.text.trim();
                  final filmList = filmText.isNotEmpty
                      ? filmText
                            .split(',')
                            .map((e) => e.trim())
                            .where((e) => e.isNotEmpty)
                            .toList()
                      : <String>[];
                  // Parse music from controller (comma separated to List<String>)
                  final musicText = _musicController.text.trim();
                  final musicList = musicText.isNotEmpty
                      ? musicText
                            .split(',')
                            .map((e) => e.trim())
                            .where((e) => e.isNotEmpty)
                            .toList()
                      : <String>[];
                  // Parse travel from controller (comma separated to List<String>)
                  final travelText = _travelController.text.trim();
                  final travelList = travelText.isNotEmpty
                      ? travelText
                            .split(',')
                            .map((e) => e.trim())
                            .where((e) => e.isNotEmpty)
                            .toList()
                      : <String>[];

                  try {
                    final sportsResult = await apiController.updateUserSports(
                      sports: sportsList,
                    );
                    final filmResult = await apiController.updateUserFilm(
                      film: filmList,
                    );
                    final musicResult = await apiController.updateUserMusic(
                      music: musicList,
                    );
                    final travelResult = await apiController.updateUserTravel(
                      travel: travelList,
                    );
                    // Update religion if selected
                    dynamic religionResult;
                    if (_selectedReligionId != null) {
                      religionResult = await apiController.updateProfileDetails(
                        religion: _selectedReligionId!,
                      );
                    }
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${sportsResult['message'] ?? 'Sports updated successfully'}\n'
                          '${filmResult['message'] ?? 'Film preferences updated successfully'}\n'
                          '${musicResult['message'] ?? 'Music preferences updated successfully'}\n'
                          '${travelResult['message'] ?? 'Travel preferences updated successfully'}\n'
                          '${religionResult != null ? (religionResult['message'] ?? 'Religion updated successfully') : 'No religion changes'}',
                        ),
                      ),
                    );
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update: $e')),
                    );
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

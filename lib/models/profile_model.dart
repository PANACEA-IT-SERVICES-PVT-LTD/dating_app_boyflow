class ProfileModel {
  final String firstName;
  final String lastName;
  final String gender;
  final String dateOfBirth;
  final String? profileImageUrl;

  ProfileModel({
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.dateOfBirth,
    this.profileImageUrl,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    // Extract profile data from the nested structure
    final data = json['data'] ?? json;

    String? profileImageUrl;
    if (data['images'] != null &&
        data['images'] is List &&
        data['images'].isNotEmpty) {
      final firstImage = data['images'][0];
      if (firstImage is Map<String, dynamic>) {
        profileImageUrl = firstImage['imageUrl'];
      } else if (firstImage is String) {
        profileImageUrl = firstImage;
      }
    }

    return ProfileModel(
      firstName: data['firstName']?.toString() ?? '',
      lastName: data['lastName']?.toString() ?? '',
      gender: data['gender']?.toString() ?? '',
      dateOfBirth: data['dateOfBirth']?.toString() ?? '',
      profileImageUrl: profileImageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'profileImageUrl': profileImageUrl,
    };
  }
}

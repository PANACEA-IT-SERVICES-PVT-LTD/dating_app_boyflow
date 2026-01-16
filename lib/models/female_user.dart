class FemaleUser {
  final String id;
  final String name;
  final int age;
  final String bio;
  final String? avatarUrl;

  FemaleUser({
    required this.id,
    required this.name,
    required this.age,
    required this.bio,
    this.avatarUrl,
  });

  factory FemaleUser.fromJson(Map<String, dynamic> json) {
<<<<<<< HEAD
    String? avatarUrl;

    // Try to get avatar from avatarUrl field first
    if (json['avatarUrl'] != null) {
      avatarUrl = json['avatarUrl'].toString();
    } else if (json['images'] != null &&
        json['images'] is List &&
        json['images'].isNotEmpty) {
      // Get avatar from first image in images array
      final firstImage = json['images'][0];
      if (firstImage is Map && firstImage['imageUrl'] != null) {
        avatarUrl = firstImage['imageUrl'].toString();
      }
=======
    String? imageUrl;

    // Handle the image structure from the API response
    if (json['images'] != null &&
        json['images'] is List &&
        json['images'].isNotEmpty) {
      final imageList = json['images'] as List;
      final firstImage = imageList[0];
      if (firstImage is Map<String, dynamic> &&
          firstImage['imageUrl'] != null) {
        imageUrl = firstImage['imageUrl'].toString();
      }
    } else if (json['avatarUrl'] != null) {
      imageUrl = json['avatarUrl'].toString();
>>>>>>> d7c53f9d8b8d3e58746e504614b209626b4667de
    }

    return FemaleUser(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'No Name',
<<<<<<< HEAD
      age: json['age']?.toInt() ?? 0,
      bio: json['bio']?.toString() ?? '',
      avatarUrl: avatarUrl,
=======
      age: json['age'] is int
          ? json['age']
          : (json['age']?.toString() != null
                ? int.tryParse(json['age'].toString()) ?? 0
                : 0),
      bio: json['bio']?.toString() ?? '',
      avatarUrl: imageUrl,
>>>>>>> d7c53f9d8b8d3e58746e504614b209626b4667de
    );
  }
}

class FemaleUserResponse {
  final bool success;
  final int page;
  final int limit;
  final int total;
  final List<FemaleUser> users;

  FemaleUserResponse({
    required this.success,
    required this.page,
    required this.limit,
    required this.total,
    required this.users,
  });

  factory FemaleUserResponse.fromJson(Map<String, dynamic> json) {
    return FemaleUserResponse(
      success: json['success'] ?? false,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      total: json['total'] ?? 0,
      users: (json['data'] as List)
          .map((user) => FemaleUser.fromJson(user))
          .toList(),
    );
  }

  void operator [](String other) {}
}

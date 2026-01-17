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
    String? avatarUrl;
    // Prefer images[0].imageUrl, fallback to avatarUrl
    if (json['images'] != null &&
        json['images'] is List &&
        (json['images'] as List).isNotEmpty) {
      final imageList = json['images'] as List;
      final firstImage = imageList[0];
      if (firstImage is Map<String, dynamic> &&
          firstImage['imageUrl'] != null) {
        avatarUrl = firstImage['imageUrl'].toString();
      }
    } else if (json['avatarUrl'] != null) {
      avatarUrl = json['avatarUrl'].toString();
    }
    return FemaleUser(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'No Name',
      age: json['age'] is int
          ? json['age']
          : (json['age']?.toString() != null
                ? int.tryParse(json['age'].toString()) ?? 0
                : 0),
      bio: json['bio']?.toString() ?? '',
      avatarUrl: avatarUrl,
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
      users: (json['data'] is List)
          ? (json['data'] as List)
                .map((user) => FemaleUser.fromJson(user))
                .toList()
          : [],
    );
  }
}

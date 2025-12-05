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
    return FemaleUser(
      id: json['_id'],
      name: json['name'] ?? 'No Name',
      age: json['age'] ?? 0,
      bio: json['bio'] ?? '',
      avatarUrl: json['avatarUrl'],
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

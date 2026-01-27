class Gift {
  final String id;
  final int coin;
  final String imageUrl;
  final String status;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Gift({
    required this.id,
    required this.coin,
    required this.imageUrl,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Gift.fromJson(Map<String, dynamic> json) {
    return Gift(
      id: json['_id'] as String,
      coin: json['coin'] as int,
      imageUrl: json['imageUrl'] as String,
      status: json['status'] as String,
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'coin': coin,
      'imageUrl': imageUrl,
      'status': status,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

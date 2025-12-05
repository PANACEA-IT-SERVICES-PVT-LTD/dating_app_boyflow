class Profiledetails {
  final String? id;
  final String? email;
  final String? mobileNumber;
  final List<String> interests;
  final List<String> languages;
  final String? status;
  final String? reviewStatus;
  final bool? isVerified;
  final List<dynamic> favourites;
  final String? kycStatus;
  final List<dynamic> followers;
  final List<dynamic> femalefollowing;
  final List<dynamic> earnings;
  final List<dynamic> blockList;
  final bool? beautyFilter;
  final bool? hideAge;
  final bool? onlineStatus;
  final int? walletBalance;
  final int? coinBalance;
  final String? referralCode;
  final bool? referralBonusAwarded;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;
  final int? age;
  final String? bio;
  final String? gender;
  final String? name;
  final String? videoUrl;
  final List<dynamic> images;

  const Profiledetails({
    this.id,
    this.email,
    this.mobileNumber,
    this.interests = const [],
    this.languages = const [],
    this.status,
    this.reviewStatus,
    this.isVerified,
    this.favourites = const [],
    this.kycStatus,
    this.followers = const [],
    this.femalefollowing = const [],
    this.earnings = const [],
    this.blockList = const [],
    this.beautyFilter,
    this.hideAge,
    this.onlineStatus,
    this.walletBalance,
    this.coinBalance,
    this.referralCode,
    this.referralBonusAwarded,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.age,
    this.bio,
    this.gender,
    this.name,
    this.videoUrl,
    this.images = const [],
  });

  factory Profiledetails.fromJson(Map<String, dynamic> json) {
    return Profiledetails(
      id: (json["_id"] ?? json["id"])?.toString(),
      email: json["email"]?.toString(),
      mobileNumber: json["mobileNumber"]?.toString(),
      interests: (json["interests"] is List)
          ? List<String>.from(
              (json["interests"] as List).map((e) => e.toString()),
            )
          : const [],
      languages: (json["languages"] is List)
          ? List<String>.from(
              (json["languages"] as List).map((e) => e.toString()),
            )
          : const [],
      status: json["status"]?.toString(),
      reviewStatus: json["reviewStatus"]?.toString(),
      isVerified: json["isVerified"] is bool
          ? json["isVerified"] as bool
          : null,
      favourites: (json["favourites"] is List)
          ? List<dynamic>.from(json["favourites"])
          : const [],
      kycStatus: json["kycStatus"]?.toString(),
      followers: (json["followers"] is List)
          ? List<dynamic>.from(json["followers"])
          : const [],
      femalefollowing: (json["femalefollowing"] is List)
          ? List<dynamic>.from(json["femalefollowing"])
          : const [],
      earnings: (json["earnings"] is List)
          ? List<dynamic>.from(json["earnings"])
          : const [],
      blockList: (json["blockList"] is List)
          ? List<dynamic>.from(json["blockList"])
          : const [],
      beautyFilter: json["beautyFilter"] is bool
          ? json["beautyFilter"] as bool
          : null,
      hideAge: json["hideAge"] is bool ? json["hideAge"] as bool : null,
      onlineStatus: json["onlineStatus"] is bool
          ? json["onlineStatus"] as bool
          : null,
      walletBalance: json["walletBalance"] is int
          ? json["walletBalance"] as int
          : _tryParseInt(json["walletBalance"]),
      coinBalance: json["coinBalance"] is int
          ? json["coinBalance"] as int
          : _tryParseInt(json["coinBalance"]),
      referralCode: json["referralCode"]?.toString(),
      referralBonusAwarded: json["referralBonusAwarded"] is bool
          ? json["referralBonusAwarded"] as bool
          : null,
      createdAt: _tryParseDate(json["createdAt"]),
      updatedAt: _tryParseDate(json["updatedAt"]),
      v: json["__v"] is int ? json["__v"] as int : _tryParseInt(json["__v"]),
      age: json["age"] is int ? json["age"] as int : _tryParseInt(json["age"]),
      bio: json["bio"]?.toString(),
      gender: json["gender"]?.toString(),
      name: json["name"]?.toString(),
      videoUrl: json["videoUrl"]?.toString(),
      images: (json["images"] is List)
          ? List<dynamic>.from(json["images"])
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "email": email,
      "mobileNumber": mobileNumber,
      "interests": interests,
      "languages": languages,
      "status": status,
      "reviewStatus": reviewStatus,
      "isVerified": isVerified,
      "favourites": favourites,
      "kycStatus": kycStatus,
      "followers": followers,
      "femalefollowing": femalefollowing,
      "earnings": earnings,
      "blockList": blockList,
      "beautyFilter": beautyFilter,
      "hideAge": hideAge,
      "onlineStatus": onlineStatus,
      "walletBalance": walletBalance,
      "coinBalance": coinBalance,
      "referralCode": referralCode,
      "referralBonusAwarded": referralBonusAwarded,
      "createdAt": createdAt?.toIso8601String(),
      "updatedAt": updatedAt?.toIso8601String(),
      "__v": v,
      "age": age,
      "bio": bio,
      "gender": gender,
      "name": name,
      "videoUrl": videoUrl,
      "images": images,
    };
  }

  static DateTime? _tryParseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static int? _tryParseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) {
      final v = int.tryParse(value);
      return v;
    }
    return null;
  }
}

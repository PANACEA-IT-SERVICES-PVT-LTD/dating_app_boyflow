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
  final List<String> hobbies;
  final List<String> sports;
  final List<String> film;
  final List<String> music;
  final List<String> travel;
  final int? balance;
  final bool? isActive;
  final List<dynamic> malefollowing;
  final List<dynamic> malefollowers;
  final bool? profileCompleted;
  final String? referredBy;
  final Map<String, dynamic>? searchPreferences;

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
    this.hobbies = const [],
    this.sports = const [],
    this.film = const [],
    this.music = const [],
    this.travel = const [],
    this.balance,
    this.isActive,
    this.malefollowing = const [],
    this.malefollowers = const [],
    this.profileCompleted,
    this.referredBy,
    this.searchPreferences,
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
      hobbies: (json["hobbies"] is List)
          ? List<String>.from(
              (json["hobbies"] as List).map((e) => e.toString()),
            )
          : const [],
      sports: (json["sports"] is List)
          ? List<String>.from((json["sports"] as List).map((e) => e.toString()))
          : const [],
      film: (json["film"] is List)
          ? List<String>.from((json["film"] as List).map((e) => e.toString()))
          : const [],
      music: (json["music"] is List)
          ? List<String>.from((json["music"] as List).map((e) => e.toString()))
          : const [],
      travel: (json["travel"] is List)
          ? List<String>.from((json["travel"] as List).map((e) => e.toString()))
          : const [],
      balance: json["balance"] is int
          ? json["balance"] as int
          : _tryParseInt(json["balance"]),
      isActive: json["isActive"] is bool ? json["isActive"] as bool : null,
      malefollowing: (json["malefollowing"] is List)
          ? List<dynamic>.from(json["malefollowing"])
          : const [],
      malefollowers: (json["malefollowers"] is List)
          ? List<dynamic>.from(json["malefollowers"])
          : const [],
      profileCompleted: json["profileCompleted"] is bool
          ? json["profileCompleted"] as bool
          : null,
      referredBy:
          (json["referredBy"] is String && json["referredBy"].isNotEmpty)
          ? json["referredBy"]
          : null,
      searchPreferences: json["searchPreferences"] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json["searchPreferences"] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
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
      "age": age,
      "bio": bio,
      "gender": gender,
      "name": name,
      "videoUrl": videoUrl,
      "images": images,
      "hobbies": hobbies,
      "sports": sports,
      "film": film,
      "music": music,
      "travel": travel,
      "balance": balance,
      "isActive": isActive,
      "malefollowing": malefollowing,
      "malefollowers": malefollowers,
      "profileCompleted": profileCompleted,
      "searchPreferences": searchPreferences,
    };

    if (createdAt != null) {
      map["createdAt"] = createdAt!.toIso8601String();
    }
    if (updatedAt != null) {
      map["updatedAt"] = updatedAt!.toIso8601String();
    }
    if (v != null) {
      map["__v"] = v;
    }
    if (referredBy != null && referredBy!.isNotEmpty) {
      map["referredBy"] = referredBy;
    }

    return map;
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

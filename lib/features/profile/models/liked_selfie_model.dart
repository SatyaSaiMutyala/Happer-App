class LikedSelfieUser {
  final String id;
  final String username;
  final String fullname;
  final int role;
  final String? profileImage;

  const LikedSelfieUser({
    required this.id,
    required this.username,
    required this.fullname,
    required this.role,
    this.profileImage,
  });

  String get displayName => username.isNotEmpty ? username : fullname;
  bool get hasPicture => profileImage != null && profileImage!.isNotEmpty;

  factory LikedSelfieUser.fromJson(Map<String, dynamic> json) {
    return LikedSelfieUser(
      id: json['_id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      fullname: json['fullname'] as String? ?? '',
      role: (json['role'] as num?)?.toInt() ?? 0,
      profileImage: json['profileImage'] as String?,
    );
  }
}

class LikedSelfieModel {
  final String id;
  final String userId;
  final List<String> images;
  final String status;
  final String createdAt;
  final LikedSelfieUser? user;
  final int likesCount;
  final bool isLikedByMe;

  const LikedSelfieModel({
    required this.id,
    required this.userId,
    required this.images,
    required this.status,
    required this.createdAt,
    this.user,
    required this.likesCount,
    required this.isLikedByMe,
  });

  String get primaryImage => images.isNotEmpty ? images.first : '';
  bool get hasImage => images.isNotEmpty;

  LikedSelfieModel copyWith({bool? isLikedByMe, int? likesCount}) {
    return LikedSelfieModel(
      id: id,
      userId: userId,
      images: images,
      status: status,
      createdAt: createdAt,
      user: user,
      likesCount: likesCount ?? this.likesCount,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
    );
  }

  factory LikedSelfieModel.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'];
    final imageList = rawImages is List
        ? rawImages.map((e) => e.toString()).toList()
        : <String>[];
    final rawUser = json['user'];
    return LikedSelfieModel(
      id: json['_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      images: imageList,
      status: json['status'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      user: rawUser is Map<String, dynamic>
          ? LikedSelfieUser.fromJson(rawUser)
          : null,
      likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
      isLikedByMe: json['is_liked_by_me'] as bool? ?? false,
    );
  }
}

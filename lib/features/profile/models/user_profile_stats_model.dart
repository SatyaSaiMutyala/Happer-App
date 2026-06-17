class UserProfileStatsModel {
  final String id;
  final String username;
  final String fullname;
  final String email;
  final bool isEmailVerified;
  final int status;
  final int role;
  final bool isOwnAccount;
  final bool isFollowing;
  final int followersCount;
  final int followingCount;
  final int selfiesCount;
  final String? picture;
  final String? bio;
  final String? instagramLink;
  final int? usersType;

  const UserProfileStatsModel({
    required this.id,
    required this.username,
    required this.fullname,
    required this.email,
    required this.isEmailVerified,
    required this.status,
    required this.role,
    required this.isOwnAccount,
    required this.isFollowing,
    required this.followersCount,
    required this.followingCount,
    required this.selfiesCount,
    this.picture,
    this.bio,
    this.instagramLink,
    this.usersType,
  });

  String get firstName {
    final parts = fullname.trim().split(RegExp(r'\s+'));
    return parts.isNotEmpty ? parts.first : '';
  }

  String get lastName {
    final parts = fullname.trim().split(RegExp(r'\s+'));
    return parts.length > 1 ? parts.sublist(1).join(' ') : '';
  }

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final l = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return (f + l).isNotEmpty ? (f + l) : '?';
  }

  bool get hasPicture => picture != null && picture!.trim().isNotEmpty;

  factory UserProfileStatsModel.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? json;
    return UserProfileStatsModel(
      id: data['_id'] as String? ?? '',
      username: data['username'] as String? ?? '',
      fullname: (data['full_name'] ?? data['fullname']) as String? ?? '',
      email: data['email'] as String? ?? '',
      isEmailVerified: data['is_email_verified'] == true || data['isEmailVerified'] == true,
      status: (data['status'] as num?)?.toInt() ?? 0,
      role: (data['role'] as num?)?.toInt() ?? 0,
      isOwnAccount: data['is_own_account'] == true,
      isFollowing: data['is_following'] == true,
      followersCount: (data['followers_count'] as num?)?.toInt() ?? 0,
      followingCount: (data['following_count'] as num?)?.toInt() ?? 0,
      selfiesCount: (data['selfies_count'] as num?)?.toInt() ?? 0,
      picture: (data['profile_image'] ?? data['profileImage'] ?? data['picture']) as String?,
      bio: data['bio'] as String?,
      instagramLink: data['instagram_link'] as String?,
      usersType: (data['users_type'] ?? data['role']) is num
          ? ((data['users_type'] ?? data['role']) as num).toInt()
          : null,
    );
  }

  UserProfileStatsModel copyWith({
    bool? isFollowing,
    int? followersCount,
  }) {
    return UserProfileStatsModel(
      id: id,
      username: username,
      fullname: fullname,
      email: email,
      isEmailVerified: isEmailVerified,
      status: status,
      role: role,
      isOwnAccount: isOwnAccount,
      isFollowing: isFollowing ?? this.isFollowing,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount,
      selfiesCount: selfiesCount,
      picture: picture,
      bio: bio,
      instagramLink: instagramLink,
      usersType: usersType,
    );
  }
}

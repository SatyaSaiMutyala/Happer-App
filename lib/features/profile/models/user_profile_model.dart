class UserProfileModel {
  final String id;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String? picture;
  final String? phone;
  final String? countryCode;
  final String? address;
  final String? streetAddress;
  final String? postalCode;
  final String? city;
  final int role;
  final bool isEsignCompleted;
  final String? createdAt;
  final String? dob;
  final int? gender;
  final String? bio;
  final String? instagramLink;

  const UserProfileModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    this.picture,
    this.phone,
    this.countryCode,
    this.address,
    this.streetAddress,
    this.postalCode,
    this.city,
    this.role = 0,
    this.isEsignCompleted = false,
    this.createdAt,
    this.dob,
    this.gender,
    this.bio,
    this.instagramLink,
  });

  String get fullName => '$firstName $lastName'.trim();

  String get initials {
    final a = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final b = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    final combined = '$a$b';
    return combined.isNotEmpty ? combined : '?';
  }

  bool get hasPicture => picture != null && picture!.trim().isNotEmpty;

  String? get fullPhone {
    final p = phone?.trim();
    if (p == null || p.isEmpty) return null;
    final cc = countryCode?.trim();
    if (cc != null && cc.isNotEmpty) return '$cc $p';
    return p;
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? json;
    final firstName = data['first_name'] as String? ?? '';
    final lastName = data['last_name'] as String? ?? '';
    return UserProfileModel(
      id: data['_id'] as String? ?? '',
      firstName: firstName,
      lastName: lastName,
      username: data['username'] as String? ?? '',
      email: data['email'] as String? ?? '',
      picture: (data['profile_image'] ?? data['profileImage'] ?? data['picture']) as String?,
      phone: (data['mobile_number'] ?? data['phone']) as String?,
      countryCode: data['country_code'] as String?,
      role: data['role'] as int? ?? 0,
      isEsignCompleted: data['is_esign_completed'] as bool? ?? false,
      address: data['address'] as String?,
      streetAddress: data['address'] as String?,
      postalCode: data['postalcode'] as String?,
      city: data['city'] as String?,
      createdAt: data['created_at'] as String?,
      dob: data['dob'] as String?,
      gender: data['gender'] as int?,
      bio: data['bio'] as String?,
      instagramLink: data['instagram_link'] as String?,
    );
  }
}

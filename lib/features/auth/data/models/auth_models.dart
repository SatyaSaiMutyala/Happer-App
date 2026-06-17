class SignupRequest {
  final String email;
  final String firstName;
  final String lastName;
  final String username;
  final String password;
  final String? referredByCode;

  SignupRequest({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.password,
    this.referredByCode,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'username': username,
      'password': password,
    };
    if (referredByCode != null && referredByCode!.isNotEmpty) {
      map['referred_by_code'] = referredByCode;
    }
    return map;
  }
}

class UserModel {
  final String id;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final bool isEmailVerified;
  final String? referralCode;
  final String? referredByCode;
  final String? accessToken;
  final String? refreshToken;

  UserModel({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.isEmailVerified,
    this.referralCode,
    this.referredByCode,
    this.accessToken,
    this.refreshToken,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      firstName: json['first_name'] as String? ?? json['fullname'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      isEmailVerified: json['is_email_verified'] as bool? ?? json['isEmailVerified'] as bool? ?? false,
      referralCode: json['referral_code'] as String? ?? json['referralCode'] as String?,
      referredByCode: json['referred_by_code'] as String? ?? json['referredByCode'] as String?,
      accessToken: json['access_token'] as String?,
      refreshToken: json['refresh_token'] as String?,
    );
  }
}

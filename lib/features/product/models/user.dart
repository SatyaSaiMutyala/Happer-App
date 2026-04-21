class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final int credits;
  final String? picture;
  final bool emailVerified;
  final String? sponsorshipCode;
  final int nbSponsorship;
  final String? subscriptionType;
  
  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.credits,
    this.picture,
    required this.emailVerified,
    this.sponsorshipCode,
    required this.nbSponsorship,
    this.subscriptionType,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      credits: json['credits'] ?? 0,
      picture: json['picture'],
      emailVerified: json['email_verified'] ?? false,
      sponsorshipCode: json['sponsorship_code'],
      nbSponsorship: json['nb_sponsorship'] ?? 0,
      subscriptionType: json['subscription_type'],
    );
  }
}
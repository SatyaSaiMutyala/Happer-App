// lib/models/product.dart
class Product {
  final String id;
  final String title;
  final String? description;
  final double price;
  final String? imageUrl;
  final String state;
  
  Product({
    required this.id,
    required this.title,
    this.description,
    required this.price,
    this.imageUrl,
    required this.state,
  });
  
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] != null ? json['description']['en'] : null,
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['pictures'] != null && json['pictures'].isNotEmpty
          ? json['pictures'][0]
          : null,
      state: json['state'] ?? '',
    );
  }
}



// lib/models/user.dart
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
class AddressModel {
  final String id;
  final String userId;
  final String addressLabel;
  final String firstName;
  final String lastName;
  final String streetAddress;
  final String postalCode;
  final String city;
  final String email;
  final String mobileNumber;
  final bool isDefault;
  final String? createdAt;

  const AddressModel({
    required this.id,
    required this.userId,
    required this.addressLabel,
    required this.firstName,
    required this.lastName,
    required this.streetAddress,
    required this.postalCode,
    required this.city,
    required this.email,
    required this.mobileNumber,
    this.isDefault = false,
    this.createdAt,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      addressLabel: json['address_label'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      streetAddress: json['street_address'] as String? ?? '',
      postalCode: json['postal_code'] as String? ?? '',
      city: json['city'] as String? ?? '',
      email: json['email'] as String? ?? '',
      mobileNumber: json['mobile_number'] as String? ?? '',
      isDefault: json['is_default'] as bool? ?? false,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'address_label': addressLabel,
        'first_name': firstName,
        'last_name': lastName,
        'street_address': streetAddress,
        'postal_code': postalCode,
        'city': city,
        'email': email,
        'mobile_number': mobileNumber,
      };
}

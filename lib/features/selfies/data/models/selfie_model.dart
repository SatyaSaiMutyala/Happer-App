class SelfieModel {
  final String id;
  final List<String> images;
  final String? state;
  final String? createdAt;
  final int nbLike;
  final bool isLikedByMe;
  final SelfieUser? user;
  final List<SelfieItem> items;

  SelfieModel({
    required this.id,
    required this.images,
    this.state,
    this.createdAt,
    this.nbLike = 0,
    this.isLikedByMe = false,
    this.user,
    this.items = const [],
  });

  factory SelfieModel.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'] ?? json['picture'];
    List<String> images = [];
    if (rawImages is List) {
      images = rawImages.map((e) => e.toString()).toList();
    } else if (rawImages is String && rawImages.isNotEmpty) {
      images = [rawImages];
    }

    // user_id can be an embedded object (detail response) or a plain string (list response)
    final rawUser = json['user_id'] ?? json['user'];
    SelfieUser? user;
    if (rawUser is Map<String, dynamic>) {
      user = SelfieUser.fromJson(rawUser);
    }

    return SelfieModel(
      id: json['_id'] as String? ?? '',
      images: images,
      state: json['status'] as String? ?? json['state'] as String?,
      createdAt: json['created_at'] as String?,
      nbLike: (json['likes_count'] as num?)?.toInt() ??
          (json['nb_like'] as num?)?.toInt() ??
          0,
      isLikedByMe: json['is_liked_by_me'] as bool? ??
          json['isLikedByMe'] as bool? ??
          false,
      user: user,
      items: (json['items_id'] as List<dynamic>?)
              ?.map((e) => SelfieItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  SelfieModel copyWith({bool? isLikedByMe, int? nbLike}) {
    return SelfieModel(
      id: id,
      images: images,
      state: state,
      createdAt: createdAt,
      nbLike: nbLike ?? this.nbLike,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      user: user,
      items: items,
    );
  }

  String get primaryImage => images.isNotEmpty ? images.first : '';
}

class SelfieUser {
  final String id;
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? picture;
  final int? usersType;

  SelfieUser({
    required this.id,
    this.username,
    this.firstName,
    this.lastName,
    this.picture,
    this.usersType,
  });

  factory SelfieUser.fromJson(Map<String, dynamic> json) {
    // Detail endpoint returns "fullname", list endpoint returns "first_name"/"last_name"
    String? firstName = json['first_name'] as String?;
    String? lastName = json['last_name'] as String?;
    if (firstName == null && lastName == null) {
      final fullname = (json['fullname'] as String? ?? '').trim();
      if (fullname.isNotEmpty) {
        final parts = fullname.split(' ');
        firstName = parts.first;
        lastName = parts.length > 1 ? parts.sublist(1).join(' ') : null;
      }
    }
    return SelfieUser(
      id: json['_id'] as String? ?? '',
      username: json['username'] as String?,
      firstName: firstName,
      lastName: lastName,
      picture: json['picture'] as String?,
      usersType: (json['users_type'] as num?)?.toInt() ??
          (json['role'] as num?)?.toInt(),
    );
  }

  String get displayName {
    if (firstName != null && lastName != null) return '$firstName $lastName';
    return username ?? '';
  }
}

class SelfieItem {
  final String? id;
  final bool exactMatch;
  final SelfieProduct? product;

  SelfieItem({this.id, this.exactMatch = false, this.product});

  factory SelfieItem.fromJson(Map<String, dynamic> json) {
    return SelfieItem(
      id: json['id'] as String?,
      exactMatch: json['exact_match'] as bool? ?? false,
      product: json['item'] != null
          ? SelfieProduct.fromJson(json['item'] as Map<String, dynamic>)
          : null,
    );
  }
}

class SelfieProduct {
  final String id;
  final String? name;
  final List<String> pictures;
  final int? price;
  final int? promoPercent;
  final String? buyUrl;

  SelfieProduct({
    required this.id,
    this.name,
    this.pictures = const [],
    this.price,
    this.promoPercent,
    this.buyUrl,
  });

  factory SelfieProduct.fromJson(Map<String, dynamic> json) {
    return SelfieProduct(
      id: json['_id'] as String? ?? '',
      name: json['name'] as String?,
      pictures: (json['pictures'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      price: (json['price'] as num?)?.toInt(),
      promoPercent: (json['promo_percent'] as num?)?.toInt(),
      buyUrl: json['buy_url'] as String?,
    );
  }

  String get primaryImage => pictures.isNotEmpty ? pictures.first : '';
}

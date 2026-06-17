class DiscoverModel {
  final String id;
  final String state;
  final String createdAt;
  final List<String> likes;
  final int userType;
  final String? categoryId;
  final UserModel? user;
  final List<ItemIdModel> itemsId;
  final String picture;
  final int nbLike;
  final bool isLikedByMe;

  DiscoverModel({
    required this.id,
    required this.state,
    required this.createdAt,
    required this.likes,
    required this.userType,
    this.categoryId,
    this.user,
    required this.itemsId,
    required this.picture,
    required this.nbLike,
    required this.isLikedByMe,
  });

  factory DiscoverModel.fromJson(Map<String, dynamic> json) {
    return DiscoverModel(
      id: json['_id'] ?? '',
      state: json['state'] ?? '',
      createdAt: json['created_at'] ?? '',
      likes: List<String>.from(json['likes'] ?? []),
      userType: json['users_type'] ?? 0,
      categoryId: json['category'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      itemsId: (json['items_id'] as List?)
          ?.map((item) => ItemIdModel.fromJson(item))
          .toList() ?? [],
      picture: json['picture'] ?? '',
      nbLike: json['nb_like'] ?? 0,
      isLikedByMe: json['isLikedByMe'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'state': state,
      'created_at': createdAt,
      'likes': likes,
      'users_type': userType,
      'category': categoryId,
      'user': user?.toJson(),
      'items_id': itemsId.map((item) => item.toJson()).toList(),
      'picture': picture,
      'nb_like': nbLike,
      'isLikedByMe': isLikedByMe,
    };
  }
}

class UserModel {
  final String id;
  final String picture;
  final int usersType;
  final String lastName;
  final String firstName;
  final String? username;
  final String? instagramLink;
  final bool isFollowedByMe;

  UserModel({
    required this.id,
    required this.picture,
    required this.usersType,
    required this.lastName,
    required this.firstName,
    this.username,
    this.instagramLink,
    required this.isFollowedByMe,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      picture: json['picture'] ?? '',
      usersType: json['users_type'] ?? 0,
      lastName: json['last_name'] ?? '',
      firstName: json['first_name'] ?? '',
      username: json['username'] as String?,
      instagramLink: json['instagram_link'],
      isFollowedByMe: json['isFollowedByMe'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'picture': picture,
      'users_type': usersType,
      'last_name': lastName,
      'first_name': firstName,
      'username': username,
      'instagram_link': instagramLink,
      'isFollowedByMe': isFollowedByMe,
    };
  }
}

class ItemIdModel {
  final bool exactMatch;
  final String? id;
  final ItemModel? item;

  ItemIdModel({
    required this.exactMatch,
    this.id,
    this.item,
  });

  factory ItemIdModel.fromJson(Map<String, dynamic> json) {
    return ItemIdModel(
      exactMatch: json['exact_match'] ?? false,
      id: json['id'],
      item: json['item'] != null ? ItemModel.fromJson(json['item']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exact_match': exactMatch,
      'id': id,
      'item': item?.toJson(),
    };
  }
}

class ItemModel {
  final String? buyUrl;
  final List<String> pictures;
  final int promoPercent;
  final String id;
  final String name;
  final BrandModel? brandId;
  final double price;

  ItemModel({
    this.buyUrl,
    required this.pictures,
    required this.promoPercent,
    required this.id,
    required this.name,
    this.brandId,
    required this.price,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      buyUrl: json['buy_url'],
      pictures: List<String>.from(json['pictures'] ?? []),
      promoPercent: json['promo_percent'] ?? 0,
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      brandId: json['brand_id'] != null ? BrandModel.fromJson(json['brand_id']) : null,
      price: (json['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'buy_url': buyUrl,
      'pictures': pictures,
      'promo_percent': promoPercent,
      '_id': id,
      'name': name,
      'brand_id': brandId?.toJson(),
      'price': price,
    };
  }
}

class BrandModel {
  final String createdAt;
  final String updatedAt;
  final double shippingPrice;
  final String id;
  final String name;
  final String description;

  BrandModel({
    required this.createdAt,
    required this.updatedAt,
    required this.shippingPrice,
    required this.id,
    required this.name,
    required this.description,
  });

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      shippingPrice: (json['shipping_price'] ?? 0).toDouble(),
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt,
      'updated_at': updatedAt,
      'shipping_price': shippingPrice,
      '_id': id,
      'name': name,
      'description': description,
    };
  }
}
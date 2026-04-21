class CreatorModel {
  final String? sId;
  final String? state;
  final String? createdAt;
  final List<String>? likes;
  final int? userType;
  final User? user;
  final List<ItemsId>? itemsId; // Updated type to List<ItemsId>
  final String? picture;
  int? nbLike;
  bool? isLikedByMe;

  CreatorModel({
    this.sId,
    this.state,
    this.createdAt,
    this.likes,
    this.userType,
    this.user,
    this.itemsId,
    this.picture,
    this.nbLike,
    this.isLikedByMe,
  });

  factory CreatorModel.fromJson(Map<String, dynamic> json) {
    try {
      return CreatorModel(
        sId: json['_id'],
        state: json['state'],
        createdAt: json['created_at'],
        likes: (json['likes'] as List<dynamic>?)?.cast<String>(),
        userType: json['users_type'],
        user: json['user'] != null ? User.fromJson(json['user']) : null,
        itemsId: (json['items_id'] as List<dynamic>?)?.map((item) {
          if (item is Map<String, dynamic>) {
            return ItemsId.fromJson(item);
          } else {
            return ItemsId(id: item.toString()); // Handle case where item is a string
          }
        }).toList(), // Parse items_id as List<ItemsId>
        picture: json['picture'],
        nbLike: json['nb_like'],
        isLikedByMe: json['isLikedByMe'],
      );
    } catch (e) {
     
      throw Exception('Invalid CreatorModel data format');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': sId,
      'state': state,
      'created_at': createdAt,
      'likes': likes,
      'users_type': userType,
      'user': user?.toJson(),
      'items_id': itemsId?.map((item) => item.toJson()).toList(),
      'picture': picture,
      'nb_like': nbLike,
      'isLikedByMe': isLikedByMe,
    };
  }

  String? getUserPicture() {
    return user?.picture;
  }

  @override
  String toString() {
    return 'CreatorModel(sId: $sId, state: $state, createdAt: $createdAt, likes: $likes, userType: $userType, user: $user, itemsId: $itemsId, picture: $picture, nbLike: $nbLike, isLikedByMe: $isLikedByMe)';
  }
}

class Category {
  String? sId;
  String? createdAt;
  String? updatedAt;
  Name? name;
  int? iV;
  String? container;
  String? picture;

  Category({
    this.sId,
    this.createdAt,
    this.updatedAt,
    this.name,
    this.iV,
    this.container,
    this.picture,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      sId: json['_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      name: json['name'] != null ? Name.fromJson(json['name']) : null,
      iV: json['__v'],
      container: json['container'],
      picture: json['picture'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': sId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'name': name?.toJson(),
      '__v': iV,
      'container': container,
      'picture': picture,
    };
  }
}

class Name {
  String? fr;
  String? en;

  Name({this.fr, this.en});

  factory Name.fromJson(Map<String, dynamic> json) {
    return Name(
      fr: json['fr'],
      en: json['en'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fr': fr,
      'en': en,
    };
  }
}

class User {
  String? sId;
  bool? emailVerified;
  List<dynamic>? devices;
  String? lastConnection;
  String? connectionInRow;
  String? createdAt;
  String? updatedAt;
  int? ads;
  String? gender;
  String? picture;
  List<dynamic>? notificationHistory;
  dynamic brandId;
  dynamic subscriptionId;
  dynamic subscriptionType;
  dynamic subscriptionFree;
  int? nbSponsorship;
  int? nbLogin;
  NumberOf? numberOf;
  List<dynamic>? usersSponsored;
  bool? authorizeMail;
  int? sponsorSendLimit;
  int? sponsorPerDay;
  int? usersType;
  String? lastName;
  String? firstName;
  String? sponsorshipCode;
  String? email;
  String? password;
  String? userName;
  int? credits;
  dynamic emailVerificationCode;
  int? iV;
  String? refreshToken;
  String? token;
  String? container;
  String? instagramLink;
  String? address;
  dynamic birthdate;
  String? city;
  String? phone;
  String? postalCode;

  User({
    this.sId,
    this.emailVerified,
    this.devices,
    this.lastConnection,
    this.connectionInRow,
    this.createdAt,
    this.updatedAt,
    this.ads,
    this.gender,
    this.picture,
    this.notificationHistory,
    this.brandId,
    this.subscriptionId,
    this.subscriptionType,
    this.subscriptionFree,
    this.nbSponsorship,
    this.nbLogin,
    this.numberOf,
    this.usersSponsored,
    this.authorizeMail,
    this.sponsorSendLimit,
    this.sponsorPerDay,
    this.usersType,
    this.lastName,
    this.firstName,
    this.sponsorshipCode,
    this.email,
    this.password,
    this.userName,
    this.credits,
    this.emailVerificationCode,
    this.iV,
    this.refreshToken,
    this.token,
    this.container,
    this.instagramLink,
    this.address,
    this.birthdate,
    this.city,
    this.phone,
    this.postalCode,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      sId: json['_id'],
      emailVerified: json['email_verified'],
      devices: json['devices'],
      lastConnection: json['last_connection'],
      connectionInRow: json['connection_in_row'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      ads: json['ads'],
      gender: json['gender'],
      picture: json['picture'],
      notificationHistory: json['notification_history'],
      brandId: json['brand_id'],
      subscriptionId: json['subscription_id'],
      subscriptionType: json['subscription_type'],
      subscriptionFree: json['subscription_free'],
      nbSponsorship: json['nb_sponsorship'],
      nbLogin: json['nb_login'],
      numberOf: json['numberOf'] != null ? NumberOf.fromJson(json['numberOf']) : null,
      usersSponsored: json['users_sponsored'],
      authorizeMail: json['authorize_mail'],
      sponsorSendLimit: json['sponsor_send_limit'],
      sponsorPerDay: json['sponsor_per_day'],
      usersType: json['users_type'],
      lastName: json['last_name'],
      firstName: json['first_name'],
      sponsorshipCode: json['sponsorship_code'],
      email: json['email'],
      password: json['password'],
      userName: json['username'],
      credits: json['credits'],
      emailVerificationCode: json['email_verification_code'],
      iV: json['__v'],
      refreshToken: json['refresh_token'],
      token: json['token'],
      container: json['container'],
      instagramLink: json['instagram_link'],
      address: json['address'],
      birthdate: json['birthdate'],
      city: json['city'],
      phone: json['phone'],
      postalCode: json['postal_code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': sId,
      'email_verified': emailVerified,
      'devices': devices,
      'last_connection': lastConnection,
      'connection_in_row': connectionInRow,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'ads': ads,
      'gender': gender,
      'picture': picture,
      'notification_history': notificationHistory,
      'brand_id': brandId,
      'subscription_id': subscriptionId,
      'subscription_type': subscriptionType,
      'subscription_free': subscriptionFree,
      'nb_sponsorship': nbSponsorship,
      'nb_login': nbLogin,
      'numberOf': numberOf?.toJson(),
      'users_sponsored': usersSponsored,
      'authorize_mail': authorizeMail,
      'sponsor_send_limit': sponsorSendLimit,
      'sponsor_per_day': sponsorPerDay,
      'users_type': usersType,
      'last_name': lastName,
      'first_name': firstName,
      'sponsorship_code': sponsorshipCode,
      'email': email,
      'password': password,
      'username': userName,
      'credits': credits,
      'email_verification_code': emailVerificationCode,
      '__v': iV,
      'refresh_token': refreshToken,
      'token': token,
      'container': container,
      'instagram_link': instagramLink,
      'address': address,
      'birthdate': birthdate,
      'city': city,
      'phone': phone,
      'postal_code': postalCode,
    };
  }
}

class NumberOf {
  int? pictureShared;
  int? productShared;

  NumberOf({this.pictureShared, this.productShared});

  factory NumberOf.fromJson(Map<String, dynamic> json) {
    return NumberOf(
      pictureShared: json['pictureShared'],
      productShared: json['productShared'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pictureShared': pictureShared,
      'productShared': productShared,
    };
  }
}

class ItemsId {
  bool? exactMatch;
  String? id;
  Item? item;

  ItemsId({this.exactMatch, this.id, this.item});

  factory ItemsId.fromJson(Map<String, dynamic> json) {
    return ItemsId(
      exactMatch: json['exact_match'],
      id: json['id'],
      item: json['item'] != null ? Item.fromJson(json['item']) : null,
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

class Item {
  String? buyUrl;
  List<String>? pictures;
  int? promoPercent;
  String? sId;
  String? name;
  BrandId? brandId;
  int? price;

  Item({
    this.buyUrl,
    this.pictures,
    this.promoPercent,
    this.sId,
    this.name,
    this.brandId,
    this.price,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      buyUrl: json['buy_url'],
      pictures: json['pictures']?.cast<String>(),
      promoPercent: json['promo_percent'],
      sId: json['_id'],
      name: json['name'],
      brandId: json['brand_id'] != null ? BrandId.fromJson(json['brand_id']) : null,
      price: json['price'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'buy_url': buyUrl,
      'pictures': pictures,
      'promo_percent': promoPercent,
      '_id': sId,
      'name': name,
      'brand_id': brandId?.toJson(),
      'price': price,
    };
  }
}

class BrandId {
  String? createdAt;
  String? updatedAt;
  int? shippingPrice;
  String? sId;
  String? name;
  String? description;
  String? picture;

  BrandId({
    this.createdAt,
    this.updatedAt,
    this.shippingPrice,
    this.sId,
    this.name,
    this.description,
    this.picture,
  });

  factory BrandId.fromJson(Map<String, dynamic> json) {
    return BrandId(
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      shippingPrice: json['shipping_price'],
      sId: json['_id'],
      name: json['name'],
      description: json['description'],
      picture: json['picture'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt,
      'updated_at': updatedAt,
      'shipping_price': shippingPrice,
      '_id': sId,
      'name': name,
      'description': description,
      'picture': picture, 
    };
  }
}

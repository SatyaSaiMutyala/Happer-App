class CartModel {
  int? status;
  Data? data;
  String? message;

  CartModel({this.status, this.data, this.message});

  factory CartModel.fromJson(Map<String, dynamic> json) => CartModel(
        status: json['status'],
        data: json['data'] != null ? Data.fromJson(json['data']) : null,
        message: json['message'],
      );
}

class Data {
  String? status;
  IngAddress? shippingAddress;
  IngAddress? billingAddress;
  double? total;
  String? id;
  UserId? userId;
  List<Item>? items;
  List<dynamic>? itemsRefunded;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  int? totalShippingPrice;

  Data({
    this.status,
    this.shippingAddress,
    this.billingAddress,
    this.total,
    this.id,
    this.userId,
    this.items,
    this.itemsRefunded,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.totalShippingPrice,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        status: json['status'],
        shippingAddress: json['shipping_address'] != null
            ? IngAddress.fromJson(json['shipping_address'])
            : null,
        billingAddress: json['billing_address'] != null
            ? IngAddress.fromJson(json['billing_address'])
            : null,
        total: (json['total'] as num?)?.toDouble(),
        id: json['_id'],
        userId: json['user_id'] != null ? UserId.fromJson(json['user_id']) : null,
        items: json['items'] != null
            ? List<Item>.from(json['items'].map((x) => Item.fromJson(x)))
            : [],
        itemsRefunded: json['items_refunded'] ?? [],
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'])
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.tryParse(json['updated_at'])
            : null,
        v: json['__v'],
        totalShippingPrice: json['total_shipping_price'],
      );
}

class IngAddress {
  String? name;
  String? address;
  String? city;
  String? state;
  String? zip;
  String? country;
  String? phone;

  IngAddress({
    this.name,
    this.address,
    this.city,
    this.state,
    this.zip,
    this.country,
    this.phone,
  });

  factory IngAddress.fromJson(Map<String, dynamic> json) => IngAddress(
        name: json['name'],
        address: json['address'],
        city: json['city'],
        state: json['state'],
        zip: json['zip'],
        country: json['country'],
        phone: json['phone'],
      );
}

class Item {
  bool? isInStock;
  String? id;
  ItemId? itemId;
  String? name;
  double? price;
  int? quantity;
  String? size;
  String? userId;
  dynamic? shippingPrice;

  Item({
    this.isInStock,
    this.id,
    this.itemId,
    this.name,
    this.price,
    this.quantity,
    this.size,
    this.userId,
    this.shippingPrice,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        isInStock: json['is_in_stock'],
        id: json['_id'],
        itemId: json['item_id'] != null ? ItemId.fromJson(json['item_id']) : null,
        name: json['name'],
        price: (json['price'] as num?)?.toDouble(),
        quantity: json['quantity'],
        size: json['size'],
        userId: json['user_id'],
        shippingPrice: json['shipping_price'],
      );
}

class ItemId {
  List<String>? pictures;
  String? id;
  BrandId? brandId;
  String? description;
  String? subtitle;

  ItemId({
    this.pictures,
    this.id,
    this.brandId,
    this.description,
    this.subtitle,
  });

  factory ItemId.fromJson(Map<String, dynamic> json) {
    BrandId? brandId;

    if (json['brand_id'] != null) {
      if (json['brand_id'] is Map<String, dynamic>) {
        brandId = BrandId.fromJson(json['brand_id'] as Map<String, dynamic>);
      } else if (json['brand_id'] is String) {
        // If brand_id is just a string (ID), create a BrandId with just the ID
        brandId = BrandId(id: json['brand_id'] as String);
      }
    }

    return ItemId(
      pictures: json['pictures'] != null
          ? List<String>.from(json['pictures'])
          : [],
      id: json['_id'],
      brandId: brandId,
      description: json['description'],
      subtitle: json['subtitle'],
    );
  }
}

class BrandId {
  String? id;
  String? name;
  String? picture;
  int? shippingPrice;

  BrandId({
    this.id,
    this.name,
    this.picture,
    this.shippingPrice,
  });

  factory BrandId.fromJson(Map<String, dynamic> json) => BrandId(
        id: json['_id'],
        name: json['name'],
        picture: json['picture'],
        shippingPrice: json['shipping_price'],
      );
}

class UserId {
  String? picture;
  int? usersType;
  String? id;
  String? lastName;
  String? firstName;

  UserId({
    this.picture,
    this.usersType,
    this.id,
    this.lastName,
    this.firstName,
  });

  factory UserId.fromJson(Map<String, dynamic> json) => UserId(
        picture: json['picture'],
        usersType: json['users_type'],
        id: json['_id'],
        lastName: json['last_name'],
        firstName: json['first_name'],
      );
}

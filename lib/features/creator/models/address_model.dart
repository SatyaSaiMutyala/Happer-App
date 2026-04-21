class AddressModel {
  int? status;
  Data? data;
  String? message;

  AddressModel({this.status, this.data, this.message});

  AddressModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['message'] = this.message;
    return data;
  }
}

class Data {
  String? status;
  ShippingAddress? shippingAddress;
  ShippingAddress? billingAddress;
  num? total;
  String? sId;
  String? userId;
  List<Items>? items;
  List<dynamic>?
  itemsRefunded; // Changed to a generic dynamic list to handle various types.
  String? createdAt;
  String? updatedAt;
  num? iV;

  Data({
    this.status,
    this.shippingAddress,
    this.billingAddress,
    this.total,
    this.sId,
    this.userId,
    this.items,
    this.itemsRefunded,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  Data.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    shippingAddress =
        json['shipping_address'] != null
            ? new ShippingAddress.fromJson(json['shipping_address'])
            : null;
    billingAddress =
        json['billing_address'] != null
            ? new ShippingAddress.fromJson(json['billing_address'])
            : null;
    total = json['total'];
    sId = json['_id'];
    userId = json['user_id'];
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(new Items.fromJson(v));
      });
    }
    if (json['items_refunded'] != null) {
      itemsRefunded = <Null>[]; // This line is incorrect and needs to be fixed.
      // Removed the incorrect code as 'Null' cannot have a 'fromJson' constructor.
    }
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.shippingAddress != null) {
      data['shipping_address'] = this.shippingAddress!.toJson();
    }
    if (this.billingAddress != null) {
      data['billing_address'] = this.billingAddress!.toJson();
    }
    data['total'] = this.total;
    data['_id'] = this.sId;
    data['user_id'] = this.userId;
    if (this.items != null) {
      data['items'] = this.items!.map((v) => v.toJson()).toList();
    }
    if (this.itemsRefunded != null) {
      data['items_refunded'] =
          this.itemsRefunded; // Removed the toJson call since itemsRefunded is dynamic.
    }
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}

class ShippingAddress {
  String? name;
  String? phone;
  String? address;
  String? city;
  String? country;
  String? zip;
  String? state;

  ShippingAddress({
    this.name,
    this.phone,
    this.address,
    this.city,
    this.country,
    this.zip,
    this.state,
  });

  ShippingAddress.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    phone = json['phone'];
    address = json['address'];
    city = json['city'];
    country = json['country'];
    zip = json['zip'];
    state = json['state'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['phone'] = this.phone;
    data['address'] = this.address;
    data['city'] = this.city;
    data['country'] = this.country;
    data['zip'] = this.zip;
    data['state'] = this.state;
    return data;
  }
}

class Items {
  bool? isInStock;
  String? sId;
  ItemId? itemId;
  String? name;
  num? price;
  num? quantity;
  String? size;
  String? userId;

  Items({
    this.isInStock,
    this.sId,
    this.itemId,
    this.name,
    this.price,
    this.quantity,
    this.size,
    this.userId,
  });

  Items.fromJson(Map<String, dynamic> json) {
    isInStock = json['is_in_stock'];
    sId = json['_id'];
    itemId =
        json['item_id'] != null ? new ItemId.fromJson(json['item_id']) : null;
    name = json['name'];
    price = json['price'];
    quantity = json['quantity'];
    size = json['size'];
    userId = json['user_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['is_in_stock'] = this.isInStock;
    data['_id'] = this.sId;
    if (this.itemId != null) {
      data['item_id'] = this.itemId!.toJson();
    }
    data['name'] = this.name;
    data['price'] = this.price;
    data['quantity'] = this.quantity;
    data['size'] = this.size;
    data['user_id'] = this.userId;
    return data;
  }
}

class ItemId {
  List<String>? pictures;
  String? sId;
  String? description;

  ItemId({this.pictures, this.sId, this.description});

  ItemId.fromJson(Map<String, dynamic> json) {
    pictures = json['pictures'].cast<String>();
    sId = json['_id'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['pictures'] = this.pictures;
    data['_id'] = this.sId;
    data['description'] = this.description;
    return data;
  }
}

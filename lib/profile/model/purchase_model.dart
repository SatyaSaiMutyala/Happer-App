class Purchase {
  final int? status;
  final List<Datum>? data;
  final String? message;

  Purchase({
    this.status,
    this.data,
    this.message,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) => Purchase(
        status: json['status'] is int
            ? json['status']
            : int.tryParse(json['status'].toString()),
        message: json['message'],
        data: json['data'] != null
            ? List<Datum>.from(json['data'].map((x) => Datum.fromJson(x)))
            : null,
      );

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'data': data?.map((x) => x.toJson()).toList(),
      };
}

class Datum {
  final double? total;
  final String? id;
  final List<Item>? items;
  final DateTime? createdAt;
  final DateTime? paidOn;

  Datum({
    this.total,
    this.id,
    this.items,
    this.createdAt,
    this.paidOn,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        total: (json['total'] is int)
            ? (json['total'] as int).toDouble()
            : (json['total'] as num?)?.toDouble(),
        id: json['_id'] ?? '',
        items: json['items'] != null
            ? List<Item>.from(json['items'].map((x) => Item.fromJson(x)))
            : [],
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'])
            : null,
        paidOn: json['paid_on'] != null
            ? DateTime.tryParse(json['paid_on'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'total': total,
        '_id': id,
        'items': items?.map((x) => x.toJson()).toList(),
        'created_at': createdAt?.toIso8601String(),
        'paid_on': paidOn?.toIso8601String(),
      };
}

class Item {
  final bool? isInStock;
  final String? id;
  final ItemId? itemId;
  final String? name;
  final double? price;
  final int? quantity;
  final String? size;
  final String? invoiceLink;
  final String? deliveryLink;
  final String? status;

  Item({
    this.isInStock,
    this.id,
    this.itemId,
    this.name,
    this.price,
    this.quantity,
    this.size,
    this.invoiceLink,
    this.deliveryLink,
    this.status,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        isInStock: json['is_in_stock'] ?? false,
        id: json['_id'] ?? '',
        itemId: json['item_id'] != null ? ItemId.fromJson(json['item_id']) : null,
        name: json['name'] ?? '',
        price: (json['price'] is int)
            ? (json['price'] as int).toDouble()
            : (json['price'] as num?)?.toDouble(),
        quantity: json['quantity'] ?? 1,
        size: json['size']?.toString() ?? '',
        invoiceLink: json['invoice_link'] ?? '',
        deliveryLink: json['delivery_link'] ?? '',
        status: json['status'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'is_in_stock': isInStock,
        '_id': id,
        'item_id': itemId?.toJson(),
        'name': name,
        'price': price,
        'quantity': quantity,
        'size': size,
        'invoice_link': invoiceLink,
        'delivery_link': deliveryLink,
        'status': status,
      };
}

class ItemId {
  final List<String>? pictures;
  final String? id;
  final String? description;
  final String? subtitle;

  ItemId({
    this.pictures,
    this.id,
    this.description,
    this.subtitle,
  });

  factory ItemId.fromJson(Map<String, dynamic> json) => ItemId(
        pictures: json['pictures'] != null
            ? List<String>.from(json['pictures'])
            : [],
        id: json['_id'] ?? '',
        description: json['description'] ?? '',
        subtitle: json['subtitle'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'pictures': pictures,
        '_id': id,
        'description': description,
        'subtitle': subtitle,
      };
}

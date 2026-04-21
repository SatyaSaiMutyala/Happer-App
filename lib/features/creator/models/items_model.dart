
class BrandId {
  final String id;
  final String name;
  final String description;
  final String picture;
  final double shippingPrice;
  final String accountType;

  BrandId({
    required this.id,
    required this.name,
    required this.description,
    required this.picture,
    required this.shippingPrice,
    required this.accountType,
  });

  factory BrandId.fromJson(Map<String, dynamic> json) {
    return BrandId(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      picture: json['picture'] ?? '',
      shippingPrice: (json['shipping_price'] is int ? json['shipping_price'].toDouble() : json['shipping_price'] ?? 0.0),
      accountType: json['account_type'] ?? '',
    );
  }
}

class ItemsModel {
  final String id;
  final String name;
  final String description;
  final String buyUrl;
  final List<String> pictures;
  final int promoPercent;
  final DateTime createdAt;
  final String ean13;
  final String sku;
  final Map<String, dynamic> sizeOfProduct; // Changed to dynamic since values can be null
  final double price;
  final String code;
  final String typeOfProduct;
  final int? v;
  final String? subtitle; // Added from your data
  final BrandId? brandId; // Added brand information
  final String? colorOfProduct; // Color of the product

  ItemsModel({
    required this.id,
    required this.name,
    required this.description,
    required this.buyUrl,
    required this.pictures,
    required this.promoPercent,
    required this.createdAt,
    required this.ean13,
    required this.sku,
    required this.sizeOfProduct,
    required this.price,
    required this.code,
    required this.typeOfProduct,
    this.v,
    this.subtitle,
    this.brandId,
    this.colorOfProduct,
  });

  factory ItemsModel.fromJson(Map<String, dynamic> json) {
    return ItemsModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      buyUrl: json['buy_url'] ?? '',
      pictures: List<String>.from(json['pictures']?.map((x) => x.toString()) ?? []),
      promoPercent: json['promo_percent']?.toInt() ?? 0,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      ean13: json['ean_13'] ?? '',
      sku: json['sku'] ?? '',
      sizeOfProduct: Map<String, dynamic>.from(json['size_of_product'] ?? {}),
      price: (json['price'] is int ? json['price'].toDouble() : json['price'] ?? 0.0),
      code: json['code'] ?? '',
      typeOfProduct: json['type_of_product'] ?? '',
      v: json['__v']?.toInt(),
      subtitle: json['subtitle'],
      brandId: json['brand_id'] != null ? BrandId.fromJson(json['brand_id']) : null,
      colorOfProduct: json['color_of_product'],
    );
  }
}

class Brand {
  final String id;
  final String name;
  final double shippingPrice;
  final String picture;
  final String accountType;
  final String description;
  final List<ItemsModel> topItems;
  final List<ItemsModel> bottomItems;
  final List<ItemsModel> accessoryItems;

  Brand({
    required this.id,
    required this.name,
    required this.shippingPrice,
    required this.picture,
    required this.accountType,
    required this.description,
    required this.topItems,
    required this.bottomItems,
    required this.accessoryItems,
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    List<ItemsModel> parseItems(List<dynamic>? items) {
      return items?.map((item) => ItemsModel.fromJson(item)).toList() ?? [];
    }

    return Brand(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      shippingPrice: (json['shipping_price'] is int ? json['shipping_price'].toDouble() : json['shipping_price'] ?? 0.0),
      picture: json['picture'] ?? '',
      accountType: json['account_type'] ?? '',
      description: json['description'] ?? '',
      topItems: parseItems(json['top']),
      bottomItems: parseItems(json['bottom']),
      accessoryItems: parseItems(json['accessory']),
    );
  }
}

// Root response model
// class BrandResponse {
//   final Brand brandDetails;

//   BrandResponse({
//     required this.brandDetails,
//   });

//   factory BrandResponse.fromJson(Map<String, dynamic> json) {
//     return BrandResponse(
//       brandDetails: Brand.fromJson(json['brand_details'] ?? {}),
//     );
//   }
// }


class BrandResponse {
  final List<ItemsModel> items;

  BrandResponse({
    required this.items,
  });

  factory BrandResponse.fromJson(List<dynamic> json) {
    return BrandResponse(
      items: json.map((item) => ItemsModel.fromJson(item)).toList(),
    );
  }
}




// class ItemsModel {
//   final String id;
//   final String name;
//   final String description;
//   final String buyUrl;
//   final List<String> pictures;
//   final List<String> containers;
//   final int promoPercent;
//   final DateTime createdAt;
//   final DateTime updatedAt;
//   final String ean13;
//   final String sku;
//   final Map<String, int> sizeOfProduct;
//   final double price;
//   final String code;
//   final String typeOfProduct;
//   final Brand brand;

//   ItemsModel({
//     required this.id,
//     required this.name,
//     required this.description,
//     required this.buyUrl,
//     required this.pictures,
//     required this.containers,
//     required this.promoPercent,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.ean13,
//     required this.sku,
//     required this.sizeOfProduct,
//     required this.price,
//     required this.code,
//     required this.typeOfProduct,
//     required this.brand,
//   });

//   factory ItemsModel.fromJson(Map<String, dynamic> json) {
//     DateTime parseDate(String? date) {
//       try {
//         return DateTime.parse(date ?? '');
//       } catch (e) {
//         return DateTime.now(); // Default to current date if parsing fails
//       }
//     }

//     return ItemsModel(
//       id: json['_id'] ?? '',
//       name: json['name'] ?? '',
//       description: json['description'] ?? '',
//       buyUrl: json['buy_url'] ?? '',
//       pictures: List<String>.from(json['pictures'] ?? []),
//       containers: List<String>.from(json['containers'] ?? []),
//       promoPercent: json['promo_percent'] ?? 0,
//       createdAt: parseDate(json['created_at']),
//       updatedAt: parseDate(json['updated_at']),
//       ean13: json['ean_13'] ?? '',
//       sku: json['sku'] ?? '',
//       sizeOfProduct: Map<String, int>.from(json['size_of_product'] ?? {}),
//       price: (json['price'] ?? 0).toDouble(),
//       code: json['code'] ?? '',
//       typeOfProduct: json['type_of_product'] ?? '',
//       brand: Brand.fromJson(json['brand_id'] ?? {}),
//     );
//   }
// }

// class Brand {
//   final String id;
//   final String name;
//   final String description;
//   final String picture;
//   final double shippingPrice;

//   Brand({
//     required this.id,
//     required this.name,
//     required this.description,
//     required this.picture,
//     required this.shippingPrice,
//   });

//   factory Brand.fromJson(Map<String, dynamic> json) {
//     return Brand(
//       id: json['_id'] ?? '',
//       name: json['name'] ?? '',
//       description: json['description'] ?? '',
//       picture: json['picture'] ?? '',
//       shippingPrice: (json['shipping_price'] ?? 0).toDouble(),
//     );
//   }
// }
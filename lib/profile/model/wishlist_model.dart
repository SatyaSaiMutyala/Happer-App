// lib/profile/model/wishlist_model.dart
class WishlistItem {
  final String id;           // _id from the wish item
  final String userId;       // user_id from the wish item
  final String createdAt;    // created_at from the wish item
  
  // Product details
  final String productId;    // product_id._id
  final String title;        // product_id.title
  final String brand;        // product_id.brand.name
  final Map<String, String> description; // product_id.description
  final double price;        // product_id.price
  final double? discountPercentage; // product_id.discount_percentage
  final List<String> pictures; // product_id.pictures
  final String startDate;    // product_id.start_date
  final String endDate;      // product_id.end_date
  final String? timer;        // product_id.timer
  final int? timerStamp;      // product_id.timerstamp

  WishlistItem({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.productId,
    required this.title,
    required this.brand,
    required this.description,
    required this.price,
    this.discountPercentage,
    required this.pictures,
    required this.startDate,
    required this.endDate,
    this.timer,
    this.timerStamp,
  });

  String get imageURL => pictures.isNotEmpty ? pictures[0] : '';
  
  // Calculate promo price if discount percentage is available
  double? get pricePromo {
    if (discountPercentage != null && discountPercentage! > 0) {
      return price - (price * discountPercentage! / 100);
    }
    return null;
  }

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    final productData = json['product_id'] as Map<String, dynamic>;
    
    return WishlistItem(
      id: json['_id'] ?? '',
      userId: json['user_id'] ?? '',
      createdAt: json['created_at'] ?? '',
      productId: productData['_id'] ?? '',
      title: productData['title'] ?? '',
      brand: productData['brand'] != null ? productData['brand']['name'] ?? '' : '',
      description: productData['description'] != null 
          ? Map<String, String>.from(productData['description'])
          : {'en': '', 'fr': ''},
      price: (productData['price'] ?? 0).toDouble(),
      discountPercentage: productData['discount_percentage'] != null 
          ? (productData['discount_percentage'] as num).toDouble()
          : null,
      pictures: productData['pictures'] != null 
          ? List<String>.from(productData['pictures'])
          : [],
      startDate: productData['start_date'] ?? '',
      endDate: productData['end_date'] ?? '',
      timer: productData['timer']?.toString() ?? '',
      timerStamp: productData['timerstamp'] != null 
          ? int.tryParse(productData['timerstamp'].toString()) ?? 0
          : 0,
    );
  }
}

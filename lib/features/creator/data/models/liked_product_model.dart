/// A liked product, as returned by GET /user/products/get-liked-products.
/// Each record is a ProductLike with populated brand / product / variant.
class LikedProductModel {
  final String likeId;
  final String productId;
  final String variantId;
  final String brandId;
  final String name;
  final String brandName;
  final String brandPicture;
  final String imageUrl;
  final num price;
  final num? compareAtPrice;

  const LikedProductModel({
    required this.likeId,
    required this.productId,
    required this.variantId,
    required this.brandId,
    required this.name,
    required this.brandName,
    required this.brandPicture,
    required this.imageUrl,
    required this.price,
    required this.compareAtPrice,
  });

  int? get discountPercent {
    final c = compareAtPrice;
    if (c == null || c <= 0 || c <= price) return null;
    return (((c - price) / c) * 100).round();
  }

  static String _id(dynamic ref) {
    if (ref is Map) return ref['_id']?.toString() ?? '';
    return ref?.toString() ?? '';
  }

  factory LikedProductModel.fromJson(Map<String, dynamic> json) {
    final brand = json['brand_id'];
    final product = json['product_id'];
    final variant = json['variant_id'];

    final brandMap = brand is Map ? brand : const {};
    final productMap = product is Map ? product : const {};
    final variantMap = variant is Map ? variant : const {};

    // Prefer the variant image, fall back to the product image.
    String image = '';
    final imgs = (variantMap['images'] as List?)
        ?.whereType<String>()
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (imgs != null && imgs.isNotEmpty) image = imgs.first;
    if (image.isEmpty) {
      image = (productMap['product_image'] as String? ?? '').trim();
    }

    return LikedProductModel(
      likeId: json['_id']?.toString() ?? '',
      productId: _id(product),
      variantId: _id(variant),
      brandId: _id(brand),
      name: (productMap['name'] as String? ?? '').trim(),
      brandName: (brandMap['name'] as String? ?? '').trim(),
      brandPicture: (brandMap['picture'] as String? ?? '').trim(),
      imageUrl: image,
      price: (variantMap['price'] as num?) ?? 0,
      compareAtPrice: variantMap['compare_at_price'] as num?,
    );
  }
}

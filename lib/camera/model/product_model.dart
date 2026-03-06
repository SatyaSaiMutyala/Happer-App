class Product {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final String categoryId;
  final double? price;

  Product({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.categoryId,
    this.price,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['image_url'],
      categoryId: json['category_id'],
      price: json['price'] != null ? double.parse(json['price'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'category_id': categoryId,
      'price': price,
    };
  }
}



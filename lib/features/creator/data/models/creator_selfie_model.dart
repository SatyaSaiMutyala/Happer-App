import 'package:happer_app/features/creator/models/creator_model.dart' as cm;

class CreatorSelfieUser {
  final String id;
  final String username;
  final String fullname;
  final int role;
  final String? profileImage;

  const CreatorSelfieUser({
    required this.id,
    required this.username,
    required this.fullname,
    required this.role,
    this.profileImage,
  });

  bool get hasPicture => profileImage != null && profileImage!.isNotEmpty;

  factory CreatorSelfieUser.fromJson(Map<String, dynamic> json) {
    return CreatorSelfieUser(
      id: json['_id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      fullname: json['fullname'] as String? ?? '',
      role: json['role'] as int? ?? 0,
      profileImage: json['profile_image'] as String?,
    );
  }
}

class CreatorSelfieModel {
  final String id;
  final String userId;
  final List<String> images;
  final String status;
  final List<Map<String, dynamic>> productObjects;
  final List<Map<String, dynamic>> linkedBrands;
  final CreatorSelfieUser? user;
  int likesCount;
  bool isLikedByMe;
  final String? createdAt;

  CreatorSelfieModel({
    required this.id,
    required this.userId,
    required this.images,
    required this.status,
    required this.productObjects,
    required this.linkedBrands,
    this.user,
    required this.likesCount,
    required this.isLikedByMe,
    this.createdAt,
  });

  List<Map<String, dynamic>> get uniqueBrands {
    final seen = <String>{};
    final result = <Map<String, dynamic>>[];
    // Prefer the top-level `linked_brands` (already populated with logo/name);
    // fall back to brand objects embedded in products when present.
    final sources = linkedBrands.isNotEmpty
        ? linkedBrands
        : productObjects
            .map((p) => p['brand_id'])
            .whereType<Map<String, dynamic>>()
            .toList();
    for (final brand in sources) {
      if (brand['_id'] != null &&
          brand['picture'] != null &&
          (brand['picture'] as String).isNotEmpty &&
          seen.add(brand['_id'] as String)) {
        result.add(brand);
      }
    }
    return result;
  }

  factory CreatorSelfieModel.fromJson(Map<String, dynamic> json) {
    final rawProducts = (json['linked_products'] ?? json['products']) as List<dynamic>? ?? [];
    final productObjects = rawProducts
        .whereType<Map<String, dynamic>>()
        .toList();
    final linkedBrands = (json['linked_brands'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();
    return CreatorSelfieModel(
      id: json['_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      images: (json['images'] as List<dynamic>? ?? []).cast<String>(),
      status: json['status'] as String? ?? '',
      productObjects: productObjects,
      linkedBrands: linkedBrands,
      user: json['user'] != null
          ? CreatorSelfieUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      likesCount: json['likes_count'] as int? ?? 0,
      isLikedByMe: json['is_liked_by_me'] as bool? ?? false,
      createdAt: json['created_at'] as String?,
    );
  }

  /// Adapts to the legacy CreatorModel required by SelfieDetailsScreen.
  cm.CreatorModel toCreatorModel() {
    return cm.CreatorModel(
      sId: id,
      picture: images.isNotEmpty ? images.first : null,
      images: images,
      createdAt: createdAt,
      isLikedByMe: isLikedByMe,
      nbLike: likesCount,
      user: user != null
          ? cm.User(
              sId: user!.id,
              userName: user!.username,
              firstName: user!.fullname,
              usersType: user!.role,
            )
          : null,
      itemsId: [],
    );
  }
}

class UserSelfieModel {
  final String id;
  final String userId;
  final List<String> images;
  final String status;
  final int likesCount;
  final String createdAt;

  /// Brands tagged in this look, each with `_id`, `name` and `picture`.
  /// The user-selfies endpoint only returns raw brand ids, so these are
  /// merged in from the creator-selfies endpoint by the repository.
  final List<Map<String, dynamic>> linkedBrands;

  const UserSelfieModel({
    required this.id,
    required this.userId,
    required this.images,
    required this.status,
    required this.likesCount,
    required this.createdAt,
    this.linkedBrands = const [],
  });

  String get primaryImage => images.isNotEmpty ? images.first : '';
  bool get hasImage => images.isNotEmpty;

  UserSelfieModel copyWith({List<Map<String, dynamic>>? linkedBrands}) {
    return UserSelfieModel(
      id: id,
      userId: userId,
      images: images,
      status: status,
      likesCount: likesCount,
      createdAt: createdAt,
      linkedBrands: linkedBrands ?? this.linkedBrands,
    );
  }

  factory UserSelfieModel.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'];
    final imageList = rawImages is List
        ? rawImages.map((e) => e.toString()).toList()
        : <String>[];
    return UserSelfieModel(
      id: json['_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      images: imageList,
      status: json['status'] as String? ?? '',
      likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}

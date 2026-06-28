/// A single autocomplete suggestion returned by
/// GET /user/selfies/get-suggestions. Each item is either a creator (`user`)
/// or a `brand`, distinguished by [type].
class SuggestionModel {
  final String id;
  final String type; // 'user' | 'brand'
  final String title; // full_name / username for users, brand name for brands
  final String? subtitle; // username for users (when full_name shown)
  final String? imageUrl; // profile_image for users, picture for brands

  const SuggestionModel({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    this.imageUrl,
  });

  bool get isUser => type == 'user';
  bool get isBrand => type == 'brand';

  factory SuggestionModel.fromJson(Map<String, dynamic> json) {
    final type = (json['type'] as String? ?? '').trim();
    if (type == 'brand') {
      return SuggestionModel(
        id: json['_id']?.toString() ?? '',
        type: 'brand',
        title: (json['brand_name'] as String? ?? json['name'] as String? ?? '')
            .trim(),
        subtitle: null,
        imageUrl: (json['picture'] as String?)?.trim(),
      );
    }
    // Default to user
    final fullName = (json['full_name'] as String? ?? '').trim();
    final username = (json['username'] as String? ?? '').trim();
    return SuggestionModel(
      id: json['_id']?.toString() ?? '',
      type: 'user',
      title: fullName.isNotEmpty ? fullName : username,
      subtitle: fullName.isNotEmpty && username.isNotEmpty ? '@$username' : null,
      imageUrl: (json['profile_image'] as String?)?.trim(),
    );
  }
}

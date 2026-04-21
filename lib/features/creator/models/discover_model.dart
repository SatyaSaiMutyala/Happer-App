// Removed unused code and added a placeholder for the Discover model
// Placeholder for Discover model
class DiscoverModel {
  final String imageUrl;

  DiscoverModel({required this.imageUrl});

  factory DiscoverModel.fromJson(Map<String, dynamic> json) {
    return DiscoverModel(
      imageUrl: json['imageUrl'],
    );
  }
}
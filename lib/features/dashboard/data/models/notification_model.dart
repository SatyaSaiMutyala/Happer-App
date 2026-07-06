/// A user notification from GET /user/notifications/fetch-list.
class NotificationModel {
  final String id;
  final String title; // subject
  final String message;
  final String path; // optional in-app route / deep link
  final String category;
  bool isRead; // is_viewed
  final DateTime? createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.path,
    required this.category,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    final rawDate = json['created_at'];
    if (rawDate is String && rawDate.isNotEmpty) {
      parsedDate = DateTime.tryParse(rawDate);
    }
    return NotificationModel(
      id: json['_id']?.toString() ?? '',
      title: (json['subject'] as String? ?? '').trim(),
      message: (json['message'] as String? ?? '').trim(),
      path: (json['path'] as String? ?? '').trim(),
      category: (json['category'] as String? ?? '').trim(),
      isRead: json['is_viewed'] as bool? ?? false,
      createdAt: parsedDate,
    );
  }
}

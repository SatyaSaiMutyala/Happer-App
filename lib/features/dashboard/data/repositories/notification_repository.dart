import 'package:happer_app/core/network/api_client.dart';
import 'package:happer_app/core/network/api_endpoints.dart';
import 'package:happer_app/features/dashboard/data/models/notification_model.dart';

class NotificationRepository {
  final ApiClient _client;

  NotificationRepository(this._client);

  /// Returns one page of notifications plus the total unseen count and whether
  /// more pages are available.
  Future<({List<NotificationModel> items, int unseenCount, bool hasMore})>
      getNotifications({int page = 1, int perPage = 10}) async {
    final response = await _client.get(
      ApiEndpoints.getNotifications,
      requiresAuth: true,
      queryParams: {'page': '$page', 'perPage': '$perPage'},
    );
    final outer = response['data'] as Map<String, dynamic>? ?? {};
    final list = (outer['data'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(NotificationModel.fromJson)
        .where((n) => n.id.isNotEmpty)
        .toList();
    final unseen = (outer['totalUnseenCount'] as num?)?.toInt() ?? 0;
    final totalPages = (outer['totalPages'] as num?)?.toInt() ?? page;
    return (items: list, unseenCount: unseen, hasMore: page < totalPages);
  }

  /// Fetches a single notification, which also marks it as read server-side.
  Future<void> markRead(String id) {
    return _client.get(ApiEndpoints.getNotification(id), requiresAuth: true);
  }

  Future<void> markAllRead() {
    return _client.put(ApiEndpoints.markAllNotificationsRead,
        requiresAuth: true);
  }

  Future<void> deleteNotification(String id) {
    return _client.delete(ApiEndpoints.deleteNotification(id),
        requiresAuth: true);
  }
}

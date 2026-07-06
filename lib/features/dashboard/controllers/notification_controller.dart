import 'package:get/get.dart';
import 'package:happer_app/features/dashboard/data/models/notification_model.dart';
import 'package:happer_app/features/dashboard/data/repositories/notification_repository.dart';

class NotificationController extends GetxController {
  final NotificationRepository _repo;

  NotificationController(this._repo);

  final notifications = <NotificationModel>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final unseenCount = 0.obs;
  final errorMessage = RxnString();

  int _page = 1;
  static const int _perPage = 10;
  bool _fetching = false;

  @override
  void onInit() {
    super.onInit();
    fetch(firstLoad: true);
  }

  Future<void> fetch({bool firstLoad = false}) async {
    if (_fetching || (!hasMore.value && !firstLoad)) return;
    _fetching = true;
    if (firstLoad) {
      _page = 1;
      hasMore.value = true;
      errorMessage.value = null;
      isLoading.value = notifications.isEmpty;
    } else {
      isLoadingMore.value = true;
    }
    try {
      final result =
          await _repo.getNotifications(page: _page, perPage: _perPage);
      if (firstLoad) {
        notifications.assignAll(result.items);
      } else {
        notifications.addAll(result.items);
      }
      unseenCount.value = result.unseenCount;
      hasMore.value = result.hasMore;
      _page++;
    } catch (e) {
      if (firstLoad) errorMessage.value = 'Une erreur est survenue';
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
      _fetching = false;
    }
  }

  @override
  Future<void> refresh() => fetch(firstLoad: true);

  /// Marks a single notification read (optimistic) and syncs server-side.
  Future<void> markRead(String id) async {
    final idx = notifications.indexWhere((n) => n.id == id);
    if (idx == -1 || notifications[idx].isRead) return;
    notifications[idx].isRead = true;
    notifications.refresh();
    if (unseenCount.value > 0) unseenCount.value--;
    try {
      await _repo.markRead(id);
    } catch (_) {
      // Non-fatal: the read state is already reflected locally.
    }
  }

  Future<void> markAllRead() async {
    if (notifications.every((n) => n.isRead)) return;
    for (final n in notifications) {
      n.isRead = true;
    }
    notifications.refresh();
    unseenCount.value = 0;
    try {
      await _repo.markAllRead();
    } catch (_) {}
  }

  /// Removes a notification (optimistic), reverting on failure.
  Future<void> delete(String id) async {
    final idx = notifications.indexWhere((n) => n.id == id);
    if (idx == -1) return;
    final removed = notifications[idx];
    notifications.removeAt(idx);
    if (!removed.isRead && unseenCount.value > 0) unseenCount.value--;
    try {
      await _repo.deleteNotification(id);
    } catch (_) {
      notifications.insert(idx.clamp(0, notifications.length), removed);
      if (!removed.isRead) unseenCount.value++;
    }
  }
}

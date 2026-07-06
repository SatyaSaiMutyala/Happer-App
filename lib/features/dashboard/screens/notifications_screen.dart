import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:happer_app/features/dashboard/bindings/notification_binding.dart';
import 'package:happer_app/features/dashboard/controllers/notification_controller.dart';
import 'package:happer_app/features/dashboard/data/models/notification_model.dart';
import 'package:happer_app/shared/widgets/happer_app_bar.dart';
import 'package:happer_app/features/profile/screens/notification_settings_screen.dart';
import 'package:happer_app/l10n/app_localizations.dart';
import 'package:shimmer/shimmer.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final NotificationController _controller;
  final ScrollController _scrollController = ScrollController();
  final Set<String> _expanded = {};

  @override
  void initState() {
    super.initState();
    NotificationBinding().dependencies();
    _controller = Get.find<NotificationController>();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 300 &&
        _controller.hasMore.value &&
        !_controller.isLoadingMore.value) {
      _controller.fetch();
    }
  }

  void _toggleExpanded(NotificationModel n) {
    setState(() {
      if (_expanded.contains(n.id)) {
        _expanded.remove(n.id);
      } else {
        _expanded.add(n.id);
      }
    });
    _controller.markRead(n.id);
  }

  Future<bool> _confirmDelete() async {
    final l = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.deleteNotificationTitle),
        content: Text(l.deleteNotificationConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child:
                Text(l.cancel, style: const TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            child: Text(l.delete, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    return confirm == true;
  }

  String _relativeTime(DateTime? date, AppLocalizations l) {
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return l.justNow;
    if (diff.inMinutes < 60) return l.minutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l.hoursAgo(diff.inHours);
    if (diff.inDays < 7) return l.daysAgo(diff.inDays);
    if (diff.inDays < 30) {
      final w = (diff.inDays / 7).floor();
      return w <= 1 ? l.weekAgo(1) : l.weeksAgo(w);
    }
    if (diff.inDays < 365) return l.monthsAgo((diff.inDays / 30).floor());
    final y = (diff.inDays / 365).floor();
    return y <= 1 ? l.yearAgo(1) : l.yearsAgo(y);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: HapperAppBar(
        title: l.notifications,
        actions: [
          Obx(() {
            if (_controller.unseenCount.value == 0) {
              return const SizedBox.shrink();
            }
            return GestureDetector(
              onTap: _controller.markAllRead,
              child: const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(Icons.done_all, color: Colors.black),
              ),
            );
          }),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const NotificationSettingsScreen()),
            ),
            child: const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.settings, color: Colors.black),
            ),
          ),
        ],
      ),
      body: Obx(() {
        final items = _controller.notifications;
        if (_controller.isLoading.value && items.isEmpty) {
          return _buildShimmer();
        }
        if (_controller.errorMessage.value != null && items.isEmpty) {
          return _buildError(l);
        }
        if (items.isEmpty) return _buildEmpty(l);

        return RefreshIndicator(
          color: Colors.black,
          onRefresh: _controller.refresh,
          child: ListView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: items.length + (_controller.isLoadingMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= items.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.black),
                    ),
                  ),
                );
              }
              final n = items[index];
              return Dismissible(
                key: Key(n.id),
                direction: DismissDirection.endToStart,
                confirmDismiss: (_) => _confirmDelete(),
                onDismissed: (_) => _controller.delete(n.id),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: _buildItem(n, l),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildItem(NotificationModel n, AppLocalizations l) {
    final isExpanded = _expanded.contains(n.id);
    return InkWell(
      onTap: () => _toggleExpanded(n),
      child: Container(
        color: n.isRead ? Colors.white : const Color(0xFFF9F9F9),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey.shade200,
                    radius: 24,
                    child: Icon(
                      n.isRead
                          ? Icons.notifications_outlined
                          : Icons.notifications_active,
                      color: Colors.grey,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                n.title,
                                style: const TextStyle(
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _relativeTime(n.createdAt, l),
                              style: const TextStyle(
                                  fontFamily: 'Lato',
                                  fontSize: 12,
                                  color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          n.message,
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                          maxLines: isExpanded ? null : 2,
                          overflow: isExpanded
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(AppLocalizations l) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: constraints.maxHeight,
          width: double.infinity,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_none_outlined,
                      size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    l.noNotifications,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l.noNotificationsSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildError(AppLocalizations l) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_controller.errorMessage.value ?? '',
              style: const TextStyle(fontFamily: 'Lato')),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _controller.refresh,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            child: const Text('Réessayer',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: ListView.builder(
        itemCount: 8,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const CircleAvatar(radius: 24, backgroundColor: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 14, width: 160, color: Colors.white),
                    const SizedBox(height: 8),
                    Container(
                        height: 12, width: double.infinity, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

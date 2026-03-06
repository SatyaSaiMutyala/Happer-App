import 'package:flutter/material.dart';
import 'package:happer_app/dashboard/models/notification_model.dart';
import 'package:happer_app/dashboard/screens/notification_details_screen.dart';
import 'package:happer_app/profile/api/profile_api.dart';
import '../../profile/ui/notification_settings_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ProfileApiService _apiService = ProfileApiService();
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _unreadCount = 0;
  Set<String> _expandedNotifications = {};

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      final List<NotificationModel> notifications =
          await _apiService.fetchNotifications();

      final notificationList = notifications.map((notification) {
        final uiModel = notification.toUiModel();
        return {
          'id': uiModel['id'],
          'title': uiModel['title'],
          'description': uiModel['description'],
          'time': _formatTimeAgo(notification.createdAt.toIso8601String()),
          'isRead': uiModel['isRead'],
          'type': uiModel['type'],
          'createdAt': notification.createdAt,
          'parameters': notification.parameter,
        };
      }).toList();

      notificationList.sort((a, b) => b['createdAt'].compareTo(a['createdAt']));

      setState(() {
        _notifications = notificationList;
        _isLoading = false;
        _updateUnreadCount();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load notifications: $e';
        _isLoading = false;
      });
    }
  }

  void _updateUnreadCount() {
    _unreadCount = _notifications
        .where((notification) => notification['isRead'] == false)
        .length;
  }

  void _markAsRead(String id) {
    setState(() {
      final index = _notifications.indexWhere((n) => n['id'] == id);
      if (index != -1 && _notifications[index]['isRead'] == false) {
        _notifications[index]['isRead'] = true;
        _updateUnreadCount();
        _apiService.markNotificationAsRead(id).catchError((error) {});
      }
    });
  }

  void _toggleExpanded(String id) {
    setState(() {
      if (_expandedNotifications.contains(id)) {
        _expandedNotifications.remove(id);
      } else {
        _expandedNotifications.add(id);
        _markAsRead(id);
      }
    });
  }

  String _formatTimeAgo(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);
      if (difference.inSeconds < 60) return '${difference.inSeconds}s ago';
      if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
      if (difference.inHours < 24) return '${difference.inHours}h ago';
      if (difference.inDays < 30) return '${difference.inDays}d ago';
      return '${(difference.inDays / 30).floor()}mo ago';
    } catch (_) {
      return 'Unknown';
    }
  }

  bool isValidImageUrl(String? url) {
  if (url == null || url.isEmpty) return false;
  try {
    final uri = Uri.parse(url);
    final path = uri.path.toLowerCase();
    return uri.isAbsolute && (
      path.endsWith('.png') ||
      path.endsWith('.jpg') ||
      path.endsWith('.jpeg') ||
      path.endsWith('.webp') ||
      path.endsWith('.gif')
    );
  } catch (_) {
    return false;
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'NOTIFICATIONS',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            height: 1.0,
            letterSpacing: 0.0,
          ),
        ),
        actions: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationSettingsScreen(),
                    ),
                  );
                },
                child: const Icon(Icons.settings, color: Colors.black),
              ),
              const SizedBox(width: 16),
              // if (_unreadCount > 0)
              //   Container(
              //     margin: const EdgeInsets.only(right: 16),
              //     padding: const EdgeInsets.all(8),
              //     decoration: const BoxDecoration(
              //       color: Colors.red,
              //       shape: BoxShape.circle,
              //     ),
              //     child: Text(
              //       _unreadCount.toString(),
              //       style: const TextStyle(
              //         color: Colors.white,
              //         fontSize: 12,
              //         fontWeight: FontWeight.bold,
              //       ),
              //     ),
              //   ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _notifications.isEmpty
                  ? const Center(child: Text('No notifications'))
                  : RefreshIndicator(
                      onRefresh: _fetchNotifications,
                      child: ListView.builder(
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                          final notification = _notifications[index];
                          return Dismissible(
  key: Key(notification['id']),
  direction: DismissDirection.endToStart,
  background: Container(
    color: Colors.red,
    alignment: Alignment.centerRight,
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: const Icon(Icons.delete, color: Colors.white),
  ),
 onDismissed: (direction) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Notification'),
      content: const Text('Are you sure you want to delete this notification?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel',style: TextStyle(color: Colors.black),),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
          child: const Text('Delete', style: TextStyle(color: Colors.white,)),
        ),
      ],
    ),
  );

  if (confirm == true) {
    _deleteNotification(notification['id']);
  } else {
    // If cancelled, re-insert the notification back into the list
    setState(() {});
  }
},
  child: _buildNotificationItem(notification),
);
                        },
                      ),
                    ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    final bool isExpanded = _expandedNotifications.contains(notification['id']);
    final String description = notification['description'] ?? '';
    final List<String?> parameters = notification['parameters'] ?? [];
    final String? imageUrl = (parameters.length > 2) ? parameters[2] : null;
    final bool hasImage = isValidImageUrl(imageUrl);

    return InkWell(
     onTap: () async {
  if (hasImage) {
    _markAsRead(notification['id']);
    final deleted = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NotificationDetailScreen(
          id: notification['id'],
          title: notification['title'],
          description: description,
          time: notification['time'],
          imageUrl: imageUrl,
        ),
      ),
    );

    if (deleted == true) {
      _deleteNotification(notification['id']);
    }
  } else {
    _toggleExpanded(notification['id']);
  }
},

      child: Container(
        color: notification['isRead'] ? Colors.white : const Color(0xFFF9F9F9),
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
                      notification['isRead']
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                notification['title'] ?? '',
                                style: const TextStyle(
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
                              notification['time'] ?? '',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                          maxLines: (!hasImage && isExpanded) ? null : 2,
                          overflow: (!hasImage && isExpanded)
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis,
                        ),
                        if (!hasImage &&
                            isExpanded &&
                            description.length > 100)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              'Tap to collapse',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
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
  
void _deleteNotification(String id) async {
  setState(() {
    _notifications.removeWhere((n) => n['id'] == id);
    _updateUnreadCount();
  });
  try {
    final accessToken = await _apiService.getToken();
    if (accessToken != null) {
      await _apiService.deleteNotification(id, accessToken);
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to delete notification')),
    );
  }
}
}

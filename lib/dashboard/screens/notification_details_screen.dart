import 'package:flutter/material.dart';
import 'package:happer_app/profile/api/profile_api.dart';

class NotificationDetailScreen extends StatefulWidget {
  final String id;
  final String title;
  final String description;
  final String time;
  final String? imageUrl;

  const NotificationDetailScreen({
    Key? key,
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    this.imageUrl,
  }) : super(key: key);

  @override
  State<NotificationDetailScreen> createState() => _NotificationDetailScreenState();
}

class _NotificationDetailScreenState extends State<NotificationDetailScreen> {
  final ProfileApiService _apiService = ProfileApiService();
  bool _isDeleting = false;

  void _deleteNotification() async {
    setState(() {
      _isDeleting = true;
    });

    try {
      final accessToken = await _apiService.getToken();
      if (accessToken != null) {
        await _apiService.deleteNotification(widget.id, accessToken);
        Navigator.pop(context, true); // Notify parent to remove the item
      } else {
        throw Exception("No access token");
      }
    } catch (e) {
      setState(() {
        _isDeleting = false;
      });
      
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'TITLE MESSAGE',
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
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: _isDeleting ? null : _deleteNotification,
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(widget.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              SizedBox(width: 10),
              Text(widget.time, style: TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
          SizedBox(height: 8),
          Text(widget.description, style: TextStyle(fontSize: 15, color: Colors.black87)),
          SizedBox(height: 24),
          if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey.shade200,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.broken_image, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Image failed to load', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

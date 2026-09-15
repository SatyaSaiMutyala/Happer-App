import 'package:flutter/material.dart';
import 'package:happer_app/shared/widgets/happer_app_bar.dart';
import 'package:happer_app/l10n/app_localizations.dart';

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
  bool _isDeleting = false;

  void _deleteNotification() {
    setState(() => _isDeleting = true);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: HapperAppBar(
        title: l.dashMessageTitle,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
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
                      children: [
                        const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                        const SizedBox(height: 8),
                        Text(l.dashImageFailedToLoad, style: const TextStyle(color: Colors.grey)),
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

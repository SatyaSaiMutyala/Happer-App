import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:happer_app/features/dashboard/models/notification_model.dart';
import 'package:happer_app/core/network/websocket_service.dart';

class WebSocketNotificationService {
  static final WebSocketNotificationService _instance =
      WebSocketNotificationService._internal();
  factory WebSocketNotificationService() => _instance;

  late WebSocketService _webSocketService;

  WebSocketNotificationService._internal();

  Future<void> initialize() async {
    // Initialize WebSocket
    _webSocketService = WebSocketService('ws://happer-websocket-plp.azurewebsites.net');
    _webSocketService.connect();

    // Listen to WebSocket messages
    _webSocketService.stream.listen(
      (data) {
        handleWebSocketMessage(data);
      },
      onError: (error) {
        // Optional: Reconnect logic
      },
      onDone: () {
        // Optional: Reconnect logic
      },
    );
  }

  Future<void> handleWebSocketMessage(dynamic message) async {
    try {
      final decodedData = jsonDecode(message);
      if (decodedData is Map<String, dynamic> &&
          decodedData.containsKey('notification')) {
        final notification = NotificationModel.fromJson(decodedData);

        // You could show a snackbar or in-app alert instead of local notification
      }
    } catch (e) {
      // Handle error
    }
  }

  void handleNotificationTap(Map<String, dynamic> notificationData) {
    // Add navigation or in-app logic here
  }

  Future<void> dispose() async {
    _webSocketService.disconnect();
  }
}

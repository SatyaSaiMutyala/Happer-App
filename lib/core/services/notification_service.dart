import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:happer_app/core/utils/storage_service.dart';
import 'package:happer_app/firebase_options.dart';

// Must be a top-level function — called when app is terminated
@pragma('vm:entry-point')
Future<void> _onBackgroundMessage(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  await NotificationService.instance.setupFlutterNotifications();
  await NotificationService.instance.showNotification(message);
}

class NotificationService {
  NotificationService._();

  static final instance = NotificationService._();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _channelId = 'happer_notifications';
  static const _channelName = 'Happer Notifications';
  static const _channelDesc = 'Happer app notifications';

  // ─── Public entry point ──────────────────────────────────────────────────

  Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);
    await _requestPermission();
    await setupFlutterNotifications();
    await _setupMessageHandlers();
    await _fetchAndSaveToken();
    _messaging.onTokenRefresh.listen(_onTokenRefresh);
  }

  // ─── Token ───────────────────────────────────────────────────────────────

  Future<void> _fetchAndSaveToken() async {
    final token = await _messaging.getToken();
    if (token != null) {
      await StorageService.setString('fcm_token', token);
      _printToken(token);
    }
  }

  void _onTokenRefresh(String token) {
    StorageService.setString('fcm_token', token);
    _printToken(token);
  }

  void _printToken(String token) {
    print('');
    print('╔══════════════════════════════════════════════════╗');
    print('║         FCM TOKEN — paste in Firebase            ║');
    print('╠══════════════════════════════════════════════════╣');
    print('║ $token');
    print('╚══════════════════════════════════════════════════╝');
    print('');
  }

  /// Returns the saved FCM token (or fetches fresh if not cached).
  Future<String?> getToken() async {
    return StorageService.getString('fcm_token') ??
        await _messaging.getToken();
  }

  // ─── Permissions ─────────────────────────────────────────────────────────

  Future<void> _requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (Platform.isIOS) {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  // ─── Local notifications setup ───────────────────────────────────────────

  Future<void> setupFlutterNotifications() async {
    if (_initialized) return;

    // Create Android high-importance channel
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await _localNotifications.initialize(
      const InitializationSettings(
        // @mipmap/ic_launcher is the app icon — shown in status bar (Android auto-converts to white silhouette)
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        ),
      ),
      onDidReceiveNotificationResponse: (details) =>
          _handleTap(details.payload),
    );

    _initialized = true;
  }

  // ─── Show notification ───────────────────────────────────────────────────

  Future<void> showNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    print('[Notification] ${notification.title} — ${notification.body}');

    await _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
          // Small icon (status bar) — white silhouette of app icon
          icon: '@mipmap/ic_launcher',
          // Large icon (notification body) — full-color app logo
          largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          // Brand color shown behind the small icon circle
          color: Colors.black,
          channelShowBadge: true,
          playSound: true,
          // Expand long notification bodies
          styleInformation: BigTextStyleInformation(
            notification.body ?? '',
            contentTitle: notification.title,
          ),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'default',
          badgeNumber: 1,
        ),
      ),
      payload: json.encode(message.data),
    );
  }

  // ─── Message handlers ────────────────────────────────────────────────────

  Future<void> _setupMessageHandlers() async {
    // App in foreground — show local notification manually
    FirebaseMessaging.onMessage.listen((message) {
      print('[Notification] Foreground: ${message.notification?.title}');
      showNotification(message);
    });

    // App in background — user tapped notification
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);

    // App was terminated — user tapped notification to open
    final initial = await _messaging.getInitialMessage();
    if (initial != null) _handleMessageTap(initial);
  }

  void _handleMessageTap(RemoteMessage message) {
    print('[Notification] Tapped — data: ${message.data}');
    // TODO: navigate based on message.data['type'] once routes are wired
  }

  void _handleTap(String? payload) {
    if (payload == null) return;
    try {
      final data = json.decode(payload) as Map<String, dynamic>;
      debugPrint('[Notification] Tap payload: $data');
      // TODO: navigate based on data['type'] once routes are wired
    } catch (e) {
      debugPrint('Failed to parse notification payload: $e');
    }
  }
}

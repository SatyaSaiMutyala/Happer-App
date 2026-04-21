import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:happer_app/firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    // Initialize Firebase only if it hasn't been initialized already
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    final notificationService = NotificationService.instance;
    await notificationService.setupFlutterNotifications();
    await notificationService.showNotification(message);
 
  } catch (e) {
  
  }
}

class NotificationService {
  // Use a lazy singleton pattern to ensure Firebase is initialized first
  static NotificationService? _instance;
  static NotificationService get instance {
    _instance ??= NotificationService._();
    return _instance!;
  }
  
  NotificationService._() {
    // Don't initialize Firebase here
  }

  // Use lazy loading to ensure Firebase is initialized before accessing
  late final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  bool _isFlutterLocalNotificationsInitialized = false;
  
  // Channel IDs
  static const String _channelId = 'high_importance_channel';
  static const String _channelName = 'High Importance Notifications';
  static const String _channelDescription = 'This channel is used for important notifications.';
  
  // API URL for token registration
    static const String _apiBaseUrl = 'https://newapi.happer.fr/api';

  //final String _apiBaseUrl = 'https://happer-production.francecentral.cloudapp.azure.com/api';

  Future<void> initialize() async {
    // Set background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request notification permissions
    await _requestPermission();

    // Setup local notifications
    await setupFlutterNotifications();
    
    // Setup message handlers for different app states
    await _setupMessageHandlers();

    // Get FCM token and send to backend
    final token = await _messaging.getToken();
    if (token != null) {

      await _saveTokenToPrefs(token);
      // No need to call sendTokenToServer here as the backend will pick it up
    }
    
    // Set up token refresh listener
    _messaging.onTokenRefresh.listen((newToken) {
   
      _saveTokenToPrefs(newToken);
    });
  }
  
  // Save token to SharedPreferences
  Future<void> _saveTokenToPrefs(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', token);
  }
  
  // Get token from SharedPreferences
  Future<String?> _getTokenFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('fcm_token');
  }
  
  // Get the auth token from SharedPreferences
  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );

   
    
    // Request specific iOS permissions
    if (Platform.isIOS) {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  Future<void> setupFlutterNotifications() async {
    if (_isFlutterLocalNotificationsInitialized) {
      return;
    }

    // Android setup
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    // iOS setup
    final initializationSettingsDarwin = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    // Initialize flutter local notifications
    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification click
        _handleNotificationClick(details.payload);
      },
    );

    _isFlutterLocalNotificationsInitialized = true;
  }

  Future<void> showNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    
    if (notification != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.high,
            priority: Priority.high,
            icon: android?.smallIcon ?? '@mipmap/launcher_icon',
            channelShowBadge: true,
            color: Colors.blue,
            playSound: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            sound: 'default',
            // Use a default badge number or parse from data
            badgeNumber: 1,
            categoryIdentifier: 'textCategory',
          ),
        ),
        payload: json.encode(message.data),
      );
    }
  }

  Future<void> _setupMessageHandlers() async {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {

      
      showNotification(message);
    });

    // Handle when user taps on notification while app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    // Handle when app is opened from a terminated state
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
       _handleBackgroundMessage(initialMessage);
    }
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    
    // Handle different notification types
    if (message.data['type'] == 'chat') {
      // Navigate to chat screen
         } else if (message.data['type'] == 'order') {
      // Navigate to order details
        // NavigationService.navigateToOrder(message.data['orderId']);
    } else {
      // Default action
         // NavigationService.navigateToHome();
    }
  }
  
  void _handleNotificationClick(String? payload) {
    if (payload != null) {
      try {
        // Parse payload and navigate accordingly
        final data = json.decode(payload) as Map<String, dynamic>;
        
        // Handle navigation based on notification type
        final type = data['type'];
        if (type != null) {
          switch (type) {
            case 'chat':
              // Navigate to chat
              break;
            case 'order':
              // Navigate to order
              break;
            default:
              // Default navigation
              break;
          }
        }
      } catch (e) {

      }
    }
  }
  
  // Method to update the token on the server
  Future<bool> updateTokenOnServer(String token, String userId) async {
    try {
      final authToken = await _getAuthToken();
      if (authToken == null) {
    
        return false;
      }
      
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/users/$userId/fcm-token'),
        headers: {
          'Authorization': authToken,
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'fcmToken': token,
        }),
      );
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
  
      return false;
    }
  }
  
  // Method to get the current FCM token
  Future<String?> getToken() async {
    // Try to get the token from shared preferences first for quick access
    final storedToken = await _getTokenFromPrefs();
    if (storedToken != null) {
      return storedToken;
    }
    
    // If not found in preferences, get from Firebase
    final token = await _messaging.getToken();
    if (token != null) {
      await _saveTokenToPrefs(token);
    }
    return token;
  }
}
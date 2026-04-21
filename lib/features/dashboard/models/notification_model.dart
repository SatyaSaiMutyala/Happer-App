import 'dart:convert';

class NotificationModel {
  final String id;
  final String userId;
  final String type;
  final List<String?> parameter;
  final DateTime createdAt;
  final NotificationMessageModel message;
  final int v; // __v field from backend

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.parameter,
    required this.createdAt,
    required this.message,
    required this.v,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? '',
      userId: json['user_id'] ?? '',
      type: json['type'] ?? '',
      parameter: (json['parameter'] as List?)?.map((e) => e?.toString()).toList() ?? [],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      message: NotificationMessageModel.fromJson(json['message'] ?? {}),
      v: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toUiModel() {
    return {
      'id': id,
      'title': message.notification?.title ?? '',
      'description': message.notification?.body ?? '',
      'time': createdAt.toIso8601String(),
      'isRead': false,
      'type': type,
      'imageUrl': message.android?.notification?.imageUrl ??
          message.apns?.fcmOptions?.image ??
          message.webpush?.headers?.image ??
          '',
    };
  }
}

class NotificationMessageModel {
  final NotificationContent? notification;
  final NotificationAndroid? android;
  final NotificationApns? apns;
  final WebPush? webpush;
  final List<String> tokens;

  NotificationMessageModel({
    this.notification,
    this.android,
    this.apns,
    this.webpush,
    required this.tokens,
  });

  factory NotificationMessageModel.fromJson(Map<String, dynamic> json) {
    return NotificationMessageModel(
      notification: json['notification'] != null
          ? NotificationContent.fromJson(json['notification'])
          : null,
      android: json['android'] != null
          ? NotificationAndroid.fromJson(json['android'])
          : null,
      apns: json['apns'] != null
          ? NotificationApns.fromJson(json['apns'])
          : null,
      webpush: json['webpush'] != null
          ? WebPush.fromJson(json['webpush'])
          : null,
      tokens: List<String>.from(json['tokens'] ?? []),
    );
  }
}

class NotificationContent {
  final String title;
  final String body;

  NotificationContent({
    required this.title,
    required this.body,
  });

  factory NotificationContent.fromJson(Map<String, dynamic> json) {
    return NotificationContent(
      title: json['title'] ?? '',
      body: json['body'] ?? '',
    );
  }
}

class NotificationAndroid {
  final AndroidNotification? notification;

  NotificationAndroid({this.notification});

  factory NotificationAndroid.fromJson(Map<String, dynamic> json) {
    return NotificationAndroid(
      notification: json['notification'] != null
          ? AndroidNotification.fromJson(json['notification'])
          : null,
    );
  }
}

class AndroidNotification {
  final String? imageUrl;

  AndroidNotification({this.imageUrl});

  factory AndroidNotification.fromJson(Map<String, dynamic> json) {
    return AndroidNotification(
      imageUrl: json['imageUrl'],
    );
  }
}

class NotificationApns {
  final NotificationApnsPayload? payload;
  final ApnsFcmOptions? fcmOptions;

  NotificationApns({this.payload, this.fcmOptions});

  factory NotificationApns.fromJson(Map<String, dynamic> json) {
    return NotificationApns(
      payload: json['payload'] != null
          ? NotificationApnsPayload.fromJson(json['payload'])
          : null,
      fcmOptions: json['fcm_options'] != null
          ? ApnsFcmOptions.fromJson(json['fcm_options'])
          : null,
    );
  }
}

class NotificationApnsPayload {
  final ApnsApsSettings? aps;

  NotificationApnsPayload({this.aps});

  factory NotificationApnsPayload.fromJson(Map<String, dynamic> json) {
    return NotificationApnsPayload(
      aps: json['aps'] != null ? ApnsApsSettings.fromJson(json['aps']) : null,
    );
  }
}

class ApnsApsSettings {
  final int? mutableContent;

  ApnsApsSettings({this.mutableContent});

  factory ApnsApsSettings.fromJson(Map<String, dynamic> json) {
    return ApnsApsSettings(
      mutableContent: json['mutable-content'],
    );
  }
}

class ApnsFcmOptions {
  final String? image;

  ApnsFcmOptions({this.image});

  factory ApnsFcmOptions.fromJson(Map<String, dynamic> json) {
    return ApnsFcmOptions(
      image: json['image'],
    );
  }
}

class WebPush {
  final WebPushHeaders? headers;

  WebPush({this.headers});

  factory WebPush.fromJson(Map<String, dynamic> json) {
    return WebPush(
      headers: json['headers'] != null
          ? WebPushHeaders.fromJson(json['headers'])
          : null,
    );
  }
}

class WebPushHeaders {
  final String? image;

  WebPushHeaders({this.image});

  factory WebPushHeaders.fromJson(Map<String, dynamic> json) {
    return WebPushHeaders(
      image: json['image'],
    );
  }
}

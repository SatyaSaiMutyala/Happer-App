class NotificationSettings {
  bool wishlistNotifications;
  bool creditsNotifications;
  bool pushNotifications;

  NotificationSettings({
    this.wishlistNotifications = true,
    this.creditsNotifications = true,
    this.pushNotifications = true,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      wishlistNotifications: json['notif_wishlist'] ?? true,
      creditsNotifications: json['notif_credits'] ?? true,
      pushNotifications: json['notif_push'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wishlist': wishlistNotifications,
      'credits': creditsNotifications,
      'push': pushNotifications,
    };
  }
}

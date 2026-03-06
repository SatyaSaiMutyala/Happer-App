import Firebase
import FirebaseMessaging
import UserNotifications
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, MessagingDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    Messaging.messaging().delegate = self
    UNUserNotificationCenter.current().delegate = self

    // Permission request moved to Flutter side (dashboard screen)
    // It will be requested via NotificationService.initialize()

    application.registerForRemoteNotifications()
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    Messaging.messaging().apnsToken = deviceToken
  }

  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    print("FCM Token: \(fcmToken ?? "")")
    // Save or send this token to your server for targeting
  }

  // Handle Universal Links
  override func application(
      _ application: UIApplication,
      continue userActivity: NSUserActivity,
      restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
  ) -> Bool {
      // Pass the universal link to Flutter
      return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
  }

}

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

    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
      print("Permission granted: \(granted)")
    }

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
}

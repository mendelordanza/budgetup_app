import UIKit
import Flutter
import flutter_local_notifications
import workmanager

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      GeneratedPluginRegistrant.register(with: self)
      
      if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
      }
      
      // This is required to make any communication available in the action isolate.
        FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
          GeneratedPluginRegistrant.register(with: registry)
        }
      
      WorkmanagerPlugin.setPluginRegistrantCallback { registry in
          GeneratedPluginRegistrant.register(with: registry)
      }
      
      UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(60*15))
      
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

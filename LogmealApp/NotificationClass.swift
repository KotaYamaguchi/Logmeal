import UIKit
import SwiftUI
import UserNotifications

class NotificationClass: NSObject, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // いかを追記
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                // 通知の許可が得られた場合の処理
                UNUserNotificationCenter.current().delegate = self
            } else {
                // 通知の許可が得られなかった場合の処理
                print("Notification permission denied")
            }
        }
        return true
    }
    
}



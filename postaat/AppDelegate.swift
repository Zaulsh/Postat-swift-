//
//  AppDelegate.swift
//  WebViewWithFCM
//
//  Created by ahmed abdelhameed on 2/21/20.
//  Copyright © 2020 ahmed abdelhameed. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate , MessagingDelegate {
    
    let notificationCenter = UNUserNotificationCenter.current()
    var window: UIWindow?
    var action_url: String = ""
    
    
   
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow()
        
        window?.rootViewController = UINavigationController(rootViewController: ViewController())
        
        window?.makeKeyAndVisible()
        FirebaseApp.configure()
     
        UIApplication.shared.applicationIconBadgeNumber = 0
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self

        
        
        registerForPushNotifications()
        return true
    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            print("Permission granted: \(granted)")
            // 1. Check if permission granted
            guard granted else { return }
            // 2. Attempt registration for remote notifications on the main thread
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
           Messaging.messaging().apnsToken = deviceToken
       }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("InstanceID token: \(fcmToken)")
        
          UserDefaults.standard.set(fcmToken, forKey: "token")
        print("Device Token: \(fcmToken)")
    }


     func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
         // 1. Print out error if PNs registration not successful
         print("Failed to register for remote notifications with error: \(error)")
     }
    
    
    
    func handleNotificationParams(userInfo:[AnyHashable:Any]){
        
        let action  = userInfo["action"] as? String ?? ""
        let title = userInfo["newTitle"] as? String ?? ""
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NotificationAction"), object: action)
        
        print("action is: \(action) ,title is: \(title)" )
 
    }
    
    //for notification if app is in background or not running
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
       
        handleNotificationParams(userInfo: userInfo)
    }
    
    //for notification if app in foreground
//    @available(iOS 10, *)
//    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        let userInfo = notification.request.content.userInfo
//        // Print full message.
//        completionHandler([UNNotificationPresentationOptions.alert,UNNotificationPresentationOptions.sound,UNNotificationPresentationOptions.badge])
//
//        handleNotificationParams(userInfo: userInfo)
//    }
    
    
}


@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo
        debugPrint(userInfo)
        handleNotificationParams(userInfo: userInfo)
        
        completionHandler([.alert, .sound])
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        handleNotificationParams(userInfo: userInfo)
        debugPrint(userInfo)
        completionHandler()
    }
}
// [END ios_10_message_handling]

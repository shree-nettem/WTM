//
//  AppDelegate.swift
//  WTM
//
//  Created by Tarun Sachdeva on 29/11/20.
//

import UIKit
import IQKeyboardManagerSwift
import Firebase
import SwiftMessages
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate , UNUserNotificationCenterDelegate, MessagingDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        NetworkMonitor.shared.startMonitoring()
        
        IQKeyboardManager.shared.enable = true
        
        FirebaseApp.configure()
        
        
        setUserFlow()
       
        
        
        //Push Notification
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound],
                                           categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
        
        let notificationCenter = NotificationCenter.default
            
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(appCameToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        
        
        //NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: appli),object: message))
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: NSNotification.Name(rawValue: UIApplication.didEnterBackgroundNotification.rawValue), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(appCameToForeground), name: NSNotification.Name(rawValue: UIApplication.willEnterForegroundNotification.rawValue), object: nil)
            
        
        return true
    }
    
    @objc func appMovedToBackground() {
        print("app enters background")
    }

    @objc func appCameToForeground() {
        
        print("app enters foreground")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.setUserFlow()
        }
    }
    
    
    func setUserFlow() {
        var initialViewController = UIViewController()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let navigationController:UINavigationController = storyboard.instantiateInitialViewController() as! UINavigationController
        
        
        if Utility.isKeyPresentInUserDefaults(key: SharedData.isAlreadyLogin) {
            let loginStatus = UserDefaults.standard.bool(forKey: SharedData.isAlreadyLogin)
            
            if loginStatus {
                if Utility.isKeyPresentInUserDefaults(key: SharedData.isPinOn) {
                    let pinStatus = UserDefaults.standard.bool(forKey: SharedData.isPinOn)
                    
                    if pinStatus {
                        initialViewController = storyboard.instantiateViewController(withIdentifier: "LoginWithPinVC")
                    }
                    else {
                        initialViewController = storyboard.instantiateViewController(withIdentifier: "LoginVC")
                    }
                }
                else {
                    initialViewController = storyboard.instantiateViewController(withIdentifier: "LoginVC")
                }
            }
            else {
                initialViewController = storyboard.instantiateViewController(withIdentifier: "LoginVC")
            }
        }
        else {
            initialViewController = storyboard.instantiateViewController(withIdentifier: "LoginVC")
        }
        
 
        navigationController.viewControllers = [initialViewController]
        self.window?.rootViewController = navigationController
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Got the msg...")
        completionHandler([.badge, .sound, .alert])
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        UserDefaults.standard.set(fcmToken, forKey: "pushToken")
        UserDefaults.standard.synchronize()
        // NetworkRequest.HitPostRequestWithHeader(params: params, url: API.saveToken, serviceType: API.saveToken, indicator: true)
    }
    internal func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var token = ""
        for i in 0..<deviceToken.count {
            token = token + String(format: "%02.2hhx", arguments: [deviceToken[i]])
        }
        print("Registration succeeded! Token: ", token)
        let FCMtoken = Messaging.messaging().fcmToken
        
        Messaging.messaging().apnsToken = deviceToken
        
        print("FCM token: \(FCMtoken ?? "")")
        
    
        
        //Device Token
        UserDefaults.standard.set(FCMtoken, forKey: "pushToken")
        
        
    }
    
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
    }
    
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        //Handle the notification
    }
    
    // The callback to handle data message received via FCM for devices running iOS 10 or above.
    func applicationReceivedRemoteMessage(_ remoteMessage: MessagingRemoteMessage) {
        print(remoteMessage.appData)
    }
    

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}


//
//  AppDelegate.swift
//  BookingTicket
//
//  Created by anhthu on 11/28/17.
//  Copyright © 2017 anhthu. All rights reserved.
//
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        var result = false
        for s in services {
            if s.application?(application, willFinishLaunchingWithOptions: launchOptions) ?? false {
                result = true
            }
        }
        return result
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window?.makeKeyAndVisible()
        var result = false
        for s in services {
            if s.application?(application, didFinishLaunchingWithOptions: launchOptions) ?? false {
                result = true
            }
        }
        return result
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        for s in services {
            s.applicationDidEnterBackground?(application)
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        for s in services {
            s.applicationDidBecomeActive?(application)
        }
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        for s in services {
            if s.application?(application, open: url, sourceApplication: sourceApplication, annotation: annotation) ?? false {
                return true
            }
        }
        return false
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        for s in services {
            s.application?(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        for s in services {
            s.application?(application, didReceiveRemoteNotification: userInfo)
        }
    }
    
    // MARK: Private
    
    private func createServices() -> [AppDelegateService] {
        let window = self.window!
        let services: [AppDelegateService] = [
            LoginStatusService(window: window),
            AppearanceService(window: window)
        ]
        return services
    }
    
    // MARK: Properties
    
    var window: UIWindow?
    private lazy var services: [AppDelegateService] = self.createServices()
}


//
//  AppDelegate+AppearanceService.swift
//  BookingTicket
//
//  Created by anhthu on 12/2/17.
//  Copyright © 2017 anhthu. All rights reserved.
//

import Foundation
import UIKit
extension AppDelegate {
    final class AppearanceService: NSObject, AppDelegateService {
        init(window: UIWindow) {
            self.window = window
            super.init()
        }
        
        func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
            customizeAppearance(window)
            return true
        }
        
        private func customizeAppearance(_ window: UIWindow) {
            window.tintColor = ColorPalette.mainColor
            let mainNavigationClass = [MainNavigationController.self]
            UINavigationBar.appearance(whenContainedInInstancesOf: mainNavigationClass).shadowImage = UIImage.imageWithColor(UIColor.clear)
            UINavigationBar.appearance(whenContainedInInstancesOf: mainNavigationClass).tintColor = UIColor.white
            UINavigationBar.appearance(whenContainedInInstancesOf: mainNavigationClass).titleTextAttributes = [.foregroundColor: UIColor.white]
            UINavigationBar.appearance().isTranslucent = false
            UINavigationBar.appearance().barTintColor = ColorPalette.whiteNavigationBarColor
            let allNavigationClasses = [NavigationController.self]
            UINavigationBar.appearance(whenContainedInInstancesOf: allNavigationClasses).backIndicatorImage = Image.backButton.image
            UINavigationBar.appearance(whenContainedInInstancesOf: allNavigationClasses).backIndicatorTransitionMaskImage = Image.backButton.image
            UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: ColorPalette.darkGrayTextColor]
            UISearchBar.appearance().searchTextPositionAdjustment = UIOffset(horizontal: 8, vertical: 0)
            UITextField.appearance().textColor = ColorPalette.grayTextColor
            UITextField.appearance().tintColor = ColorPalette.mainColor
            UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedStringKey.font.rawValue: UIFont.systemFont()]
            UITextView.appearance().textColor = ColorPalette.grayTextColor
            UITextView.appearance().tintColor = ColorPalette.mainColor
            UITabBar.appearance().barTintColor = ColorPalette.tabBarBackgroundColor
            UITabBar.appearance().selectedImageTintColor = ColorPalette.mainColor
            UITabBar.appearance().isTranslucent = false
            UITableView.appearance().separatorColor = ColorPalette.tableViewSeparatorColor
            UISwitch.appearance().onTintColor = ColorPalette.switchColor
        }
        
        // MARK: Properties
        
        private let window: UIWindow
    }
}

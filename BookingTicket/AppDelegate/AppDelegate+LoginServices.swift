//
//  AppDelegate+LoginServices.swift
//  BookingTicket
//
//  Created by anhthu on 12/1/17.
//  Copyright © 2017 anhthu. All rights reserved.
//

import RxSwift
import YapDatabase
import Foundation
import UIKit

extension AppDelegate {
    final class LoginStatusService: NSObject, AppDelegateService {
        typealias SignInData = (account: UserAccount, info: AuthenticatedInfo?)
        
        init(window: UIWindow) {
            self.window = window
            super.init()
            NotificationCenter.default.addObserver(self, selector: #selector(signedOut), name: .didSignOut, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(authenticated), name: .didAuthenticate, object: nil)
        }
        
        func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
            if loggedIn, let account = UserAccount.get() {
                signedIn(account: account)
            } else {
                showOnboarding()
            }
            return true
        }
        
        private func signedIn(account: UserAccount, info: AuthenticatedInfo? = nil) {
            window.rootViewController = MainTabBarController()
            handleUnauthorizedUser()

            let data = (account, info)
            NotificationCenter.default.post(name: .didSignIn, data: data)
        }
        
        @objc private func signedOut() {
            
        }
        
        private func showOnboarding() {
            let onboardingController = OnboardingViewController()
            window.rootViewController = onboardingController
        }
        
        private func createRootViewController(account: UserAccount) -> UIViewController {
            let tabController = MainTabBarController()
            return tabController
        }
        
        
        @objc private func authenticated(notification: NSNotification) {
            guard let info = notification.data as? AuthenticatedInfo else { return }
            let account = UserAccount(id: info.profile.id,
                                      name: info.profile.email,
                                      email: info.profile.email,
                                      token: info.mobileToken)
            do {
                try account.save()
            } catch {
                return
            }
            
            DispatchQueue.main.async {
                self.signedIn(account: account, info: info)
            }
        }
        
        private func handleUnauthorizedUser() {
            
        }
        
        // MARK: Properties
        
        private let window: UIWindow
        private let disposeBag = DisposeBag()
    }
}

extension NSNotification.Name {
    static let didSignIn    = NSNotification.Name("didSignIn")
    static let didSignOut   = NSNotification.Name("didSignOut")
}

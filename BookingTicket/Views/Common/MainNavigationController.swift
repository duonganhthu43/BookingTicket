//
//  MainNavigationController.swift
//  BookingTicket
//
//  Created by anhthu on 11/30/17.
//  Copyright © 2017 anhthu. All rights reserved.
//

import Foundation
import UIKit
import PureLayout

final class MainNavigationController: NavigationController {
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        let navBar = navigationBar
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        navBar.isTranslucent = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if let v = viewController as? CustomNavigationBarController {
            let navBar: UIView
            if let borderColor = v.navigationBarBorderColor {
                let borderView = BorderView()
                borderView.borders = .bottom
                borderView.borderColor = borderColor
                navBar = borderView
            }
            else {
                navBar = UIView()
            }
            navBar.backgroundColor = v.navigationBarBackgroundColor
            v.contentView.addSubview(navBar)
            
            NSLayoutConstraint.autoCreateAndInstallConstraints {
                navBar.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
            }
            if #available(iOS 11.0, *) {
                navBar.bottomAnchor.constraint(equalTo: v.contentView.safeAreaLayoutGuide.topAnchor).isActive = true
            } else {
                navBar.autoSetDimension(.height, toSize: 64)
            }
        }
        topViewController?.hideBackButtonTitleWhenPush()
        setNavigationBarStyle(for: viewController)
        super.pushViewController(viewController, animated: animated)
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        let vc = super.popViewController(animated: animated)
        setNavigationBarStyle(for: viewControllers.last!)
        return vc
    }
    
    override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        let vcs = super.popToViewController(viewController, animated: animated)
        setNavigationBarStyle(for: viewControllers.last!)
        return vcs
    }
    
    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        let vcs = super.popToRootViewController(animated: animated)
        setNavigationBarStyle(for: viewControllers.last!)
        return vcs
    }
    
    private func setNavigationBarStyle(for viewController: UIViewController) {
        if viewController.preferredStatusBarStyle == .lightContent {
            navigationBar.tintColor = UIColor.white
            navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        }
        else {
            navigationBar.tintColor = nil
            navigationBar.titleTextAttributes = [.foregroundColor: ColorPalette.darkGrayTextColor]
        }
    }
}

protocol CustomNavigationBarController {
    var contentView: UIView { get }
    var navigationBarBackgroundColor: UIColor { get }
    var navigationBarBorderColor: UIColor? { get }
}

extension CustomNavigationBarController where Self: UIViewController {
    var contentView: UIView {
        return view
    }
    
    var navigationBarBackgroundColor: UIColor {
        return preferredStatusBarStyle == .lightContent ? ColorPalette.mainColor : ColorPalette.whiteNavigationBarColor
    }
    
    var navigationBarBorderColor: UIColor? {
        return preferredStatusBarStyle == .lightContent ? nil : ColorPalette.whiteNavigationBarBorderColor
    }
}

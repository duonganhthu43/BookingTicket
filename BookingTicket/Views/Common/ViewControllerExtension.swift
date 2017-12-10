//
//  ViewControllerExtension.swift
//  BookingTicket
//
//  Created by anhthu on 11/30/17.
//  Copyright © 2017 anhthu. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

func dismissViewController(_ controller: UIViewController, animated: Bool) {
    if controller.isBeingDismissed || controller.isBeingPresented {
        DispatchQueue.main.async {
            dismissViewController(controller, animated: animated)
        }
        return
    }
    if controller.presentingViewController != nil {
        controller.dismiss(animated: animated, completion: nil)
    }
}


extension UIViewController {
    func hideBackButtonTitleWhenPush() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    func createCloseButtonIfIsRoot(left: Bool = false) {
        guard left && navigationItem.leftBarButtonItem == nil || !left && navigationItem.rightBarButtonItem == nil else {
            return
        }
        if navigationController?.viewControllers.count == 1 {
            let closeButton = UIBarButtonItem(title: NSLocalizedString("Close", comment: ""), style: .plain, target: self, action: #selector(_closeButtonTapped))
            if left {
                navigationItem.leftBarButtonItem = closeButton
            }
            else {
                navigationItem.rightBarButtonItem = closeButton
            }
        }
    }
    
    func createCancelButton(title: String = NSLocalizedString("Cancel", comment: "")) -> UIBarButtonItem {
        return UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(_closeButtonTapped))
    }
    //add _ to make sure it does not conflict with instance methods
    @objc private func _closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}

extension UIViewController {
    func popToViewController<T: UIViewController>(with type: T.Type, animated: Bool) {
        if let rootVC = navigationController?.viewControllers.first(where: { $0 is T }) {
            navigationController?.popToViewController(rootVC, animated: animated)
        }
        else {
            navigationController?.popToRootViewController(animated: animated)
        }
    }
}

extension UIViewController {
    var topAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return view.safeAreaLayoutGuide.topAnchor
        } else {
            return topLayoutGuide.bottomAnchor
        }
    }
    
    var bottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return view.safeAreaLayoutGuide.bottomAnchor
        } else {
            return bottomLayoutGuide.topAnchor
        }
    }
}


extension UIViewController {
    static var topMostController: UIViewController {
        var topController = rootViewController
        while let controller = topController.presentedViewController {
            topController = controller
        }
        return topController
    }
    
    static var rootViewController: UIViewController {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let window = appDelegate.window!
        return window.rootViewController!
    }
    
    static func dismissAllModalControllers() {
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: false, completion: nil)
    }
}

enum MessageBoxStyle {
    case toast
    case alertBox
}

extension UIViewController {
    func presentError(_ error: Error, messageBoxStyle: MessageBoxStyle = .alertBox, completion: (() -> Void)? = nil) {
        if (error as NSError).code == NSURLErrorNotConnectedToInternet {
            presentNoInternetConnectionError()
            return
        }
        presentError(message: error.localizedDescription, title: title, messageBoxStyle: messageBoxStyle, completion: completion)
    }
    
    func presentNoInternetConnectionError(_ completion: (() -> Void)? = nil) {
        ToastManager.shared.presentNoInternetConnectionError()
        completion?()
    }
    
    func presentError(message: String, title: String? = nil, messageBoxStyle: MessageBoxStyle = .alertBox, messageType: ToastMessageType = .error, completion: ((()) -> Void)? = nil) {
        if case messageBoxStyle = MessageBoxStyle.alertBox {
            _ = Reactive<AlertPopupViewController>.present(parent: UIViewController.topMostController) {
                $0.title = title
                $0.message = message
                $0.mainButtonTitle = NSLocalizedString("OK", comment: "")
                $0.showCancelButton = false
                }
                .filter { $0 }
                .map { _ in }
                .subscribe(onNext: completion)
        }
        else {
            ToastManager.shared.presentAnimated(message: message, messageType: messageType)
            completion?(())
        }
    }
}

//
//  SegueManager.swift
//  BookingTicket
//
//  Created by anhthu on 11/30/17.
//  Copyright © 2017 anhthu. All rights reserved.
//

import Foundation
import UIKit

class SegueManager {
    typealias Handler = (UIStoryboardSegue) -> Void
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func performSegue(_ identifier: String, handler: @escaping Handler) {
        handlers[identifier] = handler
        timers[identifier] = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(SegueManager.timeout(_:)), userInfo: identifier, repeats: false)
        viewController.performSegue(withIdentifier: identifier, sender: viewController)
    }
    
    func performSegue<T>(_ identifier: String, handler: @escaping (T) -> Void) {
        performSegue(identifier) { segue in
            if let vc: T = self.viewControllerOfType(segue.destination) {
                handler(vc)
            }
            else {
                let message = "Error when performing segue '\(identifier)', "
                    + "received type: '\(type(of: segue.destination))', "
                    + "expected type: '\(T.self)'."
                fatalError(message)
            }
        }
    }
    
    func performSegue(_ identifier: String) {
        viewController.performSegue(withIdentifier: identifier, sender: viewController)
    }
    
    func prepareForSegue(_ segue: UIStoryboardSegue) {
        if let segueIdentifier = segue.identifier {
            timers[segueIdentifier]?.invalidate()
            timers.removeValue(forKey: segueIdentifier)
            
            if let handler = handlers[segueIdentifier] {
                handler(segue)
                handlers.removeValue(forKey: segueIdentifier)
            }
        }
    }
    
    @objc private func timeout(_ timer: Timer) {
        fatalError("Forgot to call SegueManager.prepareForSegue?")
    }
    
    private func viewControllerOfType<T>(_ viewController: UIViewController?) -> T? {
        if let vc = viewController as? T {
            return vc
        }
        else if let vc = viewController as? UINavigationController {
            return viewControllerOfType(vc.visibleViewController)
        }
        else if let vc = viewController as? UITabBarController {
            return viewControllerOfType(vc.viewControllers?.first)
        }
        return nil
    }
    
    //MARK: Properties
    
    private unowned let viewController: UIViewController
    private var handlers = [String: Handler]()
    private var timers = [String: Timer]()
}

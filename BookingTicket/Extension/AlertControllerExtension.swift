//
//  AlertControllerExtension.swift
//  BookingTicket
//
//  Created by anhthu on 12/10/17.
//  Copyright © 2017 anhthu. All rights reserved.
//

import UIKit

extension UIAlertController {
    func addAction(_ title: String, style: UIAlertActionStyle = .default, handler: (() -> Void)? = nil) {
        let action = UIAlertAction(title: title, style: style) { _ in
            handler?()
        }
        addAction(action)
    }
    
    func addCancelAction(_ title: String = NSLocalizedString("Cancel", comment: ""), handler: (() -> Void)? = nil) {
        addAction(title, style: .cancel, handler: handler)
    }
}

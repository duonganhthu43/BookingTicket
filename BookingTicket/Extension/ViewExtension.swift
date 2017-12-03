//
//  ViewExtension.swift
//  BookingTicket
//
//  Created by anhthu on 12/2/17.
//  Copyright © 2017 anhthu. All rights reserved.
//

import UIKit

enum BorderType {
    case bottom
    case top
}

extension UIView {
    func dropShadow() {
        layer.shadowColor   = UIColor.black.cgColor
        layer.shadowOffset  = CGSize(width: 0, height: 1)
        layer.shadowOpacity = 0.2
        layer.shadowRadius  = 0.6
    }
}

extension UIView {
    @discardableResult
    func addBorder(_ width: CGFloat, color: UIColor, type: BorderType) -> CALayer {
        let border = CALayer()
        border.borderWidth = width
        border.borderColor = color.withAlphaComponent(0.4).cgColor
        border.frame = CGRect(x: 0, y: type == .bottom ? frame.height - width : 0, width: frame.width, height: width)
        layer.addSublayer(border)
        return border
    }
}

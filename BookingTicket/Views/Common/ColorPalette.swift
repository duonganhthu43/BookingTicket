//
//  ColorPalette.swift
//  BookingTicket
//
//  Created by anhthu on 12/1/17.
//  Copyright © 2017 anhthu. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(_ red: Int, _ green: Int, _ blue: Int) {
        self.init(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: 1.0)
    }
}

struct ColorPalette {
    static let backGroundColor_Pink = UIColor(250,80,140)
    static let backGroundColor_Yellow = UIColor(255,200,110)
    static let mainColor = UIColor(patternImage: UIImage.gradientBackgroundImage())
    static let mainLightColor = UIColor(73, 207, 224)
    static let greenColor = UIColor(177, 207, 56)
    static let tabBarBackgroundColor = UIColor(251, 251, 250)
    static let searchBarBackgroundColor = UIColor(248, 248, 247)
    static let lightGrayTextColor = UIColor.lightGray
    static let grayTextColor = UIColor.gray
    static let darkGrayTextColor = UIColor.darkGray
    static let destructiveColor = UIColor(255, 59, 48)
    static let switchColor = UIColor(177, 207, 56)
    static let indicatorColor = mainColor
    static let statusTitleColor = UIColor(126, 138, 146)
    static let whiteNavigationBarColor = UIColor(white: 0.97, alpha: 1)
    static let whiteNavigationBarBorderColor = tableViewSeparatorColor
    static let grayBackgroundColor = UIColor(237, 240, 240)
    static let darkGrayBackgroundColor = UIColor(190, 196, 200)
    static let disabledBackgroundColor = UIColor(white: 0.95, alpha: 1)
    
    static let tableViewGroupedBackgroundColor = UIColor(242, 242, 242)
    static let tableViewSeparatorColor = UIColor(white: 0.8, alpha: 1)
    
    static let collectionCellSelectionColor = UIColor(white: 0.95, alpha: 1)
    
    static let profileDetailBorderColor = UIColor(white: 1, alpha: 0.5)
    
    static let successColor = UIColor(red: 0.7, green: 0.82, blue: 0.22, alpha: 1)
    static let errorColor = UIColor(red: 1.0, green: 0.33, blue: 0.34, alpha: 1)
    static let warningColor = UIColor(red: 0.35, green: 0.41, blue: 0.45, alpha: 1)
    static let disabledColor = UIColor(207, 212, 215)
    static let cancelTextColor = UIColor(165, 173, 179)
    
    static let wizardCellBackgroundColor = UIColor(white: 1, alpha: 0.12)
    static let wizardCellHightlightedBackgroundColor = UIColor(white: 1, alpha: 0.05)
    static let wizardCellSelectedBackgroundColor = UIColor(white: 1, alpha: 0.3)
    static let wizardPlaceholderColor = UIColor(white: 1, alpha: 0.5)
}


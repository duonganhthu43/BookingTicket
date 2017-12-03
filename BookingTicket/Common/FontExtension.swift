//
//  FontExtension.swift
//  BookingTicket
//
//  Created by anhthu on 12/1/17.
//  Copyright © 2017 anhthu. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {
    static let awake: Void = {
        swizzle()
    }()
    
    private static func swizzle() {
        let regularOriginalSelector = #selector(self.systemFont(ofSize:))
        let regularSwizzledSelector = #selector(my_systemFontOfSize(_:))
        let regularOriginalMethod = class_getClassMethod(self, regularOriginalSelector)
        let regularSwizzledMethod = class_getClassMethod(self, regularSwizzledSelector)
        method_exchangeImplementations(regularOriginalMethod!, regularSwizzledMethod!)
        
        let boldOriginalSelector = #selector(self.boldSystemFont(ofSize:))
        let boldSwizzledSelector = #selector(my_boldSystemFontOfSize(_:))
        let boldOriginalMethod = class_getClassMethod(self, boldOriginalSelector)
        let boldSwizzledMethod = class_getClassMethod(self, boldSwizzledSelector)
        method_exchangeImplementations(boldOriginalMethod!, boldSwizzledMethod!)
        
        let preferredFontOriginalSelector = #selector(preferredFont(forTextStyle:))
        let preferredFontSwizzledSelector = #selector(my_preferredFontForTextStyle(_:))
        let preferredFontOriginalMethod = class_getClassMethod(self, preferredFontOriginalSelector)
        let preferredFontSwizzledMethod = class_getClassMethod(self, preferredFontSwizzledSelector)
        method_exchangeImplementations(preferredFontOriginalMethod!, preferredFontSwizzledMethod!)
        
        let sizeOriginalSelector = #selector(getter: systemFontSize)
        let sizeSwizzledSelector = #selector(my_systemFontSize)
        let sizeOriginalMethod = class_getClassMethod(self, sizeOriginalSelector)
        let sizeSwizzledMethod = class_getClassMethod(self, sizeSwizzledSelector)
        method_exchangeImplementations(sizeOriginalMethod!, sizeSwizzledMethod!)
        
        let smallSizeOriginalSelector = #selector(getter: smallSystemFontSize)
        let smallSizeSwizzledSelector = #selector(my_smallSystemFontSize)
        let smallSizeOriginalMethod = class_getClassMethod(self, smallSizeOriginalSelector)
        let smallSizeSwizzledMethod = class_getClassMethod(self, smallSizeSwizzledSelector)
        method_exchangeImplementations(smallSizeOriginalMethod!, smallSizeSwizzledMethod!)
    }
}

extension UIFont {
    private static let regularFontName = "ProximaNova-Regular"
    private static let boldFontName = "ProximaNova-Semibold"
    private static let lightFontName = "ProximaNova-Light"
    
    static func systemFont() -> UIFont {
        return self.systemFont(ofSize: systemFontSize)
    }
    static func boldSystemFont() -> UIFont {
        return self.boldSystemFont(ofSize: systemFontSize)
    }
    
    static func bigSystemFont() -> UIFont {
        return self.systemFont(ofSize: 18)
    }
    static func bigBoldSystemFont() -> UIFont {
        return self.boldSystemFont(ofSize: 18)
    }
    static func bigLightSystemFont() -> UIFont {
        return self.lightSystemFont(ofSize: 18)
    }
    
    static func smallSystemFont() -> UIFont {
        return self.systemFont(ofSize: smallSystemFontSize)
    }
    static func smallBoldSystemFont() -> UIFont {
        return self.boldSystemFont(ofSize: smallSystemFontSize)
    }
    
    static func extraSmallSystemFont() -> UIFont {
        return self.systemFont(ofSize: 10)
    }
    
    static func lightSystemFont(ofSize fontSize: CGFloat) -> UIFont {
        return UIFont(name: lightFontName, size: fontSize)!
    }
    
    static func tableViewCellTitleFont() -> UIFont {
        return boldSystemFont()
    }
    static func tableViewCellDetailFont() -> UIFont {
        return systemFont()
    }
    
    @objc private class func my_systemFontOfSize(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: regularFontName, size: fontSize)!
    }
    
    @objc private class func my_boldSystemFontOfSize(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: boldFontName, size: fontSize)!
    }
    
    @objc private class func my_preferredFontForTextStyle(_ style: UIFontTextStyle) -> UIFont {
        switch style {
        case UIFontTextStyle.footnote:
            return UIFont(name: regularFontName, size: smallSystemFontSize)!
        default:
            return UIFont(name: regularFontName, size: systemFontSize)!
        }
    }
    
    @objc private class func my_systemFontSize() -> CGFloat {
        return 15
    }
    @objc private class func my_smallSystemFontSize() -> CGFloat {
        return 13
    }
}

extension UIFont {
    func bold() -> UIFont {
        return UIFont.boldSystemFont(ofSize: pointSize)
    }
    
    func italic() -> UIFont {
        return UIFont.italicSystemFont(ofSize: pointSize)
    }
}

extension UIFont {
    static func tableViewHeaderFont() -> UIFont {
        return UIFont.systemFont(ofSize: 12)
    }
    
    static func profileCardNameFont() -> UIFont {
        return UIFont.systemFont(ofSize: 20)
    }
    
    static func profileCardTitleFont() -> UIFont {
        return UIFont.boldSystemFont(ofSize: 10)
    }
}

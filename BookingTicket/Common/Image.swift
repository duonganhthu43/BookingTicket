//
//  Image.swift
//  BookingTicket
//
//  Created by anhthu on 12/1/17.
//  Copyright © 2017 anhthu. All rights reserved.
//

import Foundation
import UIKit
enum Image : String {
    case mainIcon
    case background
    case backButton
    case camera
    case roundedButtonBackgroundLine
    case error, errorBig, success, warning, removeSmall, clear
    case dashboard, departure, destination, calendar
}
extension Image {
    var image: UIImage {
        switch self {
        case .roundedButtonBackgroundLine:
            let image =  UIImage.roundedImage(cornerRadius: 22, borderWidth: 2, borderColor: UIColor.black, size: CGSize(width: 44, height: 44))
            return image.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 22, bottom: 0, right: 22), resizingMode: .stretch).withRenderingMode(.alwaysTemplate)
        default:
            return UIImage(named: rawValue)!
        }
    }
}

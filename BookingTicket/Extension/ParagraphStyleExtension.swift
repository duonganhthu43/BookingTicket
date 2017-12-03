//
//  ParagraphStyleExtension.swift
//  BookingTicket
//
//  Created by anhthu on 12/2/17.
//  Copyright © 2017 anhthu. All rights reserved.
//

import UIKit
extension NSParagraphStyle {
    static func adjustedLineHeightParagraphStyle(_ lineSpacing: CGFloat = 4, alignment: NSTextAlignment = .left) -> NSMutableParagraphStyle {
        let ps = NSMutableParagraphStyle()
        ps.lineSpacing = lineSpacing
        ps.alignment = alignment
        return ps
    }
}

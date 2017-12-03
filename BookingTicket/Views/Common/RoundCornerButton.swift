//
//  RoundCornerButton.swift
//  BookingTicket
//
//  Created by anhthu on 12/2/17.
//  Copyright © 2017 anhthu. All rights reserved.
//

import Foundation
import UIKit

final class RoundCornerButton : UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        layer.borderWidth = 1
        setTitleColor(ColorPalette.mainColor, for: [])
        setTitleColor(ColorPalette.lightGrayTextColor, for: .disabled)
        layer.borderColor = ColorPalette.mainColor.cgColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
        layer.borderColor = isEnabled ? ColorPalette.mainColor.cgColor : ColorPalette.lightGrayTextColor.cgColor
        alpha = isEnabled ? 1 : 0.4
    }
}

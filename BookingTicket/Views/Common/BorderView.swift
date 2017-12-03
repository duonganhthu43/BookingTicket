//
//  BorderView.swift
//  BookingTicket
//
//  Created by anhthu on 12/1/17.
//  Copyright © 2017 anhthu. All rights reserved.
//

import UIKit

struct Border: OptionSet {
    init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    let rawValue: Int
    
    static let top          = Border(rawValue: 1 << 0)
    static let right        = Border(rawValue: 1 << 1)
    static let bottom       = Border(rawValue: 1 << 2)
    static let left         = Border(rawValue: 1 << 3)
    static let all: Border  = [.top, .right, .bottom, .left]
}

enum BorderWidthUnit {
    case pixel
    case point
}

class BorderView: UIView {
    convenience init(borders: Border = .all, borderColor: UIColor? = nil) {
        self.init(frame: CGRect.zero)
        self.borders = borders
        self.borderColor = borderColor
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        contentMode = .redraw
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let color = tintAdjustmentMode == .dimmed && borderColor != nil && borderColor != UIColor.white ? UIColor.lightGray : borderColor
        color?.set()
        
        let lineWidth = renderBorderWidth
        context.setLineWidth(lineWidth)
        let offset = lineWidth / 2
        if borders.contains(.top) {
            context.move(to: CGPoint(x: 0, y: offset))
            context.addLine(to: CGPoint(x: bounds.width, y: offset))
            context.strokePath()
        }
        if borders.contains(.right) {
            context.move(to: CGPoint(x: bounds.width - offset, y: 0))
            context.addLine(to: CGPoint(x: bounds.width - offset, y: bounds.height))
            context.strokePath()
        }
        if borders.contains(.bottom) {
            context.move(to: CGPoint(x: 0, y: bounds.height - offset))
            context.addLine(to: CGPoint(x: bounds.width, y: bounds.height - offset))
            context.strokePath()
        }
        if borders.contains(.left) {
            context.move(to: CGPoint(x: offset, y: 0))
            context.addLine(to: CGPoint(x: offset, y: bounds.height))
            context.strokePath()
        }
    }
    
    //MARK: Properties
    
    var borderColor: UIColor? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var borderWidth: CGFloat = 1 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var renderBorderWidth: CGFloat {
        return borderWidthUnit == .pixel ? borderWidth / UIScreen.main.scale : borderWidth
    }
    
    var borders: Border = .all {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var borderWidthUnit: BorderWidthUnit = .pixel {
        didSet {
            setNeedsDisplay()
        }
    }
}

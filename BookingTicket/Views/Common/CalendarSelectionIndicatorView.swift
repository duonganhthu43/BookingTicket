//
//  CalendarSelectionIndicatorView.swift
//  BookingTicket
//
//  Created by anhthu on 12/4/17.
//  Copyright © 2017 anhthu. All rights reserved.
//

import Foundation
import UIKit
final class CalendarSelectionIndicatorView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        if case .none = style {
            return
        }
        
        if let context = UIGraphicsGetCurrentContext() {
            context.saveGState()
            
            switch style {
            case let .left(color, filled):
                setColor(color, filled: filled, context: context)
                
                if filled {
                    let size = CGSize(width: bounds.height / 2, height: bounds.height / 2)
                    let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.topLeft, .bottomLeft], cornerRadii: size)
                    path.fill()
                }
                else {
                    let radius = (bounds.height - 2) / 2
                    context.move(to: CGPoint(x: bounds.maxX, y: 1))
                    context.addArc(tangent1End: CGPoint(x: 1, y: 1), tangent2End: CGPoint(x: 1, y: bounds.height / 2), radius: radius)
                    context.addArc(tangent1End: CGPoint(x: 1, y: bounds.maxY - 1), tangent2End: CGPoint(x: bounds.maxX, y: bounds.maxY - 1), radius: radius)
                    context.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY - 1))
                    context.strokePath()
                }
                
            case let .middle(color, filled):
                setColor(color, filled: filled, context: context)
                
                if filled {
                    context.fill(bounds)
                }
                else {
                    context.move(to: CGPoint(x: 0, y: 1))
                    context.addLine(to: CGPoint(x: bounds.maxX, y: 1))
                    context.strokePath()
                    context.move(to: CGPoint(x: 0, y: bounds.maxY - 1))
                    context.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY - 1))
                    context.strokePath()
                }
                
            case let .right(color, filled):
                setColor(color, filled: filled, context: context)
                
                if filled {
                    let size = CGSize(width: bounds.height / 2, height: bounds.height / 2)
                    let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.topRight, .bottomRight], cornerRadii: size)
                    path.fill()
                }
                else {
                    let radius = (bounds.height - 2) / 2
                    context.move(to: CGPoint(x: 0, y: 1))
                    context.addArc(tangent1End: CGPoint(x: bounds.maxX - 1, y: 1), tangent2End: CGPoint(x: bounds.maxX - 1, y: bounds.height / 2), radius: radius)
                    context.addArc(tangent1End: CGPoint(x: bounds.maxX - 1, y: bounds.maxY - 1), tangent2End: CGPoint(x: 0, y: bounds.maxY - 1), radius: radius)
                    context.addLine(to: CGPoint(x: 0, y: bounds.maxY - 1))
                    context.strokePath()
                }
                
            case let .single(color, filled):
                setColor(color, filled: filled, context: context)
                
                if filled {
                    context.fillEllipse(in: bounds)
                }
                else {
                    context.strokeEllipse(in: bounds.insetBy(dx: 1, dy: 1))
                }
                
            case .none:
                break
            }
            
            context.restoreGState()
        }
    }
    
    private func setColor(_ color: UIColor, filled: Bool, context: CGContext) {
        if filled {
            color.setFill()
        }
        else {
            color.setStroke()
            context.setLineWidth(1)
        }
    }
    
    var style: CalendarCellSelectionStyle = .none {
        didSet {
            setNeedsDisplay()
        }
    }
}

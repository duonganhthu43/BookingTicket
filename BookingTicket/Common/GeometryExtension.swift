//
//  GeometryExtension.swift
//  BookingTicket
//
//  Created by anhthu on 12/1/17.
//  Copyright © 2017 anhthu. All rights reserved.
//
import CoreGraphics
import Foundation
import UIKit

enum RectHorizontalAlignment {
    case left(inset: CGFloat)
    case right(inset: CGFloat)
}
enum RectVerticalAlignment {
    case top(inset: CGFloat)
    case bottom(inset: CGFloat)
}

extension CGRect {
    func dividePadding(_ distance: CGFloat, padding: CGFloat, fromEdge edge: CGRectEdge) -> (slice: CGRect, remainder: CGRect) {
        let rects1 = divided(atDistance: distance, from: edge)
        let rects2 = rects1.remainder.divided(atDistance: padding, from: edge)
        return (rects1.slice, rects2.remainder)
    }
    
    mutating func growInPlace(fromInsets insets: UIEdgeInsets) {
        growInPlace(left: insets.left, right: insets.right, top: insets.top, bottom: insets.bottom)
    }
    func growFrom(_ insets: UIEdgeInsets) -> CGRect {
        var newRect = self
        newRect.growInPlace(fromInsets: insets)
        return newRect
    }
    
    mutating func growInPlace(left: CGFloat = 0, right: CGFloat = 0, top: CGFloat = 0, bottom: CGFloat = 0) {
        origin.x -= left
        origin.y -= top
        size.width += left + right
        size.height += top + bottom
    }
    func growWith(left: CGFloat = 0, right: CGFloat = 0, top: CGFloat = 0, bottom: CGFloat = 0) -> CGRect {
        var newRect = self
        newRect.growInPlace(left: left, right: right, top: top, bottom: bottom)
        return newRect
    }
    
    mutating func insetInPlace(_ insets: UIEdgeInsets) {
        insetInPlace(left: insets.left, right: insets.right, top: insets.top, bottom: insets.bottom)
    }
    func insetBy(_ insets: UIEdgeInsets) -> CGRect {
        var newRect = self
        newRect.insetInPlace(insets)
        return newRect
    }
    
    mutating func insetInPlace(_ insets: CGFloat) {
        insetInPlace(left: insets, right: insets, top: insets, bottom: insets)
    }
    func insetBy(_ insets: CGFloat) -> CGRect {
        var newRect = self
        newRect.insetInPlace(insets)
        return newRect
    }
    
    mutating func insetInPlace(left: CGFloat = 0, right: CGFloat = 0, top: CGFloat = 0, bottom: CGFloat = 0) {
        origin.x += left
        origin.y += top
        size.width -= left + right
        size.height -= top + bottom
    }
    func insetWith(top: CGFloat = 0, right: CGFloat = 0, bottom: CGFloat = 0, left: CGFloat = 0) -> CGRect {
        var newRect = self
        newRect.insetInPlace(left: left, right: right, top: top, bottom: bottom)
        return newRect
    }
    
    mutating func offsetInPlace(dx: CGFloat, dy: CGFloat) {
        self = offsetBy(dx: dx, dy: dy)
    }
    
    //TODO rename
    mutating func centerInPlaceWith(_ rect: CGRect, horizontal: Bool, vertical: Bool) {
        if horizontal {
            origin.x = rect.origin.x + (rect.width - width) / 2
        }
        if vertical {
            origin.y = rect.origin.y + (rect.height - height) / 2
        }
    }
    func centerWith(_ rect: CGRect, horizontal: Bool, vertical: Bool) -> CGRect {
        var newRect = self
        newRect.centerInPlaceWith(rect, horizontal: horizontal, vertical: vertical)
        return newRect
    }
    
    mutating func alignInPlaceWith(_ rect: CGRect, horizontal: RectHorizontalAlignment, vertical: RectVerticalAlignment) {
        switch horizontal {
        case .left(let inset):
            origin.x = rect.minX + inset
        case .right(let inset):
            origin.x = rect.maxX - inset - width
        }
        
        switch vertical {
        case .top(let inset):
            origin.y = rect.minY + inset
        case .bottom(let inset):
            origin.y = rect.maxY - inset - height
        }
    }
    func alignWith(_ rect: CGRect, horizontal: RectHorizontalAlignment, vertical: RectVerticalAlignment) -> CGRect {
        var newRect = self
        newRect.alignInPlaceWith(rect, horizontal: horizontal, vertical: vertical)
        return newRect
    }
}

extension CGRect {
    enum Corner {
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
    }
    
    mutating func anchorInPlaceToCorner(_ corner: Corner, of rect: CGRect, withSize targetSize: CGSize = CGSize.zero, xOffset: CGFloat = 0, yOffset: CGFloat = 0) {
        if targetSize != CGSize.zero {
            size = targetSize
        }
        
        var xOrigin: CGFloat = 0
        var yOrigin: CGFloat = 0
        
        switch corner {
        case .topLeft:
            xOrigin = rect.minX + xOffset
            yOrigin = rect.minY + yOffset
            
        case .topRight:
            xOrigin = rect.maxX - size.width - xOffset
            yOrigin = rect.minY + yOffset
            
        case .bottomLeft:
            xOrigin = rect.minX + xOffset
            yOrigin = rect.maxY - size.height - yOffset
            
        case .bottomRight:
            xOrigin = rect.maxX - size.width - xOffset
            yOrigin = rect.maxY - size.height - yOffset
        }
        
        origin = CGPoint(x: xOrigin, y: yOrigin)
    }
    func anchorToCorner(_ corner: Corner, of rect: CGRect, withSize targetSize: CGSize = CGSize.zero, xOffset: CGFloat = 0, yOffset: CGFloat = 0) -> CGRect {
        var newRect = self
        newRect.anchorInPlaceToCorner(corner, of: rect, withSize: targetSize, xOffset: xOffset, yOffset: yOffset)
        return newRect
    }
}

extension CGRect {
    var innerSquare: CGRect {
        guard width != height else { return self }
        var rect = self
        rect.size.width = min(width, height)
        rect.size.height = rect.size.width
        rect.centerInPlaceWith(self, horizontal: true, vertical: true)
        return rect
    }
}

extension CGSize {
    var integral: CGSize {
        return CGSize(width: ceil(width), height: ceil(height))
    }
    
    func sizeAspectFill(minSize: CGSize, maxSize: CGSize) -> CGSize {
        var finalSize = self
        if finalSize.width > maxSize.width || finalSize.height > maxSize.height {
            let scale = max(finalSize.width / maxSize.width, finalSize.height / maxSize.height)
            finalSize.width = width / scale
            finalSize.height = height / scale
        }
        
        if finalSize.width < minSize.width || finalSize.height < minSize.height {
            let scale = min(finalSize.width / minSize.width, finalSize.height / minSize.height)
            finalSize.width = finalSize.width / scale
            finalSize.height = finalSize.height / scale
        }
        return finalSize
    }
}

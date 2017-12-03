//
//  ImageExtension.swift
//  BookingTicket
//
//  Created by anhthu on 12/2/17.
//  Copyright © 2017 anhthu. All rights reserved.
//

import ImageIO
import Accelerate
import UIKit

extension UIImage {
    func imageByResizingToSize(_ size: CGSize) -> UIImage {
        guard let data = UIImageJPEGRepresentation(self, 1) else {
            return self
        }
        if let imageSource = CGImageSourceCreateWithData(data as CFData, nil) {
            let options: [NSString: Any] = [
                kCGImageSourceThumbnailMaxPixelSize: max(size.width, size.height),
                kCGImageSourceCreateThumbnailFromImageIfAbsent: true,
                kCGImageSourceCreateThumbnailWithTransform: true
            ]
            if let cgImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary?) {
                return UIImage(cgImage: cgImage)
            }
        }
        return self
    }
    
    func imageAspectScaledToFillSize(_ size: CGSize) -> UIImage {
        guard size.width < self.size.width || size.height < self.size.height else {
            return self
        }
        let imageAspectRatio = self.size.width / self.size.height
        let canvasAspectRatio = size.width / size.height
        
        var resizeFactor: CGFloat
        
        if imageAspectRatio > canvasAspectRatio {
            resizeFactor = size.height / self.size.height
        }
        else {
            resizeFactor = size.width / self.size.width
        }
        
        let scaledSize = CGSize(width: self.size.width * resizeFactor, height: self.size.height * resizeFactor)
        let origin = CGPoint(x: (size.width - scaledSize.width) / 2.0, y: (size.height - scaledSize.height) / 2.0)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        draw(in: CGRect(origin: origin, size: scaledSize))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage ?? self
    }
    
    func imageWithAlpha(_ alpha: CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0)
        defer {
            UIGraphicsEndImageContext()
        }
        
        guard let graphicsContext = UIGraphicsGetCurrentContext(), let cgImage = self.cgImage else {
            return UIImage()
        }
        
        let area = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        
        graphicsContext.scaleBy(x: 1, y: -1)
        graphicsContext.translateBy(x: 0, y: -area.size.height)
        graphicsContext.setBlendMode(CGBlendMode.multiply)
        graphicsContext.setAlpha(alpha)
        graphicsContext.draw(cgImage, in: area)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        return newImage ?? self
    }
    
    func thumbnail(size: CGSize = CGSize(width: 100, height: 100)) -> UIImage {
        let scale = max(size.width / self.size.width, size.height / self.size.height)
        let width = self.size.width * scale
        let height = self.size.height * scale
        let x = (size.width - width) / CGFloat(2)
        let y = (size.height - height) / CGFloat(2)
        let thumbnailRect = CGRect(x: x, y: y, width: width, height: height)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        self.draw(in: thumbnailRect)
        let thumbnail = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return thumbnail ?? UIImage()
    }
    
    static func imageWithColor(_ color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
    
    static func searchBarBackground() -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 44)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        
        ColorPalette.searchBarBackgroundColor.setFill()
        UIRectFill(rect)
        
        ColorPalette.tableViewSeparatorColor.setFill()
        let scale = UIScreen.main.scale
        let lineWidth = 1 / scale
        var rects = rect.divided(atDistance: lineWidth, from: .minYEdge)
        UIRectFill(rects.slice)
        
        rects = rect.divided(atDistance: lineWidth, from: .maxYEdge)
        UIRectFill(rects.slice)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
    
    static func roundedImage(cornerRadius: CGFloat = 4, borderWidth: CGFloat = 1, borderColor: UIColor, backgroundColor: UIColor? = nil, size: CGSize = CGSize.zero) -> UIImage {
        var correctSize = size
        if correctSize == CGSize.zero {
            correctSize = CGSize(width: cornerRadius * 2, height: cornerRadius * 2)
        }
        UIGraphicsBeginImageContextWithOptions(correctSize, false, 0)
        
        let scale = UIScreen.main.scale
        let lineWidth = borderWidth / scale
        let rect = CGRect(x: 0, y: 0, width: correctSize.width, height: correctSize.height)
        let path = UIBezierPath(roundedRect: rect.insetBy(dx: lineWidth / 2, dy: lineWidth / 2), cornerRadius: cornerRadius)
        path.lineWidth = lineWidth
        borderColor.setStroke()
        (backgroundColor ?? UIColor.clear).setFill()
        path.fill()
        path.stroke()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
    
    static func roundedImage(cornerRadius: CGFloat = 4, byRoundingCorners roundingCorners: UIRectCorner = .allCorners, backgroundColor: UIColor, size: CGSize = CGSize.zero) -> UIImage {
        var correctSize = size
        if correctSize == CGSize.zero {
            correctSize = CGSize(width: cornerRadius * 2, height: cornerRadius * 2)
        }
        UIGraphicsBeginImageContextWithOptions(correctSize, false, 0)
        
        let rect = CGRect(x: 0, y: 0, width: correctSize.width, height: correctSize.height)
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: roundingCorners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        backgroundColor.setFill()
        path.fill()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
    
    static func gradientBackgroundImage() -> UIImage {
        let bounds = UIScreen.main.bounds
        let size = bounds.size
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer {
            UIGraphicsEndImageContext()
        }
        
        guard let currentContext = UIGraphicsGetCurrentContext() else {
            return UIImage()
        }
        
        drawGradientFromStartPoint(CGPoint(x: 0, y: 0), toEndPoint: CGPoint(x: size.width, y: size.height), bounds: bounds, context: currentContext)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        return image ?? UIImage()
    }
    
    static func gradientBackgroundImageWithSize(_ size: CGSize) -> UIImage {
        let bgImage = gradientBackgroundImage()
        let scale = UIScreen.main.scale
        let rect = CGRect(x: 0, y: 0, width: size.width * scale, height: size.height * scale)
        guard let cgImage = bgImage.cgImage, let imageRef = cgImage.cropping(to: rect) else {
            return bgImage
        }
        let image = UIImage(cgImage: imageRef, scale: bgImage.scale, orientation: bgImage.imageOrientation)
        return image
    }
    
    private static func drawGradientFromStartPoint(_ startPoint: CGPoint, toEndPoint endPoint: CGPoint, bounds: CGRect, context: CGContext) {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let startColor = UIColor(250, 80, 140)
        let endColor = UIColor(255, 200, 110)
        let startColorComponents = startColor.cgColor.components!
        let endColorComponents = endColor.cgColor.components!
        var colorComponents = [startColorComponents[0], startColorComponents[1], startColorComponents[2], startColorComponents[3], endColorComponents[0], endColorComponents[1], endColorComponents[2], endColorComponents[3]]
        var locations: [CGFloat] = [0.0, 0.8]
        let gradient = CGGradient(colorSpace: colorSpace, colorComponents: &colorComponents, locations: &locations, count: 2)
        context.setFillColor(endColor.cgColor)
        context.fill(bounds)
        context.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: [])
    }
}

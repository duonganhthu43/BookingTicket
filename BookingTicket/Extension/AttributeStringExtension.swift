//
//  AttributeStringExtension.swift
//  BookingTicket
//
//  Created by anhthu on 12/10/17.
//  Copyright © 2017 anhthu. All rights reserved.
//

import Foundation
import UIKit
private protocol Element {
    var regex: NSRegularExpression { get }
    
    func process(result: NSTextCheckingResult, in attributedString: NSMutableAttributedString, configuration: NSAttributedString.FormatConfiguration)
}

extension Element {
    func parse(attributedString: NSMutableAttributedString, configuration: NSAttributedString.FormatConfiguration) {
        var location = 0
        while let regexMatch = regex.firstMatch(in: attributedString.string,
                                                options: .withoutAnchoringBounds,
                                                range: NSRange(location: location,
                                                               length: attributedString.length - location))
        {
            let oldLength = attributedString.length
            process(result: regexMatch, in: attributedString, configuration: configuration)
            let newLength = attributedString.length
            location = regexMatch.range.location + regexMatch.range.length + newLength - oldLength
        }
    }
}

private struct BoldElement: Element {
    static let regex = try! NSRegularExpression(pattern: "(\\s+|^)(\\*\\*|__)(.+?)(\\2)", options: [])
    
    var regex: NSRegularExpression {
        return BoldElement.regex
    }
    
    func process(result: NSTextCheckingResult, in attributedString: NSMutableAttributedString, configuration: NSAttributedString.FormatConfiguration) {
        attributedString.deleteCharacters(in: result.range(at: 4))
        attributedString.addAttribute(.font, value: configuration.font.bold(), range: result.range(at: 3))
        if let color = configuration.boldColor {
            attributedString.addAttribute(.foregroundColor, value: color, range: result.range(at: 3))
        }
        attributedString.deleteCharacters(in: result.range(at: 2))
    }
}

private struct ItalicElement: Element {
    static let regex = try! NSRegularExpression(pattern: "(\\s+|^)(\\*|_)(.+?)(\\2)", options: [])
    
    var regex: NSRegularExpression {
        return ItalicElement.regex
    }
    
    func process(result: NSTextCheckingResult, in attributedString: NSMutableAttributedString, configuration: NSAttributedString.FormatConfiguration) {
        attributedString.deleteCharacters(in: result.range(at: 4))
        attributedString.addAttribute(.font, value: configuration.font.italic(), range: result.range(at: 3))
        if let color = configuration.italicColor {
            attributedString.addAttribute(.foregroundColor, value: color, range: result.range(at: 3))
        }
        attributedString.deleteCharacters(in: result.range(at: 2))
    }
}

private struct LinkElement: Element {
    static let regex = try! NSRegularExpression(pattern: "\\[([^\\[]*?)\\]\\(([^\\)]*)\\)", options: [])
    
    var regex: NSRegularExpression {
        return LinkElement.regex
    }
    
    func process(result: NSTextCheckingResult, in attributedString: NSMutableAttributedString, configuration: NSAttributedString.FormatConfiguration) {
        let nsString = attributedString.string as NSString
        let titleRange = result.range(at: 1)
        let title = nsString.substring(with: titleRange)
        let linkRange = result.range(at: 2)
        let link = nsString.substring(with: linkRange)
        attributedString.replaceCharacters(in: result.range, with: title)
        var range = titleRange
        range.location = result.range.location
        attributedString.addAttribute(.link, value: link, range: range)
        attributedString.addAttribute(.font, value: configuration.font.bold(), range: range)
    }
}

// MARK: - NSAttributedString extension

extension NSAttributedString {
    struct FormatConfiguration {
        init(font: UIFont = UIFont.systemFont(), alignment: NSTextAlignment = .left, color: UIColor? = nil, boldColor: UIColor? = nil, italicColor: UIColor? = nil) {
            self.font = font
            self.alignment = alignment
            self.color = color
            self.boldColor = boldColor
            self.italicColor = italicColor
        }
        
        let font: UIFont
        let alignment: NSTextAlignment
        let color: UIColor?
        let boldColor: UIColor?
        let italicColor: UIColor?
    }
    
    private static var elements: [Element] {
        return [BoldElement(), ItalicElement(), LinkElement()]
    }
    
    static func fromFormat(_ format: String, configuration: FormatConfiguration) -> NSAttributedString {
        var attributes: [NSAttributedStringKey: Any] = [.font: configuration.font,
                                                        .paragraphStyle: NSParagraphStyle.adjustedLineHeightParagraphStyle(alignment: configuration.alignment)]
        if let color = configuration.color {
            attributes[.foregroundColor] = color
        }
        let string = NSMutableAttributedString(string: format, attributes: attributes)
        elements.forEach {
            $0.parse(attributedString: string, configuration: configuration)
        }
        return string.copy() as! NSAttributedString
    }
    
    static func fromFormat(_ format: String, font: UIFont = UIFont.systemFont()) -> NSAttributedString {
        let configuration = FormatConfiguration(font: font)
        return fromFormat(format, configuration: configuration)
    }
}

extension NSAttributedString {
    func adjustedLineHeight(alignment: NSTextAlignment = .left) -> NSAttributedString {
        let mutable = mutableCopy() as! NSMutableAttributedString
        let range = NSRange(location: 0, length: length)
        mutable.addAttribute(.paragraphStyle,
                             value: NSParagraphStyle.adjustedLineHeightParagraphStyle(alignment: alignment),
                             range: range)
        return mutable.copy() as! NSAttributedString
    }
}

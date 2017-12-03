//
//  StringExtension.swift
//  BookingTicket
//
//  Created by anhthu on 12/2/17.
//  Copyright © 2017 anhthu. All rights reserved.
//

import Foundation
import UIKit
public extension String {
    public func trim() -> String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    public var isEmptyOrWhiteSpace: Bool {
        return isEmpty || trim().isEmpty
    }
    
    public var isValidEmail: Bool {
        guard !isEmpty && count < 101 else {
            return true
        }
        let pattern = "^[a-zA-Z0-9][-\\._+a-zA-Z0-9]*@[a-zA-Z0-9][-\\._a-zA-Z0-9]*\\.([a-zA-Z]{2,10})$"
        if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
            return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
        }
        return false
    }
    
    public func formattingPhoneNumber() -> String {
        guard !isEmptyOrWhiteSpace else { return "" }
        let regex = try! NSRegularExpression(pattern: "([a-z]+\\s*)?(.+)", options: .caseInsensitive)
        let nsString = self as NSString
        let matches = regex.matches(in: self, options: [], range: NSRange(location: 0, length: nsString.length))
        guard !matches.isEmpty else { return self }
        let range = matches[0].range(at: 2)
        return nsString.substring(with: range)
    }
    
    public func normalizedString() -> String {
        let result: NSMutableString = (self as NSString).mutableCopy() as! NSMutableString
        CFStringNormalize(result, .D)
        CFStringFold(result, [.compareCaseInsensitive, .compareDiacriticInsensitive, .compareWidthInsensitive], nil)
        return result.copy() as! String
    }
    
    public func base64EncodingString() -> String {
        let data = self.data(using: String.Encoding.utf8)
        return data?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0)) ?? ""
    }
    
    public func urlEncoded() -> String {
        return addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? self
    }
    
    public func widthWithAttributes(_ attributes: [NSAttributedStringKey: Any]) -> CGFloat {
        return (self as NSString).boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: attributes, context: nil).width
    }
    
    public func escapeLikePattern() -> String {
        return replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "%", with: "\\%")
            .replacingOccurrences(of: "_", with: "\\_")
    }
    
    public func truncate(maxLength: Int, ellipsis: Bool) -> String {
        let ns = self as NSString
        guard maxLength >= 0 && ns.length > maxLength else {
            return self
        }
        let truncated = ns.substring(to: ellipsis ? maxLength - 3 : maxLength)
        return ellipsis ? truncated + "..." : truncated
    }
    
    public func searchTerms() -> [String] {
        if !isEmptyOrWhiteSpace {
            let phrase = trim()
            return phrase.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        }
        return []
    }
    
    public func detectURLs() -> [String] {
        guard !isEmptyOrWhiteSpace else { return [] }
        var urls: [String] = []
        if let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) {
            let range = NSRange(location: 0, length: (self as NSString).length)
            detector.enumerateMatches(in: self, options: [], range: range) { result, _, stop in
                guard let result = result else { return }
                guard let url = result.url, let scheme = url.scheme, scheme.caseInsensitiveCompare("http") == .orderedSame || scheme.caseInsensitiveCompare("https") == .orderedSame else { return }
                urls.append(url.absoluteString.lowercased())
            }
        }
        return urls
    }
    
    public func ns_containsString(_ other: String, options: NSString.CompareOptions) -> Bool {
        return (self as NSString).range(of: other, options: options).location != NSNotFound
    }
    
    public func validate(pattern: String) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let range = NSMakeRange(0, utf16.count)
            let checkingResult = regex.firstMatch(in: self, options: .anchored, range: range)
            guard let result = checkingResult else { return false }
            return result.range.location != NSNotFound
        } catch {
            return false
        }
    }
    
    public func adjustedLineHeight(_ lineSpacing: CGFloat = 4, alignment: NSTextAlignment = .left) -> NSAttributedString {
        let ps = NSParagraphStyle.adjustedLineHeightParagraphStyle(lineSpacing, alignment: alignment)
        ps.lineBreakMode = .byTruncatingTail
        return NSAttributedString(string: self, attributes: [.paragraphStyle: ps])
    }
}

public extension Character {
    public func isEmoji() -> Bool {
        return Character(UnicodeScalar(0x1d000)!) <= self && self <= Character(UnicodeScalar(0x1f9ff)!)
            || Character(UnicodeScalar(0x2100)!) <= self && self <= Character(UnicodeScalar(0x27bf)!)
    }
}

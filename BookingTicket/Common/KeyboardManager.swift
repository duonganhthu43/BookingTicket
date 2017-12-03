//
//  KeyboardManager.swift
//  BookingTicket
//
//  Created by anhthu on 12/2/17.
//  Copyright © 2017 anhthu. All rights reserved.
//

import RxSwift
import RxCocoa
import UIKit

struct KeyboardManager {
    struct KeyboardTransitionInfo {
        let frame: CGRect
        let duration: Double
        let options: UIViewAnimationOptions
    }
    
    static var willShow: Driver<KeyboardTransitionInfo> {
        return NotificationCenter.default.rx.notification(.UIKeyboardWillShow).map {
            KeyboardManager.getTransitionInfo(from: $0)
            }.asDriver(onErrorJustReturn: KeyboardTransitionInfo.empty)
    }
    
    static var didShow: Driver<KeyboardTransitionInfo> {
        return NotificationCenter.default.rx.notification(.UIKeyboardDidShow).map {
            KeyboardManager.getTransitionInfo(from: $0)
            }.asDriver(onErrorJustReturn: KeyboardTransitionInfo.empty)
    }
    
    static var willHide: Driver<KeyboardTransitionInfo> {
        return NotificationCenter.default.rx.notification(.UIKeyboardWillHide).map {
            KeyboardManager.getTransitionInfo(from: $0)
            }.asDriver(onErrorJustReturn: KeyboardTransitionInfo.empty)
    }
    
    static var didHide: Driver<KeyboardTransitionInfo> {
        return NotificationCenter.default.rx.notification(.UIKeyboardDidHide).map {
            KeyboardManager.getTransitionInfo(from: $0)
            }.asDriver(onErrorJustReturn: KeyboardTransitionInfo.empty)
    }
    
    private static func getTransitionInfo(from notification: Foundation.Notification) -> KeyboardTransitionInfo {
        guard let userInfo = notification.userInfo else {
            return KeyboardTransitionInfo.empty
        }
        let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? CGRect.zero
        let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? Double ?? 0
        let rawAnimationCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? Int ?? 0
        let animationCurve = UIViewAnimationOptions(rawValue: UInt(rawAnimationCurve))
        return KeyboardTransitionInfo(frame: keyboardFrame, duration: duration, options: animationCurve)
    }
}

extension KeyboardManager.KeyboardTransitionInfo {
    fileprivate static var empty: KeyboardManager.KeyboardTransitionInfo {
        return KeyboardManager.KeyboardTransitionInfo(frame: CGRect.zero, duration: 0, options: [])
    }
}

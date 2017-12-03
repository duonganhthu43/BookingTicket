//
//  Toast.swift
//  BookingTicket
//
//  Created by anhthu on 12/2/17.
//  Copyright © 2017 anhthu. All rights reserved.
//

import Foundation
import UIKit
import PureLayout
import RxCocoa
import RxSwift

typealias TapAction = () -> Void
private struct LayoutMetrics {
    static let dismissButtonSize = CGSize(width: 44, height: 44)
    static let iconSize = CGSize(width: 44, height: 44)
    static let verticalPadding: CGFloat = 15
    static let topMargin: CGFloat = 20
}

private final class ToastViewController: UIViewController {
    fileprivate override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    fileprivate override var prefersStatusBarHidden: Bool {
        return false
    }
    
    fileprivate override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

private final class Toast: UIWindow {
    init(message: NSAttributedString, messageType: ToastMessageType = .error, autoDismissAfter: Double? = 0, uniqueKey: String? = nil, tapAction: TapAction? = nil, dismissCompletion: ((Toast) -> Void)? = nil) {
        self.messageType = messageType
        self.tapAction = tapAction
        self.autoDismissAfter = autoDismissAfter
        self.dismissCompletion = dismissCompletion
        messageLabel = UILabel()
        self.uniqueKey = uniqueKey
        super.init(frame: CGRect.zero)
        rootViewController = ToastViewController()
        backgroundColor = messageType.backgroudColor
        
        let containerView = UIView()
        rootViewController?.view?.addSubview(containerView)
        
        let icon = UIImageView(image: messageType.image)
        icon.contentMode = .center
        icon.tintColor = UIColor.white
        containerView.addSubview(icon)
        
        messageLabel.attributedText = message
        messageLabel.textColor = UIColor.white
        messageLabel.lineBreakMode = .byWordWrapping
        messageLabel.numberOfLines = 0
        containerView.addSubview(messageLabel)
        
        let dismissButton = UIButton(type: .system)
        dismissButton.setImage(Image.removeSmall.image, for: [])
        dismissButton.tintColor = UIColor.white
        dismissButton.addTarget(self, action: #selector(dismissButtonTapped), for: .touchUpInside)
        containerView.addSubview(dismissButton)
        
        NSLayoutConstraint.autoCreateAndInstallConstraints {
            containerView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: LayoutMetrics.topMargin, left: 0, bottom: 0, right: 0))
            
            icon.autoAlignAxis(toSuperviewAxis: .horizontal)
            icon.autoPinEdge(toSuperviewEdge: .leading)
            icon.autoSetDimensions(to: LayoutMetrics.iconSize)
            
            dismissButton.autoAlignAxis(toSuperviewAxis: .horizontal)
            dismissButton.autoSetDimension(.width, toSize: LayoutMetrics.dismissButtonSize.width)
            dismissButton.autoMatch(.height, to: .height, of: containerView)
            dismissButton.autoPinEdge(toSuperviewEdge: .trailing)
            
            messageLabel.autoAlignAxis(toSuperviewAxis: .horizontal)
            messageLabel.autoPinEdge(.leading, to: .trailing, of: icon)
            messageLabel.autoPinEdge(.trailing, to: .leading, of: dismissButton)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandling(_:)))
        addGestureRecognizer(tapGesture)
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeGestureHandling(_:)))
        swipeGesture.direction = .up
        addGestureRecognizer(swipeGesture)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override fileprivate func layoutSubviews() {
        super.layoutSubviews()
        let width = frame.width - LayoutMetrics.dismissButtonSize.width - LayoutMetrics.iconSize.width
        let labelSize = messageLabel.sizeThatFits(CGSize(width: width, height: UIScreen.main.bounds.height))
        
        // Auto increase height of the window if the message displays multiple lines
        let expectHeight = labelSize.height + 2 * LayoutMetrics.verticalPadding + LayoutMetrics.topMargin
        if frame.height < expectHeight {
            frame.size.height = expectHeight
        }
    }
    
    //MARK: Properties
    
    private let messageType: ToastMessageType
    private let tapAction: TapAction?
    private var animating = false
    private let autoDismissAfter: Double?
    private var dismissCompletion: ((Toast) -> Void)? = nil
    private let messageLabel: UILabel
    let uniqueKey: String?
    
    //MARK: Public
    
    func presentAnimated(_ animated: Bool) {
        guard !animating else { return }
        animating = true
        isHidden = false
        
        var feedbackGenerator: Any? = nil
        if #available(iOS 10.0, *) {
            feedbackGenerator = UINotificationFeedbackGenerator()
            (feedbackGenerator as? UINotificationFeedbackGenerator)?.prepare()
        }
        
        let completion = {
            self.animating = false
            if let delay = self.autoDismissAfter, delay > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    self.dismiss(animated)
                }
            }
        }
        
        guard animated else {
            completion()
            return
        }
        
        transform = CGAffineTransform(translationX: 0, y: -frame.height)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            self.transform = CGAffineTransform.identity
        }, completion: { _ in
            completion()
            
            if #available(iOS 10.0, *) {
                let type: UINotificationFeedbackType = self.messageType == .success ? .success : .error
                (feedbackGenerator as? UINotificationFeedbackGenerator)?.notificationOccurred(type)
            }
        })
    }
    
    func dismiss(_ animated: Bool, completion: (() -> Void)? = nil) {
        guard !animating else { return }
        
        let completeAction = {
            self.removeFromSuperview()
            self.isHidden = true
            self.dismissCompletion?(self)
            completion?()
        }
        
        guard animated else {
            completeAction()
            return
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            self.transform = CGAffineTransform(translationX: 0, y: -self.frame.height)
        }, completion: { _ in
            completeAction()
        })
    }
    
    //MARK: Gestures & events
    
    @objc private func tapGestureHandling(_ gesture: UITapGestureRecognizer) {
        dismiss(true) {
            self.tapAction?()
        }
    }
    
    @objc private func swipeGestureHandling(_ gesture: UISwipeGestureRecognizer) {
        dismiss(true)
    }
    
    @objc private func dismissButtonTapped() {
        dismiss(true)
    }
}

enum ToastMessageType {
    case error
    case warning
    case success
    
    var backgroudColor: UIColor {
        switch self {
        case .error:
            return ColorPalette.errorColor
        case .success:
            return ColorPalette.successColor
        case .warning:
            return ColorPalette.warningColor
        }
    }
    
    var image: UIImage? {
        switch self {
        case .error:
            return Image.error.image
        case .success:
            return Image.success.image
        case .warning:
            return Image.warning.image
        }
    }
}

final class ToastManager {
    private var windows = [Toast]()
    
    func presentAnimated(message: String, messageType: ToastMessageType = .error, animated: Bool = true, autoDismissAfter: Double? = 5, uniqueKey: String? = nil, tapAction: TapAction? = nil) {
        let message = NSAttributedString(string: message, attributes: [.font: UIFont.smallSystemFont()])
        presentAnimated(message: message, messageType: messageType, animated: animated, autoDismissAfter: autoDismissAfter, uniqueKey: uniqueKey, tapAction: tapAction)
    }
    
    func presentAnimated(format: String, messageType: ToastMessageType = .error, animated: Bool = true, autoDismissAfter: Double? = 5, uniqueKey: String? = nil, tapAction: TapAction? = nil) {
        presentAnimated(message: format, messageType: messageType, animated: animated, autoDismissAfter: autoDismissAfter, uniqueKey: uniqueKey, tapAction: tapAction)
    }
    
    private func presentAnimated(message: NSAttributedString, messageType: ToastMessageType, animated: Bool, autoDismissAfter: Double?, uniqueKey: String?, tapAction: TapAction?) {
        if let uniqueKey = uniqueKey, windows.contains(where: { t -> Bool in t.uniqueKey == uniqueKey }) {
            return
        }
        let toast = Toast(message: message, messageType: messageType, autoDismissAfter: autoDismissAfter, uniqueKey: uniqueKey, tapAction: tapAction) { toast in
            let item = self.windows.enumerated().filter { $0.element == toast }.first
            if let item = item {
                self.windows.remove(at: item.offset)
            }
        }
        toast.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 64)
        toast.layoutIfNeeded()
        toast.presentAnimated(animated)
        windows.append(toast)
    }
    
    func presentAnimated(error: Error) {
        presentAnimated(error: error, animated: true)
    }
    
    func presentAnimated(error: Error, animated: Bool = true, autoDismissAfter: Double? = 3, uniqueKey: String? = nil, tapAction: TapAction? = nil) {
        if (error as NSError).code == NSURLErrorNotConnectedToInternet {
            return presentNoInternetConnectionError()
        }
        presentAnimated(message: error.localizedDescription,
                        messageType: ToastMessageType.error,
                        animated: animated,
                        autoDismissAfter: autoDismissAfter,
                        uniqueKey: uniqueKey,
                        tapAction: tapAction)
    }
    
    func presentNoInternetConnectionError() {
        presentAnimated(message: NSLocalizedString("No Internet Connection.", comment: ""),
                        messageType: .warning,
                        uniqueKey: "NetworkError.noInternetConnection")
    }
    
    func dismissAll(_ animated: Bool) {
        windows.forEach { $0.dismiss(animated) }
    }
    
    func dismiss(forKey key: String, animated: Bool) {
        windows.filter { $0.uniqueKey == key }.forEach { $0.dismiss(animated) }
    }
    
    static let shared = ToastManager()
}

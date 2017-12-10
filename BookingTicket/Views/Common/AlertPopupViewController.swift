//
//  AlertPopupViewController.swift
//  BookingTicket
//
//  Created by anhthu on 12/10/17.
//  Copyright © 2017 anhthu. All rights reserved.
//

import Foundation
import UIKit
@objc protocol AlertPopupViewControllerDelegate: class {
    @objc optional func alertPopupViewControllerDidTapMainButton(_ controller: AlertPopupViewController)
    @objc optional func alertPopupViewControllerDidCancel(_ controller: AlertPopupViewController)
}

class AlertPopupViewController: PopupViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if showIcon {
            let imageView = UIImageView(image: image ?? Image.errorBig.image)
            imageView.tintColor = ColorPalette.darkGrayBackgroundColor
            addView(imageView)
            addSpace(height: 1)
        }
        
        if attributeTitle?.string.isEmpty == false || title?.isEmpty == false {
            let label = addLabel(text: " ")
            label.attributedText = attributeTitle?.adjustedLineHeight(alignment: .center) ?? title?.adjustedLineHeight(alignment: .center)
            label.font = UIFont.boldSystemFont()
            titleLabel = label
            
            addSpace(height: 1)
        }
        
        if let message = attributedMessage, !message.string.isEmpty {
            messageLabel = addLabel(attributedText: message.adjustedLineHeight(alignment: .center))
            addSpace(height: 1)
        }
        else if let message = message, !message.isEmpty {
            messageLabel = addLabel(attributedText: message.adjustedLineHeight(alignment: .center))
            addSpace(height: 1)
        }
        
        let buttonStyle: ButtonStyle = destructiveMainButton ? .destructive : .default
        let button = addButton(text: mainButtonTitle ?? NSLocalizedString("OK", comment: ""), style: buttonStyle)
        mainButton = button
        button
            .rx.tap.subscribe(onNext: { [weak self] in
                self?.mainButtonTapped()
            })
            .disposed(by: disposeBag)
        
        if showCancelButton {
            let button = addButton(text: cancelButtonTitle ?? NSLocalizedString("Cancel", comment: ""), style: .cancel)
            cancelButton = button
            button
                .rx.tap.subscribe(onNext: { [weak self] in
                    self?.cancelButtonTapped()
                })
                .disposed(by: disposeBag)
        }
        else {
            addSpace(height: 8)
        }
    }
    
    func mainButtonTapped() {
        if alwaysOpen {
            delegate?.alertPopupViewControllerDidTapMainButton?(self)
            return
        }
        dismiss(animated: true) {
            self.delegate?.alertPopupViewControllerDidTapMainButton?(self)
        }
    }
    
    func cancelButtonTapped() {
        if alwaysOpen {
            delegate?.alertPopupViewControllerDidCancel?(self)
            return
        }
        dismiss(animated: true) {
            self.delegate?.alertPopupViewControllerDidCancel?(self)
        }
    }
    
    // MARK: Properties
    
    override var spacing: CGFloat {
        return 7
    }
    
    override var leftRightMargin: CGFloat {
        return 40
    }
    
    weak var delegate: AlertPopupViewControllerDelegate?
    var attributeTitle: NSAttributedString?
    var message: String?
    var attributedMessage: NSAttributedString?
    var mainButtonTitle: String?
    var cancelButtonTitle: String?
    var image: UIImage?
    var destructiveMainButton = false
    var showCancelButton = true
    var alwaysOpen = false
    var showIcon = true
    
    private(set) var titleLabel: UILabel?
    private(set) var messageLabel: UILabel?
    private(set) var mainButton: UIButton?
    private(set) var cancelButton: UIButton?
}

//MARK: - UIViewControllerTransitioningDelegate

extension AlertPopupViewController {
    override func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AlertAnimatedTransitioning(isPresentation: true)
    }
    
    override func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AlertAnimatedTransitioning(isPresentation: false)
    }
}

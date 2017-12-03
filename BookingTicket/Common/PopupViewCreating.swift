//
//  PopupViewCreating.swift
//  BookingTicket
//
//  Created by anhthu on 12/2/17.
//  Copyright © 2017 anhthu. All rights reserved.
//

import Foundation
import UIKit

protocol PopupViewControllerSpacing {
    var leftRightMargin: CGFloat { get }
    var topBottomMargin: CGFloat { get }
}

protocol PopupViewCreating: class {
    func addView(_ view: UIView)
    func registerCancelButtonHandler(for button: UIButton)
    var textAlignment: NSTextAlignment { get }
}

extension PopupViewCreating {
    var textAlignment: NSTextAlignment {
        return .center
    }
    
    func registerCancelButtonHandler(for button: UIButton) {
        
    }
    
    @discardableResult
    func addHeaderLabel(text: String) -> UILabel {
        let label = createHeaderLabel()
        label.text = text
        addView(label)
        return label
    }
    func createHeaderLabel() -> UILabel {
        let label = createLabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = ColorPalette.darkGrayTextColor
        return label
    }
    
    @discardableResult
    func addLabel(text: String?) -> UILabel {
        let label = createLabel()
        label.text = text
        addView(label)
        return label
    }
    
    @discardableResult
    func addLabel(attributedText: NSAttributedString?) -> UILabel {
        let label = createLabel()
        label.attributedText = attributedText
        addView(label)
        return label
    }
    
    func createLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont()
        label.textColor = UIColor.white
        label.numberOfLines = 0
        label.textAlignment = textAlignment
        label.textColor = ColorPalette.grayTextColor
        return label
    }
    
    @discardableResult
    func addCancelButton(text: String = NSLocalizedString("Cancel", comment: "")) -> UIButton {
        let button = addButton(text: text, style: .cancel)
        registerCancelButtonHandler(for: button)
        return button
    }
    
    @discardableResult
    func addButton(text: String, style: ButtonStyle = .`default`) -> UIButton {
        let button = createButton(style: style)
        button.setTitle(text, for: [])
        addView(button)
        NSLayoutConstraint.autoCreateAndInstallConstraints {
            button.autoPinEdge(toSuperviewEdge: .leading)
            button.autoPinEdge(toSuperviewEdge: .trailing)
        }
        return button
    }
    
    func createButton(style: ButtonStyle = .`default`) -> UIButton {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont.boldSystemFont()
        button.autoSetDimension(.height, toSize: 44)
        button.setTitleColor(ColorPalette.disabledColor, for: .disabled)
        
        switch style {
        case .`default`, .destructive:
            button.setBackgroundImage(Image.roundedButtonBackgroundLine.image, for: [])
            
        case .cancel:
            button.setTitleColor(ColorPalette.cancelTextColor, for: [])
            
        case .none:
            break
        }
        
        if style == .destructive {
            button.tintColor = ColorPalette.destructiveColor
        }
        
        return button
    }
    
    func addSpace(height: CGFloat) {
        guard height > 0 else { return }
        let view = UIView()
        addView(view)
        view.autoSetDimension(.height, toSize: height)
    }
    
    func createStackView(spacing: CGFloat, axis: UILayoutConstraintAxis = .vertical) -> UIStackView {
        let stackView = UIStackView()
        stackView.spacing = spacing
        stackView.axis = axis
        stackView.alignment = .fill
        return stackView
    }
}

enum ButtonStyle {
    case `default`
    case destructive
    case cancel
    case none
}

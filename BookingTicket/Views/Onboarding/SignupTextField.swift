//
//  SignupTextField.swift
//  BookingTicket
//
//  Created by anhthu on 12/1/17.
//  Copyright © 2017 anhthu. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class SignUpTextField: TextField {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    private func commonInit() {
        highlightedBorderColor = ColorPalette.mainColor
        normalBorderColor = ColorPalette.lightGrayTextColor
        clearButtonMode = .whileEditing
    }
}

class TextField: UITextField {
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        font = UIFont.systemFont()
    }
    
    //MARK: Delegate forwarder
    
    override func responds(to aSelector: Selector) -> Bool {
        return super.responds(to: aSelector) || realDelegate?.responds(to: aSelector) == true
    }
    
    override func forwardingTarget(for aSelector: Selector) -> Any? {
        return realDelegate?.responds(to: aSelector) == true ? realDelegate : super.forwardingTarget(for: aSelector)
    }
    
    private weak var realDelegate: UITextFieldDelegate?
    override weak var delegate: UITextFieldDelegate? {
        get {
            return realDelegate
        }
        set {
            realDelegate = newValue
        }
    }
    
    //MARK: Properties
    
    var maxLength = 0
    
    var normalBorderColor: UIColor? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var highlightedBorderColor: UIColor? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var invalidBorderColor: UIColor? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var isValid: Bool = true {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var inset: UIEdgeInsets? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func becomeFirstResponder() -> Bool {
        defer {
            setNeedsDisplay()
        }
        return super.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        defer {
            setNeedsDisplay()
        }
        return super.resignFirstResponder()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if isFirstResponder, !isValid, let borderColor = invalidBorderColor {
            drawBorder(borderColor)
        }
        else if !isFirstResponder, let borderColor = normalBorderColor {
            drawBorder(borderColor)
        }
        else if isFirstResponder, let borderColor = highlightedBorderColor ?? normalBorderColor {
            drawBorder(borderColor)
        }
    }
    
    private func drawBorder(_ color: UIColor) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        color.set()
        let lineWidth = 1 / UIScreen.main.scale
        context.setLineWidth(lineWidth)
        let offset = lineWidth / 2
        context.move(to: CGPoint(x: 0, y: bounds.height - offset))
        context.addLine(to: CGPoint(x: bounds.width, y: bounds.height - offset))
        context.strokePath()
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        if textAlignment == .center, let rightView = rightView {
            return bounds.insetBy(dx: rightView.frame.width, dy: 0)
        }
        else if let inset = inset {
            return bounds.insetBy(inset)
        }
        
        return super.textRect(forBounds: bounds)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        if let inset = inset {
            return bounds.insetBy(inset)
        }
        return textRect(forBounds: bounds)
    }
}

final class TextBoxWithActionButton: SignUpTextField {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    private func commonInit() {
        rx.text.orEmpty.subscribe(onNext: { [weak self] input in
            guard let strongSelf = self else { return }
            if strongSelf.actionButton.superview == nil {
                strongSelf.addActionButton()
            }
            strongSelf.actionButton.isHidden = input.isEmpty
        }).disposed(by: disposeBag)
    }
    
    private func addActionButton() {
        guard let superview = superview else { return }
        superview.addSubview(actionButton)
        NSLayoutConstraint.autoCreateAndInstallConstraints({
            actionButton.autoSetDimensions(to: CGSize(width: 44, height: frame.height))
            actionButton.autoPinEdge(.leading, to: .trailing, of: self)
            actionButton.autoPinEdge(.bottom, to: .bottom, of: self)
        })
    }
    
    fileprivate lazy var actionButton: UIButton = {
        let button = UIButton()
        button.setImage(Image.camera.image, for: [])
        button.contentMode = .center
        return button
    }()
    
    private let disposeBag = DisposeBag()
}

extension Reactive where Base: TextBoxWithActionButton {
    var action: Observable<Void> {
        return Observable.merge(base.actionButton.rx.tap.asObservable(), base.rx.returnButtonClicked.asObservable())
    }
}



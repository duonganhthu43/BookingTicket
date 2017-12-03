//
//  TextFieldExtension.swift
//  BookingTicket
//
//  Created by anhthu on 12/3/17.
//  Copyright © 2017 anhthu. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension UITextField {
    func setPrefix(_ prefix: String, padding: CGFloat = 0) {
        let label = UILabel()
        label.font = font
        label.textColor = ColorPalette.grayTextColor
        label.text = prefix
        label.sizeToFit()
        label.frame.size.width += padding
        leftView = label
        leftViewMode = .always
    }
    
    func createCustomClearButton() -> Disposable {
        let clearButton = UIButton(type: .system)
        clearButton.setImage(Image.clear.image, for: [])
        clearButton.alpha = 0.7
        clearButton.frame = CGRect(x: 0, y: 0, width: 20, height: 44)
        rightView = clearButton
        rightViewMode = .whileEditing
        
        let disposable = CompositeDisposable()
        var d = rx.text.orEmpty.asDriver().map { $0.isEmpty }.drive(clearButton.rx.isHidden)
        _ = disposable.insert(d)
        
        d = clearButton.rx.tap.subscribe(onNext: { [weak self] in
            clearButton.isHidden = true
            DispatchQueue.main.async {
                self?.text = nil
                self?.sendActions(for: .valueChanged)
            }
        })
        _ = disposable.insert(d)
        return disposable
    }
}

extension Reactive where Base: UITextField {
    var returnButtonClicked: ControlEvent<Void> {
        return controlEvent(.editingDidEndOnExit)
    }
}


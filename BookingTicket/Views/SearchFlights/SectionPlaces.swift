//
//  Section.swift
//  BookingTicket
//
//  Created by anhthu on 12/3/17.
//  Copyright © 2017 anhthu. All rights reserved.
//

import UIKit
final class SectionPlacesController: ViewController, SectionedChildViewControllerProtocol {
    init() {
        super.init(nibName: nil, bundle: nil)
        title = NSLocalizedString("Choose Places", comment: "")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        view.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20))
        stackView.addArrangedSubview(departure)
        stackView.addArrangedSubview(destination)
        
    }
    private lazy var departure: UIButton = createButton(placeHolder: "Departure", icon: Image.departure.image)
    private lazy var destination: UIButton = createButton(placeHolder: "Destination", icon: Image.destination.image)

    
    private func createButton(placeHolder: String, icon: UIImage?) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(placeHolder, for: .normal)
        button.tintColor = ColorPalette.mainColor
        button.setTitleColor(ColorPalette.lightGrayTextColor, for: .normal)
        button.titleLabel?.font = UIFont.systemFont()
        button.layer.borderWidth = 1
        button.layer.borderColor = ColorPalette.mainColor.cgColor
        button.layer.cornerRadius  = 10
        let iconView = UIImageView()
        iconView.image = icon
        button.addSubview(iconView)
        button.autoSetDimension(.height, toSize: 48)
        iconView.tintColor = ColorPalette.mainColor
        iconView.autoPinEdge(toSuperviewEdge: .left, withInset: 10)
        iconView.autoSetDimensions(to: CGSize(width: 18, height: 18))
        iconView.autoAlignAxis(toSuperviewAxis: .horizontal)
        return button
    }
    
    var titleInsets: UIEdgeInsets {
        let defaultInset = type(of: self).defaultInset
        return UIEdgeInsets(top: 0, left: defaultInset, bottom: defaultInset, right: defaultInset)
    }
    
    var contentInsets: UIEdgeInsets {
        return UIEdgeInsets(top: type(of: self).defaultInset, left: 0, bottom: 0, right: 0)
    }
}


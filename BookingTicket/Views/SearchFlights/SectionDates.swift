//
//  SectionDates.swift
//  BookingTicket
//
//  Created by anhthu on 12/3/17.
//  Copyright © 2017 anhthu. All rights reserved.
//

import Foundation
import UIKit
final class SectionDatesController: ViewController, SectionedChildViewControllerProtocol {
    init() {
        super.init(nibName: nil, bundle: nil)
        title = NSLocalizedString("Choose Dates", comment: "")
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
        // create round trip stack
        let roundTripStack = UIStackView()
        roundTripStack.axis = .horizontal
        roundTripStack.spacing = 20
        roundTripStack.addArrangedSubview(roundTripSwitch)
        roundTripStack.addArrangedSubview(roundTripLabel)
        
        stackView.addArrangedSubview(roundTripStack)
        stackView.addArrangedSubview(departure)
        stackView.addArrangedSubview(destination)
        
        let state  = leaveViewModel.state.asDriver()
        state.map {$0.values.startDate?.mediumDateString}
            .filter{$0 != nil}.drive(departure.rx.title(for: .normal)).disposed(by: disposeBag)
         state.map {$0.values.endDate?.mediumDateString}
            .filter{$0 != nil}.drive(destination.rx.title(for: .normal)).disposed(by: disposeBag)
        roundTripSwitch.rx.isOn.asDriver().map{!$0}.drive(destination.rx.isHidden).disposed(by: disposeBag)
        
    }
    
    private lazy var leaveViewModel: LeaveDatesViewModel = LeaveDatesViewModel(startDate: nil, endDate: nil, roundTrip: roundTripSwitch.rx.isOn.asDriver())
    private lazy var departure: UIButton = createButton(placeHolder: "Fly Out", icon: Image.calendar.image)
    private lazy var destination: UIButton = createButton(placeHolder: "Fly Back", icon: Image.calendar.image)
    private lazy var roundTripSwitch = createSwitch()
    private lazy var roundTripLabel = createSwitchTitle()
    
    
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
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }
    
    var titleInsets: UIEdgeInsets {
        let defaultInset = type(of: self).defaultInset
        return UIEdgeInsets(top: 0, left: defaultInset, bottom: defaultInset, right: defaultInset)
    }
    
    var contentInsets: UIEdgeInsets {
        return UIEdgeInsets(top: type(of: self).defaultInset, left: 0, bottom: 0, right: 0)
    }
    
    func createSwitchTitle() -> UILabel {
        let label = UILabel()
        label.textColor = ColorPalette.darkGrayTextColor
        label.text = "Round trip"
        return label
    }
    
    func createSwitch() -> UISwitch {
        let toggle = UISwitch()
        toggle.onTintColor = ColorPalette.mainColor
        toggle.tintColor = ColorPalette.mainColor
        toggle.isOn = true
        return toggle
    }
    
    @objc private func buttonTapped() {
        let leaveDatesController = SelectDateViewController(viewModel: leaveViewModel)
        navigationController?.pushViewController(leaveDatesController, animated: true)
    }
    
}

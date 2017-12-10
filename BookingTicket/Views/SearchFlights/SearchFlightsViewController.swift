//
//  SearchFlights.swift
//  BookingTicket
//
//  Created by anhthu on 12/2/17.
//  Copyright © 2017 anhthu. All rights reserved.
//

import UIKit
final class SearchFlightViewController: SectionedViewController, CustomNavigationBarController {
    init() {
        super.init(nibName: nil, bundle: nil)
        title = NSLocalizedString("Find Flights", comment: "")
        tabBarItem.image = Image.dashboard.image.withRenderingMode(.alwaysTemplate)
        hidesBottomBarWhenPushed = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var config = SectionItemConfig()
        config.borderColor = ColorPalette.mainColor
        addSectionViewController(placesSection, config: config)
        addSectionViewController(datesSection, config: config)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK Properties
    private lazy var placesSection = SectionPlacesController()
    private lazy var datesSection = SectionDatesController()
    private lazy var searchButton =
    
}

extension SearchFlightViewController {
    private func createSearch() -> UIButton {
        let button = UIButton(type: .system)
        button.setup(backgroundColor: ColorPalette.ma
        )
//        if let rightIcon = rightIcon {
//            button.setImage(rightIcon, for: .normal)
//            button.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
//            button.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
//            button.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
//            button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10)
//        }
        return button
    }
    
}

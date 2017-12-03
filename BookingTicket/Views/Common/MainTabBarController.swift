//
//  MainTabBarController.swift
//  BookingTicket
//
//  Created by anhthu on 12/2/17.
//  Copyright © 2017 anhthu. All rights reserved.
//

import UIKit
import RxSwift

protocol MainTabBarControllerDelegate: class {
    func mainTabBarControllerDidTapOnCurrentItem()
}
final class MainTabBarController: UITabBarController {
    init() {
        super.init(nibName: nil, bundle: nil)
        delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabItems()
    }
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return selectedViewController?.preferredStatusBarStyle ?? .lightContent
    }
    
    func changeSelectedIndex(_ newIndex: Int) {
        guard let viewControllers = viewControllers, viewControllers.count > 0 && viewControllers.count > newIndex else {
            return
        }
        guard newIndex != selectedIndex else {
            return
        }
        selectedIndex = newIndex
        previousController = viewControllers[newIndex]
    }
    
    //MARK: Properties
    
    private weak var previousController: UIViewController?
    private(set) var previousSelectedIndex: Int = 0
    private let disposeBag = DisposeBag()
    weak var tabBarItemDelegate: MainTabBarControllerDelegate?
    
    lazy var searchFlightNavController: UINavigationController = {
        let controller: SearchFlightViewController = SearchFlightViewController()
        let navController = MainNavigationController(rootViewController: controller)
        navController.tabBarItem.title = NSLocalizedString("Flights", comment: "")
        return navController
    }()
}
extension MainTabBarController {
    private func setupTabItems() {
        let viewControllers = [searchFlightNavController]
        for controller in viewControllers {
             controller.tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -5)
        }
        
        self.viewControllers = viewControllers
    }
}

// MARK: - TabBar Controller Delegate

extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        // Scroll to top support
        if previousController == viewController {
            if let navController = viewController as? UINavigationController {
                if navController.viewControllers.count == 1 {
                    scrollToTop(navController.viewControllers[0])
                }
            }
            else {
                scrollToTop(viewController)
            }
            tabBarItemDelegate?.mainTabBarControllerDidTapOnCurrentItem()
        }
        previousSelectedIndex = selectedIndex
        previousController = viewController
        return true
    }
    
    private func scrollToTop(_ viewController: UIViewController) {
        guard viewController.isViewLoaded else { return }
        if let vc = viewController as? UITableViewController {
            vc.scrollViewToRowAtIndexPath(IndexPath(row: 0, section: 0), atScrollPosition: .top, animated: true)
        }
    }
}

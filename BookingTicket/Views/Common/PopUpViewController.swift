//
//  PopUpViewController.swift
//  BookingTicket
//
//  Created by anhthu on 12/10/17.
//  Copyright © 2017 anhthu. All rights reserved.
//

import Foundation
import UIKit

class PopupViewController: ViewController, PopupViewControllerSpacing {
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        transitioningDelegate = self
        modalPresentationStyle = .custom
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        
        wrapperView.backgroundColor = UIColor.white
        wrapperView.layer.cornerRadius = 6
        wrapperView.clipsToBounds = true
        view.addSubview(wrapperView)
        
        stackView.spacing = spacing
        stackView.alignment = .center
        stackView.axis = .vertical
        wrapperView.addSubview(stackView)
        
        NSLayoutConstraint.autoCreateAndInstallConstraints {
            stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 20, left: 20, bottom: 10, right: 20))
            wrapperView.autoPinEdge(toSuperviewEdge: .leading)
            wrapperView.autoPinEdge(toSuperviewEdge: .trailing)
            wrapperView.autoAlignAxis(toSuperviewAxis: .horizontal)
        }
        
        setup()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return presentingViewController?.preferredStatusBarStyle ?? .default
    }
    
    func setup() { }
    
    var leftRightMargin: CGFloat {
        return 25
    }
    
    var topBottomMargin: CGFloat {
        return 30
    }
    
    var spacing: CGFloat {
        return 15
    }
    
    private(set) lazy var wrapperView: UIView = UIView()
    private(set) lazy var stackView: UIStackView = UIStackView()
}

// MARK: UIViewControllerTransitioningDelegate

extension PopupViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return PopupPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PopupAnimatedTransitioning(isPresentation: true)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PopupAnimatedTransitioning(isPresentation: false)
    }
}

extension PopupViewController: PopupViewCreating {
    func registerCancelButtonHandler(for button: UIButton) {
        button.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
    }
    
    func addView(_ view: UIView) {
        stackView.addArrangedSubview(view)
    }
    
    @objc private func didTapCancelButton() {
        dismiss(animated: true, completion: nil)
    }
}

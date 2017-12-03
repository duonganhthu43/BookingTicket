//
//  PopupPresentController.swift
//  BookingTicket
//
//  Created by anhthu on 12/2/17.
//  Copyright © 2017 anhthu. All rights reserved.
//

import UIKit

final class PopupPresentationController: UIPresentationController {
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        dimmingView = UIView()
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        dimmingView.backgroundColor = UIColor(white: 0, alpha: 0.4)
        dimmingView.alpha = 0
    }
    
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        
        if let containerView = containerView {
            presentingViewController.view.tintAdjustmentMode = .dimmed
            
            dimmingView.frame = containerView.bounds
            dimmingView.alpha = 0
            containerView.insertSubview(dimmingView, at: 0)
            
            if let transitionCoordinator = presentedViewController.transitionCoordinator {
                transitionCoordinator.animate(alongsideTransition: { context in
                    self.dimmingView.alpha = 1
                }, completion: nil)
            }
            else {
                dimmingView.alpha = 1
            }
        }
    }
    
    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        presentingViewController.view.tintAdjustmentMode = .automatic
        
        if let transitionCoordinator = presentedViewController.transitionCoordinator {
            transitionCoordinator.animate(alongsideTransition: { context in
                self.dimmingView.alpha = 0
            }, completion: nil)
        }
        else {
            dimmingView.alpha = 0
        }
    }
    
    override var adaptivePresentationStyle : UIModalPresentationStyle {
        return .overFullScreen
    }
    override func adaptivePresentationStyle(for traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .custom
    }
    
    override func containerViewWillLayoutSubviews() {
        if let containerView = containerView {
            dimmingView.frame = containerView.bounds
        }
        if let presentedView = presentedView {
            presentedView.frame = frameOfPresentedViewInContainerView
        }
    }
    
    override var shouldPresentInFullscreen : Bool {
        return true
    }
    
    override var frameOfPresentedViewInContainerView : CGRect {
        var presentedViewFrame = CGRect.zero
        if let containerView = containerView {
            let containerBounds = containerView.bounds
            presentedViewFrame.size = size(forChildContentContainer: presentedViewController, withParentContainerSize: containerBounds.size)
            let leftRight = (presentedViewController as? PopupViewControllerSpacing)?.leftRightMargin ?? 25
            let topBottom = (presentedViewController as? PopupViewControllerSpacing)?.topBottomMargin ?? 30
            presentedViewFrame.insetInPlace(left: leftRight, right: leftRight, top: topBottom, bottom: topBottom)
        }
        return presentedViewFrame
    }
    
    //MARK: Properties
    
    private let dimmingView: UIView
}

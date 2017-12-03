//
//  PopupAnimatedTransitioning.swift
//  BookingTicket
//
//  Created by anhthu on 12/2/17.
//  Copyright © 2017 anhthu. All rights reserved.
//

import Foundation
import UIKit

final class PopupAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    init(isPresentation: Bool, bounce: Bool = true) {
        self.isPresentation = isPresentation
        self.bounce = bounce
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
            let fromView = fromController.view,
            let toView = toController.view else {
                return
        }
        let containerView = transitionContext.containerView
        
        if isPresentation {
            containerView.addSubview(toView)
        }
        
        let animatingController = isPresentation ? toController : fromController
        let animatingView = animatingController.view
        let appearedFrame = transitionContext.finalFrame(for: animatingController)
        var dismissedFrame = appearedFrame
        dismissedFrame.origin.y += dismissedFrame.height + dismissedFrame.origin.x * 2
        
        let initialFrame = isPresentation ? dismissedFrame : appearedFrame
        let finalFrame = isPresentation ? appearedFrame : dismissedFrame
        animatingView?.frame = initialFrame
        
        let duration = transitionDuration(using: transitionContext)
        let options: UIViewAnimationOptions = [isPresentation ? .curveEaseOut : .curveEaseIn]
        let animate: () -> Void = {
            animatingView?.frame = finalFrame
        }
        let completion: (Bool) -> Void = { finished in
            if !self.isPresentation {
                fromView.removeFromSuperview()
            }
            transitionContext.completeTransition(true)
        }
        
        if !bounce {
            UIView.animate(withDuration: duration, delay: 0, options: options, animations: animate, completion: completion)
        }
        else {
            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 1, options: options, animations: animate, completion: completion)
        }
    }
    
    //MARK: Properties
    
    private let isPresentation: Bool
    private let bounce: Bool
}

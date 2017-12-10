//
//  AlertAnimatedTransitioning.swift
//  BookingTicket
//
//  Created by anhthu on 12/10/17.
//  Copyright © 2017 anhthu. All rights reserved.
//

import UIKit

final class AlertAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    init(isPresentation: Bool) {
        self.isPresentation = isPresentation
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
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
        
        if isPresentation {
            animatingView?.frame = transitionContext.finalFrame(for: animatingController)
            animatingView?.alpha = 0
            animatingView?.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.55, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                animatingView?.alpha = 1
                animatingView?.transform = CGAffineTransform.identity
            }, completion: { finished in
                transitionContext.completeTransition(true)
            })
        }
        else {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                animatingView?.alpha = 0
                animatingView?.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            }, completion: { finished in
                if !self.isPresentation {
                    fromView.removeFromSuperview()
                }
                transitionContext.completeTransition(true)
            })
        }
    }
    
    //MARK: Properties
    
    private let isPresentation: Bool
}

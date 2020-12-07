//
//  BounceAnimationController.swift
//
//  Created by JechtSh0t on 8/14/20.
//  Copyright © 2020 Brook Street Games. All rights reserved.
//

import UIKit

///
/// Animates a popover into view by growing past normal size, and then shrinking.
///
final class BounceAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        if let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to), let toView = transitionContext.view(forKey: UITransitionContextViewKey.to) {
            
            let containerView = transitionContext.containerView
            toView.frame = transitionContext.finalFrame(for: toViewController)
            containerView.addSubview(toView)
            
            toView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            
            UIView.animateKeyframes(withDuration: transitionDuration(using: transitionContext), delay: 0, options: .calculationModeCubic, animations: {
                
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5, animations: {
                    toView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                })
                
                UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5, animations: {
                    toView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                })
                
            }, completion: { finished in
                transitionContext.completeTransition(finished)
            })
        }
    }
}

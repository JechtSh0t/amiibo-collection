//
//  FadeOutAnimationController.swift
//
//  Created by JechtSh0t on 8/14/20.
//  Copyright © 2020 Brook Street Games. All rights reserved.
//

import UIKit

///
/// Fades out popover on dismissal.
///
final class FadeOutAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        if let fromView = transitionContext.view( forKey: UITransitionContextViewKey.from) {
            
            let time = transitionDuration(using: transitionContext)
            UIView.animate(withDuration: time, animations: {
                fromView.alpha = 0
            }, completion: { finished in
                transitionContext.completeTransition(finished)
            })
        }
    }
}

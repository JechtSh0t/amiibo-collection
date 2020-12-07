//
//  FadeOutAnimationController.swift
//
//  Created by JechtSh0t on 8/14/20.
//  Copyright © 2020 Brook Street Games. All rights reserved.
//

import UIKit

///
/// Brings gradient into view slowly, during popover.
///
final class DimmingPresentationController: UIPresentationController {
    
    lazy var dimmingView = GradientView(frame: CGRect.zero)
    
    override func presentationTransitionWillBegin() {
        
        dimmingView.frame = containerView!.bounds
        containerView!.insertSubview(dimmingView, at: 0)
        
        dimmingView.alpha = 0
        if let coordinator = presentedViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { _ in
                self.dimmingView.alpha = 1
            }, completion: nil)
        }
    }
    
    override func dismissalTransitionWillBegin()  {
      
        if let coordinator = presentedViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { _ in
                self.dimmingView.alpha = 0 }, completion: nil)
        }
    }
    
    override var shouldRemovePresentersView: Bool {
        return false
    }
}

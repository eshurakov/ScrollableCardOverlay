//
//  CardAnimatedTransitioning.swift
//  ScrollableCardOverlay
//
//  Created by Evgeny Shurakov on 18/02/2018.
//  Copyright © 2018 Evgeny Shurakov. All rights reserved.
//

import UIKit

class CardAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
        
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toController = transitionContext.viewController(forKey: .to) as? CardOverlayViewController else {
            transitionContext.completeTransition(false)
            return
        }

        guard let toView = transitionContext.view(forKey: .to) else {
            transitionContext.completeTransition(false)
            return
        }
        
        toView.frame = transitionContext.finalFrame(for: toController)
        transitionContext.containerView.addSubview(toView)
        
        toView.setNeedsLayout()
        toView.layoutIfNeeded()
        
        toController.backgroundView.alpha = 0.0
        toController.scrollView.transform = CGAffineTransform(translationX: 0.0, y: toController.scrollView.frame.size.height)
        
        let transitionAnimationBlock = {
            toController.scrollView.transform = .identity
            toController.backgroundView.alpha = 1.0
        }

        let animator = UIViewPropertyAnimator(duration: self.transitionDuration(using: transitionContext), dampingRatio: 0.8, animations: transitionAnimationBlock)
        
        animator.addCompletion { (_) in
            let success = !transitionContext.transitionWasCancelled
            if !success {
                toView.removeFromSuperview()
            }
            
            transitionContext.completeTransition(success)
        }
        
        animator.startAnimation()
        
//        UIView.animate(withDuration: self.transitionDuration(using: transitionContext),
//                       delay: 0.0,
//                       options: [.curveEaseInOut],
//                       animations: transitionAnimationBlock,
//                       completion: transitionCompletionBlock)
    }
}


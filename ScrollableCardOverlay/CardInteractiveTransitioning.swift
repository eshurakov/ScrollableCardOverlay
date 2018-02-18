//
//  CardInteractiveTransitioning.swift
//  ScrollableCardOverlay
//
//  Created by Evgeny Shurakov on 18/02/2018.
//  Copyright © 2018 Evgeny Shurakov. All rights reserved.
//

import UIKit

class CardInteractiveTransitioning: NSObject, UIViewControllerInteractiveTransitioning {
    private var completionAnimator: UIViewPropertyAnimator?
    private var statusBarAnimator: UIViewPropertyAnimator?
    private var transitionContext: UIViewControllerContextTransitioning?
    
    var scrollView: UIScrollView? {
        didSet {
            self.onProgressUpdate()
        }
    }
    
    fileprivate let backgroundView: UIView
    
    var progress: CGFloat = 0.0 {
        didSet {
            self.onProgressUpdate()
        }
    }
    
    init(backgroundView: UIView, scrollView: UIScrollView?) {
        self.scrollView = scrollView
        self.backgroundView = backgroundView
    }
    
    func cancel(withDamping: Bool) {
        if self.progress < 0.01 {
            self.transitionContext?.view(forKey: .to)?.removeFromSuperview()
            self.transitionContext?.cancelInteractiveTransition()
            self.transitionContext?.completeTransition(false)
            
            self.statusBarAnimator?.stopAnimation(false)
            self.statusBarAnimator?.finishAnimation(at: .start)
            self.statusBarAnimator = nil
            
            return
        }
        
        let completionAnimator: UIViewPropertyAnimator
        
        let animationsBlock = {
            self.scrollView?.transform = .identity
            self.backgroundView.alpha = 1.0
        }
        
        let duration = max(0.1, 0.6 * TimeInterval(self.progress))
        
        if withDamping {
            completionAnimator = UIViewPropertyAnimator(duration: duration,
                                                        dampingRatio: 0.8,
                                                        animations: animationsBlock)
        } else {
            completionAnimator = UIViewPropertyAnimator(duration: duration,
                                                        curve: .easeOut,
                                                        animations: animationsBlock)
        }
        
        if let statusBarAnimator = self.statusBarAnimator {
            statusBarAnimator.isReversed = true
            completionAnimator.addAnimations {
                statusBarAnimator.startAnimation()
            }
        }
        
        self.completionAnimator = completionAnimator
        completionAnimator.addCompletion { (_) in
            self.transitionContext?.view(forKey: .to)?.removeFromSuperview()
            
            self.transitionContext?.cancelInteractiveTransition()
            self.transitionContext?.completeTransition(false)
            self.completionAnimator = nil
            self.statusBarAnimator = nil
        }
        
        completionAnimator.startAnimation()
    }
    
    func finish() {
        let duration = max(0.1, 0.4 * TimeInterval(1.0 - self.progress))
        let animationsBlock = {
            if let scrollView = self.scrollView {
                scrollView.transform = CGAffineTransform(translationX: 0.0, y: scrollView.frame.size.height)
            }
            self.backgroundView.alpha = 0.0
        }
        
        let completionAnimator = UIViewPropertyAnimator(duration: duration,
                                                        curve: .easeOut,
                                                        animations: animationsBlock)
        
        if let statusBarAnimator = self.statusBarAnimator {
            statusBarAnimator.isReversed = false
            completionAnimator.addAnimations {
                statusBarAnimator.startAnimation()
            }
        }
        
        self.completionAnimator = completionAnimator
        completionAnimator.addCompletion { (_) in
            self.transitionContext?.view(forKey: .from)?.removeFromSuperview()
            
            self.transitionContext?.finishInteractiveTransition()
            self.transitionContext?.completeTransition(true)
            self.completionAnimator = nil
            self.statusBarAnimator = nil
        }
        completionAnimator.startAnimation()
    }
    
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        
        if let toController = transitionContext.viewController(forKey: .to),
            let fromView = transitionContext.view(forKey: .from),
            let toView = transitionContext.view(forKey: .to) {
            
            toView.frame = transitionContext.finalFrame(for: toController)
            transitionContext.containerView.insertSubview(toView, belowSubview: fromView)
        }
        
        self.statusBarAnimator = UIViewPropertyAnimator(duration: 0.4, curve: .easeInOut, animations: {
            UIView.animate(withDuration: 0.4, delay: 0.0, options: [.curveEaseInOut], animations: {
                self.transitionContext?.updateInteractiveTransition(self.progress)
            }, completion: nil)
        })
        self.statusBarAnimator?.scrubsLinearly = true
        
        self.onProgressUpdate()
    }
    
    private func onProgressUpdate() {
        self.backgroundView.alpha = 1.0 - self.progress
        if let scrollView = self.scrollView {
            scrollView.transform = CGAffineTransform(translationX: 0.0, y: scrollView.frame.size.height * self.progress)
        }
        
        self.statusBarAnimator?.fractionComplete = self.progress
        self.transitionContext?.updateInteractiveTransition(self.progress)
    }
}

//
//  CardTransitioningDelegate.swift
//  ScrollableCardOverlay
//
//  Created by Evgeny Shurakov on 18/02/2018.
//  Copyright © 2018 Evgeny Shurakov. All rights reserved.
//

import UIKit

class CardTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    static let shared = CardTransitioningDelegate()
    
    var interactionController: CardInteractiveTransitioning?
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CardAnimatedTransitioning()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CardAnimatedTransitioning()
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.interactionController
    }
    
}

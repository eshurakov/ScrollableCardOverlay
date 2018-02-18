//
//  CardOverlayViewController.swift
//  ScrollableCardOverlay
//
//  Created by Evgeny Shurakov on 18/02/2018.
//  Copyright © 2018 Evgeny Shurakov. All rights reserved.
//

import UIKit

class CardOverlayViewController: UIViewController {
    private var interactiveTransitioningDelegate: CardTransitioningDelegate?
    
    private var panGestureRecognizer: UIPanGestureRecognizer?
    private var panTranslationCompensation: CGFloat = 0.0
    
    @IBOutlet weak var backgroundView: UIView! {
        didSet {
            self.backgroundView.backgroundColor = .orange
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            self.scrollView.alwaysBounceVertical = true
            self.scrollView.delegate = self
            self.scrollView.clipsToBounds = false
        }
    }
    
    var statusBarStyle: UIStatusBarStyle = .lightContent {
        didSet {
            if oldValue == self.statusBarStyle {
                return
            }
            
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.statusBarStyle
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
//        self.modalPresentationStyle = .overFullScreen
        self.modalPresentationStyle = .fullScreen
        self.modalPresentationCapturesStatusBarAppearance = true
        
        self.transitioningDelegate = CardTransitioningDelegate.shared
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .clear
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        self.scrollView.addGestureRecognizer(panGestureRecognizer)
        panGestureRecognizer.delegate = self
        
        self.panGestureRecognizer = panGestureRecognizer
    }

    @objc private func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: self.view).y
        
        switch gestureRecognizer.state {
        case .began, .changed:
            if self.scrollView.contentOffset.y < 0 {
                if let activeTransitioningDelegate = self.interactiveTransitioningDelegate {
                    if let interactor = activeTransitioningDelegate.interactionController {
                        if interactor.scrollView == nil {
                            self.panTranslationCompensation = translation + self.scrollView.contentOffset.y
                            interactor.scrollView = self.scrollView
                            
                            self.scrollView.bounces = false
                            self.scrollView.contentOffset = .zero
                        }
                    }
                } else {
                    self.panTranslationCompensation = translation + self.scrollView.contentOffset.y
                    let progress = min((translation - self.panTranslationCompensation) / self.scrollView.frame.height, 1.0)
                    
                    let interactionController = CardInteractiveTransitioning(backgroundView: self.backgroundView, scrollView: self.scrollView)
                    interactionController.progress = progress
                    
                    let transitioningDelegate = CardTransitioningDelegate()
                    transitioningDelegate.interactionController = interactionController
                    
                    self.interactiveTransitioningDelegate = transitioningDelegate
                    
                    self.scrollView.bounces = false
                    self.scrollView.contentOffset = .zero
                    
                    self.transitioningDelegate = transitioningDelegate
                    self.dismiss(animated: true, completion: nil)
                }
            }
            
            if self.scrollView.contentOffset.y > 0.0 && self.interactiveTransitioningDelegate != nil {
                self.scrollView.bounces = true
                self.interactiveTransitioningDelegate?.interactionController?.cancel(withDamping: false)
                self.interactiveTransitioningDelegate = nil
                self.transitioningDelegate = nil
            }
            
            let progress = min((translation - self.panTranslationCompensation) / self.scrollView.frame.height, 1.0)
            
            self.interactiveTransitioningDelegate?.interactionController?.progress = progress
            
            if progress > 0.75 {
                self.interactiveTransitioningDelegate?.interactionController?.finish()
                self.interactiveTransitioningDelegate = nil
                self.transitioningDelegate = nil
            }
            
        default:
            let velocity = gestureRecognizer.velocity(in: self.view).y
            let progress = min((translation - self.panTranslationCompensation) / self.scrollView.frame.height, 1.0)
            
            if velocity >= 0.0 && (progress > 0.4 || velocity > 800.0) {
                self.interactiveTransitioningDelegate?.interactionController?.finish()
                self.interactiveTransitioningDelegate = nil
                self.transitioningDelegate = nil
            } else {
                self.scrollView.bounces = true
                self.interactiveTransitioningDelegate?.interactionController?.cancel(withDamping: velocity > -50)
                self.interactiveTransitioningDelegate = nil
                self.transitioningDelegate = nil
            }
        }
    }
}

extension CardOverlayViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let f = self.view.convert(scrollView.bounds, from: scrollView)
        if (f.origin.y - scrollView.contentOffset.y) < 15 {
            self.statusBarStyle = .default
        } else {
            self.statusBarStyle = .lightContent
        }
        
        guard let panGestureRecognizer = self.panGestureRecognizer else {
            return
        }
        
        if panGestureRecognizer.state != .possible {
            return
        }
        
        if self.scrollView.contentOffset.y < 0 && self.interactiveTransitioningDelegate == nil {
            let progress = min(-self.scrollView.contentOffset.y / self.scrollView.frame.height, 1.0)
            
            let interactionController = CardInteractiveTransitioning(backgroundView: self.backgroundView, scrollView: nil)
            interactionController.progress = progress
            
            let transitioningDelegate = CardTransitioningDelegate()
            transitioningDelegate.interactionController = interactionController
            
            self.interactiveTransitioningDelegate = transitioningDelegate
            
            self.transitioningDelegate = transitioningDelegate
            self.dismiss(animated: true, completion: nil)
        }
        
        if self.scrollView.contentOffset.y >= 0.0 && self.interactiveTransitioningDelegate != nil {
            self.interactiveTransitioningDelegate?.interactionController?.cancel(withDamping: false)
            self.interactiveTransitioningDelegate = nil
            self.transitioningDelegate = nil
        }
        
        let progress = min(-self.scrollView.contentOffset.y / self.scrollView.frame.height, 1.0)
        
        self.interactiveTransitioningDelegate?.interactionController?.progress = progress
    }
}

extension CardOverlayViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

//
//  NewTransition.swift
//  VideoLibrary
//
//  Created by Alexander Bozhko on 09/11/2018.
//

import UIKit

public class DetailsTransition: NSObject, UIViewControllerTransitioningDelegate {
    
    var interactionController: DetailsInteractionController? = nil
    
    public var sender: UIView? = nil
    
    public init(sender: UIView?) {
        super.init()
        self.sender = sender
    }
    
    // MARK: Transitioning delegate
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentAnimator(sender)
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissAnimator(sender)
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        (animator as? DismissAnimator)?.isInteractive = interactionController != nil
        return interactionController
    }
    
}

// MARK: - Interactive dismissal support

public extension VideoViewController where Self: UIViewController {
    
    func enabledInteractiveDismissal() {
        guard transitioningDelegate is DetailsTransition || navigationController?.transitioningDelegate is DetailsTransition else { return }
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.handleInteractiveDismissal(_:)))
        pan.delegate = self.videoController
        if let scrollView = self.videoController.scrollView {
            scrollView.addGestureRecognizer(pan)
        } else {
            view.addGestureRecognizer(pan)
        }
    }
    
}

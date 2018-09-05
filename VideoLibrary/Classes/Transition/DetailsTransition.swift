//
//  DetailsTransition.swift
//  video app
//
//  Created by Alexander Bozhko on 23/08/2018.
//  Copyright © 2018 Filmgrail AS. All rights reserved.
//

import UIKit

public class DetailsTransition: NSObject, UIViewControllerTransitioningDelegate {
    
    /** superview of video view */
    private weak var initialSuperview: UIView? = nil
    
    /** Start frame of video view realted to window */
    private var initialFrame: CGRect? = nil
    
    /** Sender view is used to set animated properties to transition proccess */
    public var sender: UIView? = nil
    
    /** Video view is used for animated video transfer */
    public var videoView: VideoView? = nil
    
    /** Controller for interactive dismissal */
    var interactionController: DetailsInteractionController? = nil
    
    public init(sender: UIView?, videoView: VideoView? = nil) {
        super.init()
        
        self.initialSuperview = videoView?.superview
        self.initialFrame = initialSuperview?.convert(videoView!.frame, to: nil)
        
        self.sender = sender
        self.videoView = videoView
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = PresentAnimator(videoView: videoView, sender: sender)
        if let delegate = presented as? DetailsAnimatorDelegate {
            animator.delegate = delegate
        } else if let nc = (presented as? UINavigationController), let delegate = nc.viewControllers.last as? DetailsAnimatorDelegate {
            animator.delegate = delegate
        }
        return animator
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let isInteractive = interactionController != nil
        let animator = DismissAnimator(videoView: videoView, sender: sender, finalFrame: initialFrame, finalSuperview: initialSuperview, isInteractive: isInteractive)
        if let delegate = dismissed as? DetailsAnimatorDelegate {
            animator.delegate = delegate
        } else if let nc = (dismissed as? UINavigationController), let delegate = nc.viewControllers.last as? DetailsAnimatorDelegate {
            animator.delegate = delegate
        }
        return animator
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }
    
}

// MARK: - Interactive dismissal support

public extension VideoViewController where Self: UIViewController {
    
    public func enabledInteractiveDismissal() {
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

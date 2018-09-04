//
//  DetailsTransition.swift
//  video app
//
//  Created by Alexander Bozhko on 23/08/2018.
//  Copyright © 2018 Filmgrail AS. All rights reserved.
//

import UIKit

public class DetailsTransition: NSObject, UIViewControllerTransitioningDelegate {
    
    /** superview of sender view */
    private weak var startSuperview: UIView? = nil
    
    /** Start frame of sender view realted to window */
    var fromFrame: CGRect? = nil
    
    /** Start corenter radius of sender view */
    private var fromRadius: CGFloat = 0
    
    /** sender view */
    public var videoView: VideoView! = nil
    
    /** Controller for interactive dismissal */
    var interactionController: DetailsInteractionController? = nil
    
    public init(_ senderView: UIView?) {
        videoView = senderView as? VideoView
        startSuperview = senderView?.superview
        fromFrame = senderView?.superview?.convert(senderView!.frame, to: nil)
        fromRadius = senderView?.layer.cornerRadius ?? 0

        super.init()
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = DetailsAnimator(videoView, isPresent: true, fromFrame: fromFrame, fromRadius: fromRadius)
        if let delegate = presented as? DetailsAnimatorDelegate {
            animator.delegate = delegate
        } else if let nc = (presented as? UINavigationController), let delegate = nc.viewControllers.last as? DetailsAnimatorDelegate {
            animator.delegate = delegate
        }
        return animator
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = DetailsAnimator(videoView, isPresent: false, superview: startSuperview, fromFrame: fromFrame, fromRadius: fromRadius)
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

public extension UIViewController {
    
    public func enabledInteractiveDismissal() {
        guard transitioningDelegate is DetailsTransition else { return }
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.handleInteractiveDismissal(_:)))
        view.addGestureRecognizer(pan)
    }
    
    @objc func handleInteractiveDismissal(_ pan: UIPanGestureRecognizer) {
        guard let transition = transitioningDelegate as? DetailsTransition else { return }
        let height = transition.fromFrame?.midY ?? UIScreen.main.bounds.height
        let point = pan.translation(in: nil)
        let velocity = pan.velocity(in: nil).y
        let progress = min(1, max(0, point.y / height))
        switch pan.state {
        case .changed where transition.interactionController == nil && point.y > 20:
            transition.interactionController = DetailsInteractionController()
            var vc = presentingViewController
            if let nc = vc as? UINavigationController {
                vc = nc.viewControllers.last
            }
            dismiss(animated: true) {
                Video.shared.sync(for: vc)
            }
        case .changed where transition.interactionController != nil:
            transition.interactionController?.update(progress)
        case .ended:
            if velocity > 0 || (velocity == 0 && progress > 0.5) {
                transition.interactionController?.finish()
            } else {
                transition.interactionController?.cancel()
            }
            transition.interactionController = nil
        case .cancelled:
            transition.interactionController?.cancel()
            transition.interactionController = nil
        default: break
        }
    }
    
}

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
    
    /** Sender view is used to set animated properties to transition proccess */
    public var sender: UIView? = nil
    
    /** Video view is used for animated video transfer */
    public var videoView: VideoView? = nil
    
    /** Controller for interactive dismissal */
    var interactionController: DetailsInteractionController? = nil
    
    public init(_ senderView: UIView?) {
        videoView = senderView as? VideoView
        startSuperview = senderView?.superview
        fromFrame = senderView?.superview?.convert(senderView!.frame, to: nil)
        fromRadius = senderView?.layer.cornerRadius ?? 0

        super.init()
    }
    
    public init(sender: UIView?, videoView: VideoView? = nil) {
        super.init()
        
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

extension UIViewController {
    
    @objc func handleInteractiveDismissal(_ pan: UIPanGestureRecognizer) {
        var transition: DetailsTransition! = transitioningDelegate as? DetailsTransition
        if transition == nil {
            transition = navigationController?.transitioningDelegate as? DetailsTransition
        }
        guard transition != nil else { return }
        if let scrollView = pan.view as? UIScrollView, scrollView.contentOffset.y > 0 {
            transition.interactionController?.cancel()
            transition.interactionController = nil
            return
        }
        let height = transition.fromFrame?.midY ?? UIScreen.main.bounds.height
        let point = pan.translation(in: nil)
        let velocity = pan.velocity(in: nil).y
        let progress = min(1, max(0, point.y / height))
        switch pan.state {
        case .changed where transition.interactionController == nil && point.y > 0:
            transition.interactionController = DetailsInteractionController()
            var vc = presentingViewController
            if let nc = vc as? UINavigationController {
                vc = nc.viewControllers.last
            }
            dismiss(animated: true) {
                Video.shared.sync(for: vc)
            }
        case .changed:
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

//
//  DetailsTransition.swift
//  video app
//
//  Created by Alexander Bozhko on 23/08/2018.
//  Copyright © 2018 Filmgrail AS. All rights reserved.
//

import UIKit

public class DetailsTransition: NSObject, UIViewControllerTransitioningDelegate {
    
    private weak var startSuperview: UIView? = nil
    var startFrame: CGRect? = nil
    private var startCornerRadius: CGFloat = 0
    
    public weak var senderView: VideoView? = nil
    var interactionController: DetailsInteractionController? = nil
    
    public init(_ senderView: VideoView) {
        self.senderView = senderView
        super.init()
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let senderView = senderView else { return nil }
        startCornerRadius = senderView.layer.cornerRadius
        if let superview = senderView.superview {
            startSuperview = superview
            startFrame = senderView.superview!.convert(senderView.frame, to: nil)
        } else {
            startSuperview = nil
            startFrame = nil
        }
        let animator = DetailsAnimator(senderView, isPresent: true)
        animator.delegate = presented as? DetailsAnimatorDelegate
        return animator
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let senderView = senderView else { return nil }
        let animator = DetailsAnimator(senderView, isPresent: false, superview: startSuperview, finalFrame: startFrame, cornerRadius: startCornerRadius)
        animator.delegate = dismissed as? DetailsAnimatorDelegate
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
        let height = transition.startFrame?.midY ?? 1
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

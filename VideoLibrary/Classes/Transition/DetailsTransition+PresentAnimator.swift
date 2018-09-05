//
//  DetailsTransition+PresentAnimator.swift
//  VideoLibrary
//
//  Created by Alexander Bozhko on 05/09/2018.
//

import UIKit

extension DetailsTransition {
    
    class PresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {
        
        /** This view is used to set animated properties to transition proccess */
        private var sender: UIView? = nil
        
        /** This view is used for animated video view transfer */
        private var videoView: VideoView? = nil
        
        /** Delegate for additional animations during the transition */
        public var delegate: DetailsAnimatorDelegate? = nil
        
        private let moveDuration: TimeInterval = 0.35
        private let expandDuration: TimeInterval = 0.35
        
        init(videoView: VideoView?, sender: UIView?) {
            super.init()
            self.videoView = videoView
            self.sender = sender
        }
        
        // MARK: - Transitioning context
        
        func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            return moveDuration + expandDuration
        }
        
        func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            let videoView = self.videoView
            let delegate = self.delegate
            
            prepare(using: transitionContext)
            animate(using: transitionContext) {
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                PresentAnimator.complete(using: transitionContext, videoView: videoView, delegate: delegate)
            }
        }
        
        // MARK: - Helpers
        
        private func prepare(using context: UIViewControllerContextTransitioning) {
            guard
                let fromVC = context.viewController(forKey: .from),
                let toVC = context.viewController(forKey: .to),
                let fromView = fromVC.view,
                let toView = toVC.view else {
                    context.completeTransition(false)
                    return
            }
            delegate?.prepare(using: context, isPresentation: true)
            let container = context.containerView
            container.clipsToBounds = true
            
            // calculate initial frame
            var initialFrame: CGRect! = videoView?.superview?.convert(videoView!.frame, to: container)
            if initialFrame == nil {
                initialFrame = sender?.superview?.convert(sender!.frame, to: container)
                if initialFrame == nil {
                    initialFrame = context.finalFrame(for: toVC)
                    initialFrame.origin.y = initialFrame.maxY
                }
            }
            toView.frame = initialFrame
            videoView?.frame = initialFrame
            
            // apply initial properties
            toView.applyProperties(from: sender)
            videoView?.applyProperties(from: sender)
            
            // add members to transition container
            container.addSubview(toView)
            if let videoView = videoView { container.addSubview(videoView) }
            
            //add blur
            fromView.addBlurView()
        }
        
        private func animate(using context: UIViewControllerContextTransitioning, with completion: (() -> Void)?) {
            delegate?.animate(using: context, isPresentation: true)
            UIView.animate(withDuration: moveDuration, delay: 0, options: .curveEaseIn, animations: { [weak self] in
                self?.move(using: context)
                }, completion: nil)
            UIView.animate(withDuration: expandDuration, delay: moveDuration, options: .curveEaseOut, animations: { [weak self] in
                self?.expand(using: context)
            }) { _ in
                completion?()
            }
        }
        
        private func move(using context: UIViewControllerContextTransitioning) {
            guard
                let fromVC = context.viewController(forKey: .from),
                let toVC = context.viewController(forKey: .to),
                let fromView = fromVC.view,
                let toView = toVC.view else {
                    context.completeTransition(false)
                    return
            }
            
            // move members
            if sender != nil {
                var finalFrame = context.finalFrame(for: toVC)
                var safeInset: UIEdgeInsets! = nil
                if #available(iOS 11.0, *) {
                    safeInset = fromView.safeAreaInsets
                } else {
                    safeInset = UIEdgeInsets(top: UIApplication.shared.statusBarFrame.maxY, left: 0, bottom: 0, right: 0)
                }
                finalFrame = UIEdgeInsetsInsetRect(finalFrame, safeInset)
                
                let k = finalFrame.width / toView.frame.width
                let y = finalFrame.minY + round((k - 1) * 0.5 * toView.frame.height)
                toView.frame.origin.y = y
                videoView?.frame.origin.y = y
                toView.center.x = finalFrame.midX
                videoView?.center.x = finalFrame.midX
            }
            
            // enbale blur
            fromView.enableBlur()
        }
        
        private func expand(using context: UIViewControllerContextTransitioning) {
            guard
                let toVC = context.viewController(forKey: .to),
                let toView = toVC.view else {
                    context.completeTransition(false)
                    return
            }
            let container = context.containerView
            let finalFrame = context.finalFrame(for: toVC)
            
            let k = finalFrame.width / toView.frame.width
            let transform = toView.transform.scaledBy(x: k, y: k)
            videoView?.transform = transform
            
            // apply properties to members
            toView.applyProperties(from: container)
            videoView?.applyProperties(from: container)
            
            toView.frame = context.finalFrame(for: toVC)
        }
        
        private class func complete(using context: UIViewControllerContextTransitioning, videoView: VideoView?, delegate: DetailsAnimatorDelegate?) {
            // normalize transform
            if let videoView = videoView {
                let frame = videoView.frame
                videoView.transform = .identity
                videoView.frame = frame
            }
            
            videoView?.removeFromSuperview()
            delegate?.finish(using: context, isPresentation: true)
        }
        
    }
    
}

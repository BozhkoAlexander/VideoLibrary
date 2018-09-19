//
//  DetailsTransition+PresentAnimator.swift
//  VideoLibrary
//
//  Created by Alexander Bozhko on 05/09/2018.
//

import UIKit

extension DetailsTransition {
    
    class PresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {
        
        /** This view is used for animated video view transfer */
        private var videoView: VideoView? = nil
        
        /** Delegate for additional animations during the transition */
        public var delegate: DetailsAnimatorDelegate? = nil
        
        private let moveDuration: TimeInterval = 0.35
        private let expandDuration: TimeInterval = 0.35
        
        init(videoView: VideoView?, sender: UIView?) {
            super.init()
            self.videoView = videoView
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
                PresentAnimator.complete(using: transitionContext, videoView: videoView, delegate: delegate)
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
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
            
            // calculate initial frame
            var initialFrame: CGRect! = videoView?.superview?.convert(videoView!.frame, to: container)
            var toViewInitialFrame = context.finalFrame(for: toVC)
            toViewInitialFrame.origin.y = toViewInitialFrame.maxY
            if initialFrame == nil {
                initialFrame = toViewInitialFrame
            }
            videoView?.frame = initialFrame
            toView.frame = toViewInitialFrame
            
            // apply initial properties
            toView.applyProperties()
            videoView?.applyProperties()
            
            // add members to transition container
            container.addSubview(toView)
            if let videoView = videoView {
                container.addSubview(videoView)
                
                let k = videoView.frame.width / toView.frame.width
                toView.transform = toView.transform.scaledBy(x: k, y: k)
                toView.frame = videoView.frame
            } else {
                let center = toView.center
                toView.transform = toView.transform.scaledBy(x: 0.9, y: 0.9)
                toView.center = center
            }
            
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
            toView.frame.size.height = round(k * finalFrame.height)
            
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
            let finalFrame = context.finalFrame(for: toVC)
            
            let k = finalFrame.width / toView.frame.width
            videoView?.transform = videoView!.transform.scaledBy(x: k, y: k)
            
            // apply properties to members
            toView.removeProperties()
            videoView?.removeProperties()
            
            toView.transform = .identity
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
